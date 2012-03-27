class FileSender
  require 'zip/zip'
  require 'zip/zipfilesystem'
  require 'digest/md5'
  require 'net/ftp'
  
  
  PATH_PREFIX = "#{RAILS_ROOT}/public"
  URL = "ftp2.cadmus.com"
  PASS = "onc1234"
  USER_NAME = "oncpeer"
  DIR = ""
  LOCAL_ZIP_PATH = "#{Rails.root}/zip_files/"
  LOCAL_TMP_PATH = "#{Rails.root}/tmp/"
  JOURNAL_ID = "ONC"
  
  @figures = Array.new
  @man_file = ""
  @hash = Hash.new
  @file_prefix = ""
  
  
  
  def self.get_zip_file(article_submission)
    bundle_file_path = ""
    hash = Hash.new
    if article_submission.manuscript && article_submission.manuscript.file 
      hash["manuscript"] = article_submission.manuscript
    end 
    
    if article_submission.cover_letter && article_submission.cover_letter.file 
      hash["cover_letter"] = article_submission.cover_letter
    end 
    
    if article_submission.permission && article_submission.permission.file 
      hash["permission"] = article_submission.permission
    end 
    
    hash["files"] = Array.new
    article_submission.additional_files.each do |af| 
      hash["files"] <<  af    
    end
    version = article_submission.version || 1
    file_prefix = "#{article_submission.title}_v#{version}_#{Time.now.to_i}"       
    bundle_file_name = "#{file_prefix}.zip"
    bundle_file_path = "#{LOCAL_TMP_PATH}#{bundle_file_name}"
    
    Zip::ZipFile.open(bundle_file_path, Zip::ZipFile::CREATE) {
      |zipfile|
      zipfile.mkdir(file_prefix)
      zipfile.mkdir("#{file_prefix}/graphic")
      zipfile.mkdir("#{file_prefix}/manuscript")
      zipfile.mkdir("#{file_prefix}/cover_letter")
      zipfile.mkdir("#{file_prefix}/suppl_data")
      zipfile.mkdir("#{file_prefix}/permission")
      file = hash["manuscript"]    
      unless article_submission.isVideo?
        man_path = PATH_PREFIX +  hash["manuscript"].file.url
        f_name =  hash["manuscript"].file.filename
        Rails.logger.info(man_path)
        Rails.logger.info("-------------------")
        zipfile.add("#{file_prefix}/manuscript/#{f_name}",man_path)
      else
        man_file = article_submission.manuscript_video_link   
      end
      
      path = PATH_PREFIX +  hash["cover_letter"].file.url
      f_name =  hash["cover_letter"].file.filename
      zipfile.add("#{file_prefix}/cover_letter/#{f_name}",path)
      
      if hash["permission"]
        path = PATH_PREFIX +  hash["permission"].file.url
        f_name =  hash["permission"].file.filename
        zipfile.add("#{file_prefix}/cover_letter/#{f_name}",path)
        
      end
      i = 0
      hash["files"].each do|file| 
      i+=1
      suffix = i < 10 ? "0#{i}" : "#{i}"
      path = PATH_PREFIX + file.file.url
      name = file.file.filename
      name.sub!(/(\w+|\s+)*/,"#{file_prefix}-f#{suffix}")
      unless zipfile.find_entry(name)
        zipfile.add("#{file_prefix}/graphic/#{name}",path)        
      end
    end
  }
  File.chmod(0777, bundle_file_path) 
  return bundle_file_path
end


def self.create_zip_file(article_submission)  
  self.create_if_missing(LOCAL_ZIP_PATH)
  self.create_if_missing(LOCAL_TMP_PATH)
  @bundle_file_path = ""
  begin
    start = Time.now
    Rails.logger.info "Starting #{article_submission.id} @ #{start}"
    if article_submission.manuscript && article_submission.manuscript.file 
      @hash["manuscript"] = article_submission.manuscript
    end 
    
    if article_submission.cover_letter && article_submission.cover_letter.file 
      @hash["cover_letter"] = article_submission.cover_letter
    end 
    
    if article_submission.permission && article_submission.permission.file 
      @hash["permission"] = article_submission.permission
    end 
    
    @hash ["files"] = Array.new
    article_submission.additional_files.each do |af| 
      @hash["files"] <<  af    
    end
    
    Rails.logger.info "1 got files"
    @file_prefix = "ONC-#{article_submission.article.manuscript_num}"       
    @bundle_file_name = "#{@file_prefix}.zip"
    @bundle_file_path = "#{LOCAL_ZIP_PATH}#{@bundle_file_name}"
    File.delete(@bundle_file_path) if File.exists?(@bundle_file_path)   
    Rails.logger.info "2 deleted file already there if necessary"
    Zip::ZipFile.open(@bundle_file_path, Zip::ZipFile::CREATE) {
      |zipfile|
        zipfile.mkdir(@file_prefix)
        zipfile.mkdir("#{@file_prefix}/pdfs")
        zipfile.mkdir("#{@file_prefix}/graphic")
        zipfile.mkdir("#{@file_prefix}/doc")
        zipfile.mkdir("#{@file_prefix}/suppl_data")
        file = @hash["manuscript"]    
        unless article_submission.isVideo?
          man_path = PATH_PREFIX +  @hash["manuscript"].file.url
          f_name =  @hash["manuscript"].file.filename
          @man_file = f_name.sub(/(\w+|\s+)*/,@file_prefix)
          zipfile.add("#{@file_prefix}/doc/#{@man_file}",man_path)
        else
          @man_file = article_submission.manuscript_video_link   
        end
        
          path = PATH_PREFIX +  @hash["cover_letter"].file.url
          f_name =  @hash["cover_letter"].file.filename
          zipfile.add("#{@file_prefix}/cover_letter/#{f_name}",path)
          
          if @hash["permission"]
            path = PATH_PREFIX +  @hash["permission"].file.url
            f_name =  @hash["permission"].file.filename
            zipfile.add("#{@file_prefix}/permission/#{f_name}",path)   
          end
        
        i = 0
        @hash["files"].each do|file| 
        i+=1
        suffix = i < 10 ? "0#{i}" : "#{i}"
        path = PATH_PREFIX + file.file.url
        name = file.file.filename
        name.sub!(/(\w+|\s+)*/,"#{@file_prefix}-f#{suffix}")
        unless zipfile.find_entry(name)
          @figures << name
          zipfile.add("#{@file_prefix}/graphic/#{name}",path)        
        end
      end
      
      xml_file = build_xml_file(article_submission)
      zipfile.add("#{@file_prefix}/#{xml_file}",xml_file)
  }
  Rails.logger.info "3 creatd ziRails.logger.info file:#{@bundle_file_name}"
  File.chmod(0777, @bundle_file_path) 
  local_checksum = calculate_checksum(@bundle_file_path)
  begin_ftp = Time.now
  ftp_file(@bundle_file_path)
  end_ftp = Time.now
  Rails.logger.info "Ftp'd file => #{end_ftp-begin_ftp}"
  ftp_checksum = get_ftp_file_checksum(@bundle_file_name) 
  Rails.logger.info "5 got remote checksum"
  if  ftp_checksum == local_checksum
    Rails.logger.info "6 Checksums Match"
    log = CadmusSubmissionLog.create(:article_submission_id=>article_submission.id,:successful=>true,:file_name=>@bundle_file_name)
    article_submission.change_status(:article_submission_published)
  else
    Rails.logger.info "7 Checksums Don't Match"
    log = CadmusSubmissionLog.create(:article_submission_id=>article_submission.id,:successful=>false,:file_name=>@bundle_file_name,:failure_reason=>"checksum_failure")    
    Notifier.deliver_cadmus_error(log)
  end
  Rails.logger.info "Total Time: #{Time.now - start}"
rescue => e
  Rails.logger.info e.to_s
  Rails.logger.info e.backtrace.join("\r\n")
  log = CadmusSubmissionLog.create(:article_submission_id=>article_submission.id,:successful=>false,:file_name=>@bundle_file_name,:failure_reason=>e.to_s,:stack_trace=>e.backtrace.join('\r\n'))   
  begin
    Notifier.deliver_cadmus_error(log)
  rescue => m
    Rails.logger.info m.to_s
  end
end
end

def self.create_if_missing name
  Dir.mkdirs(name) unless File.directory?(name)
end 

def self.calculate_checksum(file_name)

Digest::MD5.hexdigest(File.open(file_name, "rb") { |f| f.read 
})
end


def self.ftp_file(file_name)
Net::FTP.open(URL) do |ftp|
  ftp.login(USER_NAME,PASS)
  #files = ftp.chdir(DIR)
  ftp.putbinaryfile(file_name)
end
end



def self.get_ftp_file_checksum(file_name)
zip_file = nil
ftp_file ="#{file_name}"
Net::FTP.open(URL) do |ftp|
  ftp.login(USER_NAME,PASS)
  #files = ftp.chdir(DIR)
  ftp.getbinaryfile(file_name,ftp_file)
end

return calculate_checksum(ftp_file)
end


def self.build_xml_file(as)
require 'builder'
output = ""
xml = Builder::XmlMarkup.new(:target=>output,:indent=>3)
self.add_article_info(xml,as)
add_corr_auth_info(xml,as)
add_author_grp(xml,as)
add_history_info(xml,as)
add_class_info(xml, as)
add_comments(xml,as)
add_abstract(xml,as)
add_digital_info(xml, as)
xml_content = '<?xml version="1.0" encoding="UTF-8"?>'
xml_content += "<metadata>#{output}</metadata>"
#xml_content = xml_content.gsub(/\s+</, "<");
#  xml_content = xml_content.gsub(/>\n\s/, ">");
file = File.open("#{@file_prefix}.xml", 'w') {|f| f.write(xml_content) }
File.chmod(0777, "#{@file_prefix}.xml")
return "#{@file_prefix}.xml"
end

def self.add_article_info(xml,as)
xml.articleinfo do|ai|   
ai.tag! "article-title",as.title
num = as.article ? as.article.manuscript_num : "none"
ai.tag! "manucripts-number",num
end
end


def self.add_corr_auth_info(xml,as)
corr_a = as.corresponding_author
if corr_a
xml.corrinfo do|ca|
ca.tag! "corresponding-author-firstname",(corr_a.first_name  || "")    
ca.tag! "corresponding-author-middlename",(corr_a.middle_name || "")               
ca.tag!"corresponding-author-lastname",(corr_a.last_name || "")              
ca.tag! "corresponding-author-title",(corr_a.pre_title || "")
ca.tag! "corresponding-author-institution",(corr_a.employer || "")
ca.tag! "corresponding-author-email",(corr_a.email || "")
ca.tag! "corresponding-author-address1",(corr_a.address || "")              
ca.tag! "corresponding-author-address2",(corr_a.address_2 || "")  
ca.tag! "corresponding-author-address3",""              
ca.tag! "corresponding-author-city",(corr_a.city || "")                                     
if corr_a.state_province
  ca.tag!"corresponding-author-state",corr_a.state_province.state_name
end

if corr_a.country
  ca.tag! "corresponding-author-country",corr_a.country.country_name 
end         

ca.tag! "corresponding-author-zipcode",(corr_a.zip_postalcode || "")
ca.tag! "corresponding-author-phone",(corr_a.phone_preferred || "")              
out = ""
contr = Contribution.find_by_article_submission_and_user(as.id, corr_a.id)
contr.coi_info.each {|key,value|
  out+="#{key}:#{value}\r\n"
}

ca.tag!"conflict-of-interest",out

end
end
end

def self.add_author_grp(xml,as)
xml.authorgrp do|grp|     
as.co_author_list.each do|auth|          
prefix = auth == as.first_author ? "first_author" : "other_author"        
grp.tag! "#{prefix}" do |oa|
oa.tag! "#{prefix}-firstname",(auth.first_name  || "")
oa.tag! "#{prefix}-middlename",(auth.middle_name  || "")
oa.tag! "#{prefix}-lastname" ,(auth.last_name || "")
oa.tag! "#{prefix}-suffix", ""

oa.tag! "#{prefix}-email",(auth.email  || "")              
oa.tag! "#{prefix}-institution",(auth.employer  || "")              
out = ""
contr = Contribution.find_by_article_submission_and_user(as.id, auth.id)
contr.coi_info.each {|key,value|
out+="#{key}:#{value}\r"
}
oa.tag! "conflict-of-interest", out
end     
end    
end
end

def self.add_comments(xml,as)
comm = as.publisher_comments || ""
comm += "\r\n"
comm += "Medial Writer: #{as.cacontribution.assistedinfo}"
comm += "\r\n"
comm += "Author Contributions:\r\n"
comm += as.authorcontributionsinfo_as_text
xml.comments comm
end

def self.add_history_info(xml,as)  
xml.history do |his|
val = !as.time_of_status(:article_submission_submitted).blank? ? as.time_of_status(:article_submission_submitted).strftime('%m/%d/%y') :  ""
his.tag!"submitted_date",val

val = !as.time_of_status(:article_submission_submitted).blank? ? as.time_of_status(:article_submission_submitted).strftime('%m/%d/%y') : ""
his.tag!"received_date",val

val = !as.time_of_status(:article_submission_staged_for_cadmus).blank? ? as.time_of_status(:article_submission_staged_for_cadmus).strftime('%m/%d/%y') : ""
his.tag! "accepted_date",val  
end
end

def self.add_abstract(xml,as)
xml.abstract (as.abstract || "")
end

def self.add_class_info(xml,as)
xml.classinfo do |ci|    
ci.tag! "manuscript-type",(as.man_type || "")   
ci.tag! "manuscript-section",as.section_header
end
end



def self.add_digital_info(xml,as)
xml.digitalinfo do |di|
unless as.isVideo?
di.tag!("text-file",{"type"=>'word',"decription"=>"Full text of paper","originalname"=>"#{@man_file}"},@man_file)

end
@figures.each do |f| 
file_type = f.sub(/(\w+|\s+|-)*/,"")
di.tag!("figure",{"type"=>file_type,"description"=>"","originalname"=>f},f)
end
end

end



end

