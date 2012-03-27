class ManuscriptCoiForm < CoiForm
  include ActionView::Helpers::UrlHelper
  include ActionController::UrlWriter
  include ActionView::Helpers::TagHelper
  # Table Relationships
  belongs_to :contribution
  belongs_to :article_submission_reviewer
  
  # Validations
  #  validates_inclusion_of :alternative_use, :in => [true, false], :if => :updating_state?, :message=>'has not been answered'
  #
  #  validates_presence_of :alternative_use_details, :if => :updating_state_and_alternative_use?
  
  attr_human_name  'unbiased' => 'Unbiased CME activity question'
  
  def parent
    return (self.contribution || self.article_submission_reviewer)
  end
  # Conveinence methods
  def user
    parent.user
  end
  
  def article_submission
    parent.article_submission
  end
  
  def corresponding_author
    parent.article_submission.corresponding_author
  end
  
  
  def previous
    if self.version.to_i <= 0
      return nil
    else
      ManuscriptCoiForm.find(:last, :conditions=>['contribution_id = ? AND version < ?', self.contribution_id, self.version], :order=>'version ASC')
    end
  end
  
 
    
    
  end
