class Manuscript < ActiveRecord::Base
  belongs_to :article_submission
  has_attached_file :pfile
  validates_attachment_size :pfile, :less_than => 5.megabytes
  has_many :updated_manuscripts,:dependent=>:destroy
  has_many :users,:through=>:reviewer_manuscripts
  has_one :updated_manuscript
  include EntityMixin
  
  #:extensions => %w(doc rtf docx docm odt sxw eps tiff tif jpg jpeg pdf)
end

