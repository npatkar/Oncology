require 'active_merchant'

class Charge < ActiveRecord::Base
  attr_writer :password

  belongs_to :article_submission
  belongs_to :charge_type
  belongs_to :charge_pdf, 
             :dependent => :destroy, 
             :class_name => 'Pdf'
             
  has_many :cc_transactions
  
  has_one :last_cc_transaction, :class_name => 'CcTransaction', :order => 'updated_at DESC'
  acts_as_state_machine :initial => :created

  state :created
  state :processing, :enter => :do_process, :after => :act_on_result
  state :failed, :enter => :do_failed_actions
  state :settled, :enter => :do_settled_actions
  state :canceled

  event :process do
    transitions :to => :processing, :from => :created
    transitions :to => :processing, :from => :failed
    transitions :to => :processing, :from => :canceled
  end

  event :cancel do
    transitions :to => :canceled, :from => :processing
    transitions :to => :canceled, :from => :failed
    transitions :to => :canceled, :from => :created
  end

  event :settle do
    transitions :to => :settled, :from => :processing
  end

  event :fail do
    transitions :to => :failed, :from => :processing
  end
 
  before_save :set_defaults

  def initialize(*params)
    super(*params)
    if !self.charge_type
      raise ArgumentError, "You must specify the charge_type when instantiating a Charge"
    end
    self.amount = self.charge_type.amount
  end

  def description
    self.charge_type.description
  end
  def code
    self.charge_type.code
  end

  def status
    case self.state
      when 'created'
        'Not attempted'
      when 'processing'
        'Processing'
      when 'failed'
        'Failed'
      when 'settled'
        "Processed #{self.processed.strftime('%x %H%M')}"
      when 'canceled'
        'Canceled'
      else
        '*** unknown state ***'
    end
  end

  def transaction_summary
    self.cc_transactions.collect {|cc_transaction| cc_transaction.label}
  end

  def label
    "#{self.description} (#{self.amount / 100.0})"
  end

  def user_name
    self.article_submission.corresponding_author.full_name
  end
  def when_last_transaction
    last_cc_transaction.created_at.strftime("%x %H:%M")
  end
  
  
  def amount_in_dollars
    self.amount / 100
  end

  private

  def set_defaults
    self.date_due ||= Date.today
  end
  

  def do_process
    self.save if self.new_record?
    puts 'do_process'
    self.cc_transactions.create.process!
  end

  def act_on_result
    self.last_cc_transaction.success ? self.settle! : self.fail!
  end

  def do_failed_actions
    Notifier.deliver_notify_failed_credit_card(self)
  end

  def do_settled_actions
    self.update_attribute(:processed, Time.now)
    # stub
  end
  
end
