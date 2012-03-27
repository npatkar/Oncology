class AdditionalFile < ActiveRecord::Base
  belongs_to :article_submission
  
  upload_column :file, :extensions => %w(doc rtf docx docm odt sxw eps tiff tif jpg jpeg pdf ppt xls pptx xlsx)
  validates_integrity_of :file
  validates_presence_of :file
end
