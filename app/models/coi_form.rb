class CoiForm < ActiveRecord::Base

  # table relationships
  has_one :pdf, :dependent => :destroy 
 
  # virtual attributes
  attr_accessor :form_state

  # Table Description

  # Triggers
  before_validation :check_constraints
  before_save :update_save_audit_trail

  
  before_create :update_create_audit_trail
  
  
  # Validations to run on the update page
  
  

  validates_inclusion_of :conflicts,    :in => [true, false], :if => :updating_state?, :message=>'has not been answered'

  validates_inclusion_of :unbiased,    :in => [true, false], :if => :updating_state?, :message=>'has not been answered'

  validate :at_least_one_conflict_checked, :if => :updating_state_and_has_conflicts?
 

#  validates_inclusion_of :employment,   :in => [true, false], :if => :updating_state_and_has_conflicts?, :message=>'has not been answered'
#  validates_inclusion_of :ip,           :in => [true, false], :if => :updating_state_and_has_conflicts?, :message=>'has not been answered'
#  validates_inclusion_of :consultant,   :in => [true, false], :if => :updating_state_and_has_conflicts?, :message=>'has not been answered'
#  validates_inclusion_of :honoraria,    :in => [true, false], :if => :updating_state_and_has_conflicts?, :message=>'has not been answered'
#  validates_inclusion_of :research,     :in => [true, false], :if => :updating_state_and_has_conflicts?, :message=>'has not been answered'
#  validates_inclusion_of :ownership,    :in => [true, false], :if => :updating_state_and_has_conflicts?, :message=>'has not been answered'
#  validates_inclusion_of :expert,       :in => [true, false], :if => :updating_state_and_has_conflicts?, :message=>'has not been answered'
#  validates_inclusion_of :other,        :in => [true, false], :if => :updating_state_and_has_conflicts?, :message=>'has not been answered'




  validates_presence_of :employment_details, :if => :updating_state_and_employment?
  validates_presence_of :ip_details,        :if => :updating_state_and_ip?
  validates_presence_of :consultant_details, :if => :updating_state_and_consultant?
  validates_presence_of :honoraria_details, :if => :updating_state_and_honoraria?
  validates_presence_of :research_details,  :if => :updating_state_and_research?
  validates_presence_of :ownership_details, :if => :updating_state_and_ownership?
  validates_presence_of :expert_details,     :if => :updating_state_and_expert?
  validates_presence_of :other_details,     :if => :updating_state_and_other?
  
  validate :check_compensation
  validates_length_of :employment_details,:maximum=>250,:allow_nil => true
  validates_length_of :ip_details, :maximum=>250,:allow_nil => true
  validates_length_of :consultant_details,:maximum=>250,:allow_nil => true
  validates_length_of :honoraria_details,:maximum=>250,:allow_nil => true
  validates_length_of :research_details, :maximum=>250,:allow_nil => true
  validates_length_of :ownership_details,:maximum=>250,:allow_nil => true
  validates_length_of :expert_details, :maximum=>250,:allow_nil => true
  validates_length_of :other_details,   :maximum=>250,:allow_nil => true
 
  validates_presence_of :sig_completed_by, :if => :commit_state?
  validates_acceptance_of :sig_assent, :accept=>true, :if => :commit_state?
  
  
  CONFLICT_FIELDS =  %w(ip consultant employment expert other ownership research honoraria)

  # Override the default column names so our error messages are more friendly
  attr_human_name 'alternative_use' => 'Discuss unlabeled, investigational, or alternative use',
                  'employment' => 'Employment / Leadership Position',
                  'expert' => 'Expert Testimony',
                  'consultant' => 'Consultant / Advisory Role',
                  'honoraria' => 'Honoraria Received',
                  'ip' => 'Intellectual Property Rights / Patent Holder',
                  'ownership' => 'Ownership Interest',
                  'research' => 'Research Funding / Contracted Research',
                  'conflicts' => 'Conflicts',
                  
                  'consultant_details' => 'Consultant / Advisory Role Details',
                  'honoraria_details' => 'Honoraria Received Details',
                  'ip_details' => 'Intellectual Property Rights / Patent Holder Details',
                  'ownership_details_' => 'Ownership Interest Details',
                  'research_details' => 'Research Funding / Contracted Research Details',

                  'sig_completed_by' => 'Signature Completed By',
                  'sig_entity' => 'Signature Organization/Institution',
                  'sig_entity_title' => 'Signature Organization / Institution and Your Title',
                  'sig_assent' => 'The Terms'
 
 
 
 def check_compensation
     if self.conflicts
        CONFLICT_FIELDS.each do |attr|
          if self.send(attr)
              comp = self.send("#{attr}_comp") == 0 ? false : self.send("#{attr}_comp")
              uncomp = self.send("#{attr}_uncomp")  == 0 ? false : self.send("#{attr}_uncomp")
              if comp == uncomp
                 errors.add(attr, "must be recorded as compensated or uncompensated")
              end
          end
        end    
     end
 end
  
  # Give details on state of 'state'
  def details_on(show_state, field)
    answer = self.send(field.to_s) ? 'Yes' : 'No'
    if self.send(field.to_s) and  show_state
      "#{self.send(field.to_s + "_details")}"
    elsif ! self.send(field.to_s) and !  show_state
            "#{self.send(field.to_s + "_details")}"
    else
      ''
    end
  end   
 
  def submit_date
    self.committed? ? self.committed.strftime("%x") : 'Not Submitted' 
  end
 
  
  def update_create_audit_trail
    self.create_date = Time.now
  end

  def update_save_audit_trail
    self.mod_date = Time.now
    self.sig_time = Time.now if updating_state?
  end
  
  def commit
    self.committed = Time.now
    self.sig_time = Time.now
  end
  
  def create_an_update
    new_coi_form = self.clone
    new_coi_form.committed = nil
    new_coi_form.create_date = nil
    new_coi_form.mod_date = nil
    new_coi_form.create_by_ip = nil
    new_coi_form.mod_by_ip = nil

    new_coi_form.conflicts = nil
    new_coi_form.unbiased = nil
    
    new_coi_form.sig_completed_by = nil    
    new_coi_form.sig_entity = nil
    new_coi_form.sig_entity_title = nil
    new_coi_form.sig_time = nil
    new_coi_form.sig_assent = nil
    
    new_coi_form.version = self.version + 1
    new_coi_form
    Rails.logger.info(new_coi_form.attributes.inspect)
    return new_coi_form
  end
  
  def has_reported_bias?
   if (self.employment || self.ip || self.consultant || self.honoraria || self.research || self.ownership || self.expert || self.other)
     true
   else
     false
   end
 end

  def reported_at_least_one_conflict
    self.alternative_use || self.consultant || self.employment || self.expert || self.honoraria || self.ip || self.other || self.ownership || self.research
  end 
 
  private 
  
  # Fix any inconsistancies
  def check_constraints

    # This isn't used anymore, as we're requiring all questions in the conflicts group to be completed no matter what. (not hiding on the page any more either)
    #unless self.conflicts
    #  self.consultant      = false
    #  self.employment      = false
    #  self.expert          = false
    #  self.honoraria       = false
    #  self.ip              = false
    #  self.other           = false
    #  self.ownership       = false
    #  self.research        = false
    #end
    
    self.alternative_use_details = nil unless self.alternative_use
    self.consultant_details      = nil unless self.consultant
    self.employment_details      = nil unless self.employment
    self.expert_details          = nil unless self.expert
    self.honoraria_details       = nil unless self.honoraria
    self.ip_details              = nil unless self.ip
    self.other_details           = nil unless self.other
    self.ownership_details       = nil unless self.ownership
    self.research_details        = nil unless self.research
    
    unless self.conflicts
      CONFLICT_FIELDS.each do |val|
         comp = "#{val}_comp"
         uncomp = "#{val}_uncomp"
         write_attribute(comp,false)
         write_attribute(uncomp,false)
        end
    end
  end

  def at_least_one_conflict_checked
    unless reported_at_least_one_conflict
      errors.add(:base, 'You have indicated you have real or apparent conflicts. Please explain in one of the conflict fields available.')
    end
  end
  
  
  def updating_state_and_has_conflicts?
    updating_state? and self.conflicts
  end

  def updating_state_and_consultant?
   (updating_state? and self.consultant) and self.conflicts
  end
  def updating_state_and_employment?
    (updating_state? and self.employment) and self.conflicts
  end
  def updating_state_and_expert?
    (updating_state? and self.expert) and self.conflicts
  end
  def updating_state_and_alternative_use?
    (updating_state? and self.alternative_use) and self.conflicts
  end
  def updating_state_and_honoraria?
    (updating_state? and self.honoraria) and self.conflicts
  end
  def updating_state_and_ip?
    (updating_state? and self.ip) and self.conflicts
  end
  def updating_state_and_other?
    (updating_state? and self.other) and self.conflicts
  end
  def updating_state_and_ownership?
    (updating_state? and self.ownership) and self.conflicts
  end
  def updating_state_and_research?
    (updating_state? and self.research) and self.conflicts
  end
  def updating_state_and_not_has_reported_bias?
    updating_state? and ! has_reported_bias?
  end
  def updating_state_and_has_reported_bias?
    updating_state? and has_reported_bias?
  end
  
  

  
  def updating_state?
    self.form_state == :updating or review_state?
  end
  
  def commit_state?
    self.form_state == :commit
  end
   
   
  def review_state?
    return false
  end
  
  
end
