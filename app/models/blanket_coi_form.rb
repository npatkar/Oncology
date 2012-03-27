class BlanketCoiForm < CoiForm
  
  # Table Relationships
  belongs_to :user



  # Because manuscript_coi_form supports these, we'll return nil, JIC they get called
  def article_submission
    nil
  end
  def corresponding_author
    nil
  end
  
  def previous
    if self.version.to_i <= 0
      return nil
    else
      BlanketCoiForm.find(:last, :conditions=>['user_id = ? AND version < ?', self.user_id, self.version], :order=>'version ASC')
    end
  end
  
end
