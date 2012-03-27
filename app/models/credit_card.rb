require 'active_merchant'
require 'digest/md5'

class CreditCard < ActiveRecord::Base
  @@validation_mode            = App::Config.gateway_test ? 'testMode' : 'liveMode'
  @@gateway_cim_profile_prefix = App::Config.gateway_cim_profile_prefix
  @@public_key                 = App::Config.public_key
  @@private_key                = App::Config.private_key
  @@gateway_login              = App::Config.gateway_login
  @@gateway_password           = App::Config.gateway_password
  @@gateway_test               = App::Config.gateway_test


  attr_accessor :first_name, :last_name, :name, :num, :exp_mo, :exp_yr, :cvv, :zip
  attr_protected :encrypted_name, :encrypted_exp_mo, :encrypted_exp_yr, :encrypted_cvv, :encrypted_zip, :encrypted_iv, :encrypted_key, :merchant_customer_id

  belongs_to :user
  has_many :transactions
  has_many :charges, :through => :transactions 

  # Credit Card validations
  validates_presence_of :cc_type
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :exp_mo
  validates_presence_of :exp_yr
  validates_presence_of :cvv
  validates_presence_of :zip

  # regex from: http://www.regular-expressions.info/creditcard.html
  validates_format_of   :num, :with => /^(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|6(?:011|5[0-9][0-9])[0-9]{12}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|(?:2131|1800|35\d{3})\d{11})$/
  validate :check_num?


  before_save :normalize

  #before_save :encrypt
  before_save :fill_last_four, :if => :have_info_to_update
  before_save :connect_to_gateway
  before_save :create_or_update_customer_profile
  before_save :create_or_update_payment_profile, :if => :have_info_to_update

  before_destroy :connect_to_gateway
  before_destroy :delete_customer_profile
 
  # Override the default column names so our error messages are more friendly
  attr_human_name 'cc_type' => 'Card Type',
                  'name' => 'Name on Credit Card',
                  'num' => 'Card Number',
                  'exp_mo' => 'Expiration Month',
                  'exp_yr' => 'Expiration Year',
                  'cvv' => 'Card Security Code',
                  'zip' => 'Billing Address Zip/Postal Code'


  def self.get_customer_profile(customer_profile_id)
    gw = ActiveMerchant::Billing::AuthorizeNetCimGateway.new(
      :login    => @@gateway_login,
      :password => @@gateway_password,
      :test     => @@gateway_test
    )
    gw.get_customer_profile(:customer_profile_id => customer_profile_id)
  end



  def num_masked
    self.num ? ('X' * 12) + self.num[-4, 0] : '****'
  end

  def decrypt(password) 
      private_key = OpenSSL::PKey::RSA.new(File.read(@@private_key),password) 
      cipher = OpenSSL::Cipher::Cipher.new('aes-256-cbc')  
      cipher.decrypt  
      cipher.key = private_key.private_decrypt(self.encrypted_key)  
      cipher.iv = private_key.private_decrypt(self.encrypted_iv)  
 
      # Decrypt each encrypted attribute, and store in accessors
      [:name, :exp_mo, :exp_yr, :cvv, :zip].each do |a|  
        cipher.update(self.send('encrypted_' + a.to_s))
        write_attribute(a.to_s, cipher.final)
      end
  end  

  def clear 
    self.encrypted_name = self.encrypted_exp_mo = self.encrypted_exp_yr = self.encrypted_cvv = self.encrypted_zip = self.encrypted_iv = self.encrypted_key = nil
  end  

  def process_transaction(cc_transaction, options={})
    connect_to_gateway or raise(StandardError, "Could not connect to Gateway...")

    create_customer_profile_transaction(cc_transaction, options)
  end


  def reattach_customer_profile(customer_profile_id)
    logger.info("*** Trying to reattach this credit card to customer_profile: #{customer_profile_id}")
    response = CreditCard.get_customer_profile(customer_profile_id)
    logger.info("*** response: #{response.inspect}")
    if response.success?
      self.customer_profile_id = response.params['profile']['customer_profile_id']
      merchant_customer_id(response.params['profile']['merchant_customer_id'])

      if response.params['profile']['payment_profiles'] and response.params['profile']['payment_profiles'].length > 0
        payment_profiles = response.params['profile']['payment_profiles']

        if payment_profiles.class == Array
          self.payment_profile_id = payment_profiles[0]['customer_payment_profile_id']
          self.num_last_four = payment_profiles[0]['payment']['credit_card']['card_number']
        elsif payment_profiles.class == Hash
          self.payment_profile_id = payment_profiles['customer_payment_profile_id']
          self.num_last_four = payment_profiles['payment']['credit_card']['card_number']
        end

      end
      true
    else
      logger.info("*** Failed to reattach this credit card to customer_profile: #{customer_profile_id}, #{response.inspect}")
      false
    end
  end

  def merchant_customer_id(new_id = nil)
    if new_id
      self[:merchant_customer_id] = new_id
    else
      self[:merchant_customer_id] || self[:merchant_customer_id] = new_merchant_customer_id
    end
  end



  private

  def have_info_to_update
    have_info = !(self.cc_type.blank? || self.first_name.blank? || self.last_name.blank? || self.exp_mo.blank? || self.exp_yr.blank? || self.cvv.blank? || self.zip.blank?)
    logger.info("*** have_info: #{have_info}")
    have_info
  end

  def connect_to_gateway(options={})
    #logger.info("*** connecting to gw, login: #{@@gateway_login}, password: #{@@gateway_password}, test: #{@@gateway_test}")
    return true if ENV['RAILS_ENV'] == 'development' || ENV['RAILS_ENV'] == 'test'
    
    @gw ||= ActiveMerchant::Billing::AuthorizeNetCimGateway.new(
      :login    => @@gateway_login,
      :password => @@gateway_password,
      :test     => @@gateway_test
    )
  end


  # process transaction ... We are given AMOUNT IN PENNIES, SEND AMOUNT IN DOLLARS
  def create_customer_profile_transaction(cc_transaction, options={})
    return true if ENV['RAILS_ENV'] == 'development' || ENV['RAILS_ENV'] == 'test'
    
      transaction = {
                        :type => :auth_capture,
                        :amount => cc_transaction.charge.amount / 100,
                        :line_items => { :name => cc_transaction.charge.charge_type.description },
                        :customer_profile_id => self.customer_profile_id,
                        :customer_payment_profile_id => self.payment_profile_id
                      }
    logger.info("*** creating customer profile transaction for credit card: #{self.inspect}\n\ntransaction: #{transaction.inspect}") 
    @gw.create_customer_profile_transaction( :transaction => transaction )
  end


  # Either create or update a CIM profile
  def create_or_update_payment_profile
    return true if ENV['RAILS_ENV'] == 'development' || ENV['RAILS_ENV'] == 'test'
    
    cc_info = { :first_name         => self.first_name,
                :last_name          => self.last_name,
                :number             => self.num,
                :month              => self.exp_mo.to_i,
                :year               => self.exp_yr.to_i,
                :verification_value => self.cvv
              }

    bill = { :first_name => self.first_name,
             :last_name => self.last_name,
             :zip => self.zip
           }

    if !self.payment_profile_id
      response = create_payment_profile :cc_info => cc_info, :bill => bill
      self.payment_profile_id = response.params['customer_payment_profile_id'] if response.success?
    else
      response = update_payment_profile :cc_info => cc_info, :bill => bill
    end

    logger.info("*** response from create or update payment_profile: #{response.inspect}")

    if !response.success? and response.params['messages']['message']['code'] == 'E00039'
      # We have a duplicate payment profile, try to delete everything and start fresh,
      # .. but only if we have credit card info to recreate the profile
      unless have_info_to_update and delete_customer_profile and create_or_update_customer_profile and create_or_update_payment_profile
        raise StandardError, "Could not create or update customer payment profile (duplicate payment profile): #{response.inspect}\n"
      end
    elsif !response.success?
      raise StandardError, "Could not create or update customer payment profile: #{response.inspect}\n"
    end
    response.success?
  end


  def create_or_update_customer_profile
    return true if ENV['RAILS_ENV'] == 'development' || ENV['RAILS_ENV'] == 'test'
    
    profile_info = {
      :merchant_customer_id => merchant_customer_id,
      :email                => self.user.email,
      :description          => "forms site customer profile for user #{self.user.id}, #{self.user.email}",
      :validation_mode      => @@validation_mode
    }

    if !self.customer_profile_id
      logger.info("*** creating a new customer profile")
      response = @gw.create_customer_profile :profile => profile_info
      self.customer_profile_id = response.params['customer_profile_id'] if response.success?
    else
      logger.info("*** updating a new customer profile")
      profile_info[:customer_profile_id] = self.customer_profile_id
      response = @gw.update_customer_profile :profile => profile_info
    end

    success = true
    # Example of text of this message: "A duplicate record with id 1159774 already exists." 
    if !response.success? and response.params['messages']['message']['code'] == 'E00039' and self.reattach_customer_profile(response.params['messages']['message']['text'].match(/\D(\d+)\D/)[1])
      logger.info("*** Successfully reattached this credit card to customer_profile: #{customer_profile_id}")
    elsif !response.success?
      success = false
      raise StandardError, "Could not create or update customer profile: #{response.inspect}\n"
    end
    success
  end



  def create_payment_profile(options={})
    return true if ENV['RAILS_ENV'] == 'development' || ENV['RAILS_ENV'] == 'test'
    
    logger.info("*** creating a new payment profile: #{options.inspect}")
    credit_card = ActiveMerchant::Billing::CreditCard.new(options[:cc_info]);
     
    logger.info("*** creating a new payment profile: #{credit_card.inspect}")
    payment_profile = { :bill_to => options[:bill], 
                        :payment => { :credit_card => credit_card } 
                      }

     # Create a new one
     @gw.create_customer_payment_profile :customer_profile_id => self.customer_profile_id, 
                                         :payment_profile => payment_profile
  end

  # if they have a merchant_customer_id, then they need to be updated, else create a new profile with Authorize.net
  def update_payment_profile(options={})
    return true if ENV['RAILS_ENV'] == 'development' || ENV['RAILS_ENV'] == 'test'
    
    logger.info("*** updating an existing payment profile")
     credit_card = ActiveMerchant::Billing::CreditCard.new(options[:cc_info])

     payment_profile = { :bill_to => options[:bill], 
                         :payment => { :credit_card => credit_card }, 
                         :customer_payment_profile_id => self.payment_profile_id 
                        }

     @gw.update_customer_payment_profile :payment_profile => payment_profile, 
                                         :customer_profile_id => self.customer_profile_id, 
                                         :customer_payment_profile_id => self.payment_profile_id
  end


  def new_merchant_customer_id
   @@gateway_cim_profile_prefix + Digest::MD5.hexdigest(self.first_name + self.last_name + self.num)[0..10]
  end

  def payment_profile
      {
                                 :customer_type => 'individual',
                                 :bill_to => {
                                               :first_name => self.first_name,
                                               :last_name => self.last_name,
                                               :zip => self.zip
                                             },
                                 :payment => {
                                               :credit_card => {
                                                                 :card_number => self.num,
                                                                 :expiration_date => "#{self.exp_yr}-#{self.exp_mo}",
                                                                 :card_code => self.cvv
                                                               }
                                             }
                               }
  end


  #implementation of the Luhn algorithm to check cc numbers
  # got from: http://blog.internautdesign.com/2007/4/18/ruby-luhn-check-aka-mod-10-formula
  def check_num?
    return unless self.num
    odd = true
    self.num.to_s.gsub(/\D/,'').reverse.split('').map(&:to_i).collect { |d|
      d *= 2 if odd = !odd
      d > 9 ? d - 9 : d
    }.sum % 10 == 0
  end

  def normalize
    return unless self.num
    self.num.gsub!(/\D/,'')

    return unless self.exp_yr
    self.exp_yr = self.exp_yr.to_i % 2000 + 2000
  end
  
  def encrypt
      cipher = OpenSSL::Cipher::Cipher.new('aes-256-cbc')  
      cipher.encrypt  
      cipher.key = random_key = cipher.random_key  
      cipher.iv = random_iv = cipher.random_iv  

      # Encrypt each sensitive plain text attribute 
      [:name, :exp_mo, :exp_yr, :cvv, :zip].each do |a|  
        cipher.update(self.send(a.to_s))
        write_attribute('encrypted_' + a.to_s, cipher.final)
      end
 
      # Encrypt our key and initialization vector 
      public_key = OpenSSL::PKey::RSA.new(File.read(@@public_key))

      self.encrypted_key =  public_key.public_encrypt(random_key)  
      self.encrypted_iv = public_key.public_encrypt(random_iv)  
  end  

  def fill_last_four
    return unless self.num
    self.num_last_four = self.num[-4,4] 
  end


  def delete_customer_profile
    return true if ENV['RAILS_ENV'] == 'development' || ENV['RAILS_ENV'] == 'test'
    
    response = @gw.delete_customer_profile :customer_profile_id => self.customer_profile_id
    if response.success? or response.params['messages']['message']['code'] == 'E00040'
      self.customer_profile_id = nil
      self.payment_profile_id = nil
    else
      raise StandardError, "Could not delete customer profile: #{response.inspect}\n"
    end
    response.success? or response.params['messages']['message']['code'] == 'E00040'
  end
end
