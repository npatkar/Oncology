# To change this template, choose Tools | Templates
# and open the template in the editor.

class Permission < ActiveRecord::Base
  belongs_to :article_submission
  
  upload_column :file, :extensions => %w(doc rtf docx docm odt sxw eps tiff tif jpg jpeg pdf)
  validates_integrity_of :file
  validates_presence_of :file
end
