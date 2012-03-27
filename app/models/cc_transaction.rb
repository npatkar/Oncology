require 'active_merchant'

class CcTransaction < ActiveRecord::Base
  # We need to accept the password to decript the credit card info
  attr_writer :password 

  belongs_to :charge

  acts_as_state_machine :initial => :not_attempted

  state :not_attempted
  state :processed, :enter => :do_process

  event :process do
    transitions :to => :processed, :from => :not_attempted
  end

  def initialize(*params)
    super(*params)
    self.amount = self.charge.amount 
  end

  def label
    case self.state
      when 'not_attempted'
        'Not attempted'
      when 'processed'
        if self.success
          "Successfully charged: #{self.created_at.strftime('%x %H:%M')}"
        else
          "Failed charge: #{self.created_at.strftime('%x %H:%M')}"
        end
      else
        '*** unknown state ***'
      end
  end

  def user
    @user ||= self.charge.article_submission.corresponding_author
  end

  def credit_card
    @credit_card ||= user.credit_card
  end

  def details
    ["Charge ID => #{self.charge.id}",
     "User ID => #{self.user.id}", 
     "Amount => #{self.charge.amount}",
     "Action => Auth_Capture", 
     "Client => #{self.user.name}", 
     "Authorization => #{self.authorization}", 
     "AVS Result => #{self.avs_result}", 
     "CVV Result => #{self.cvv_result}", 
     "Message => #{self.message}", 
     "Params => #{self.params}", 
     "Fraud Review? => #{self.fraud_review}", 
     "Success? => #{self.success}",
     "Test => #{self.test}", 
     "Response => #{self.response}"]
  end

  private

  def do_process
    self.save if self.new_record?

    if ENV['RAILS_ENV'] == 'development' || ENV['RAILS_ENV'] == 'test'
      self.authorization = 'authorization goes here'
      self.avs_result    = 'avs result goes here'
      self.cvv_result    = 'cvv result goes here'
      self.message       = 'response message goes here'
      self.params        = 'params go here'
      self.fraud_review  = 'fraud review goes here'
      self.success       = true
      self.test          = 'test param goes here'
      self.response      = 'response goes here'

    else
      response = credit_card.process_transaction(self)

      self.authorization = response.authorization
      self.avs_result    = response.avs_result[:message]
      self.cvv_result    = response.cvv_result[:message]
      self.message       = response.message
      self.params        = response.params.inspect
      self.fraud_review  = response.fraud_review?
      self.success       = response.success?
      self.test          = response.test
      self.response      = response.inspect
    end

    self.save!

    if self.success
      logger.info("Successfully charged $#{sprintf("%.2f", amount / 100)} to the credit card #{credit_card.id}")
    else
      logger.info("Unsuccessful transaction for charge $#{sprintf("%.2f", self.charge.amount / 100)} to the credit card #{credit_card.id}. response: #{self.response}")
    end
    self.success
  end

end
