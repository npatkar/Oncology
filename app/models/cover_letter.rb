class CoverLetter < ActiveRecord::Base
  belongs_to :article_submission
  
  upload_column :file, 
                :extensions => %w(doc rtf docx docm odt sxw eps tiff tif jpg jpeg pdf),
                :permission => "0664"

  validates_integrity_of :file
  validates_presence_of :file
end