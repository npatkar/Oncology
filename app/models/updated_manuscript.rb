class UpdatedManuscript<ActiveRecord::Base
  
  belongs_to :article_submission
  belongs_to :manuscript
  upload_column :file, :extensions => %w(doc rtf docx docm odt sxw eps tiff tif jpg jpeg pdf)
  validates_presence_of :file
  validates_integrity_of :file
  
  
  
end