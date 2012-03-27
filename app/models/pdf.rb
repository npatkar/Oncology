require 'aws/s3'

class Pdf < ActiveRecord::Base

  belongs_to :user
  belongs_to :coi_form, :dependent => :delete

  validates_presence_of :user_id
  validates_presence_of :form_type

  before_save :generate_file_name

  attr_accessor :html_src

  def path
    out = dir
    if self.new_record? || ! self.file?
      out += generate_file_name
    else
      out += self.file
    end
  end

  def abs_path
    @abs_path ||= RAILS_ROOT + '/public' + path
  end

  def dir
    @dir ||= '/pdfs/' + (self.user_id || 0).to_s + '/'
  end

  def abs_dir
    @abs_dir ||= RAILS_ROOT + '/public' + dir 
  end

  def generate(options = {})
    raise unless self.html_src && self.user_id

    @@html2psrc_config_src  ||= RAILS_ROOT + '/public/stylesheets/html2psrc'
    @@html2psrc_config      ||= RAILS_ROOT + '/public/stylesheets/html2ps.css'
    @@main_css_file         ||= RAILS_ROOT + '/public/stylesheets/main.css'
    @@pdf_override_css_file ||= RAILS_ROOT + '/public/stylesheets/pdf_override.css'

    # create the config file
    FileUtils.copy @@html2psrc_config_src, @@html2psrc_config
    File.open @@html2psrc_config, "w+" do |out_file|
  #    File.open @@main_css_file, "r" do |in_file|
  #      in_file.each_line {|line| out_file.write(line)}
  #    end
      File.open @@pdf_override_css_file, "r" do |in_file|
        in_file.each_line {|line| out_file.write(line)}
      end
    end

    # connect to s3
    connect_s3

    # generate the pdf file
    
    kit = PDFKit.new(html_src.force_encoding("UTF-8"))
    #kit = PDFKit.new("<h1>Hello<h1>")
    kit.stylesheets << @@html2psrc_config
    AWS::S3::S3Object.store(abs_path, kit.to_pdf, @s3_credentials[:bucket_name],:use_virtual_directories => true)
    logger.info("*** stored on s3 ***")
    logger.info(AWS::S3::Bucket.objects(@s3_credentials[:bucket_name]))
    self.save!
  end

private
  def generate_file_name
    self.form_type ||= 'unknown'    
    self.file ||= self.form_type.gsub(/|^-a-zA-Z0-9_.|/, '').gsub(/\.\./, '.') + '-' + Time.now.strftime("%Y%m%d-%H%M%S") + '.pdf'
  end
  def connect_s3
    @s3_credentials = parse_credentials("#{RAILS_ROOT}/config/amazon_s3.yml")
    logger.info("*** s3_credentials ***")
    logger.info(@s3_credentials[:access_key_id])
    AWS::S3::Base.establish_connection!(
    :access_key_id     => @s3_credentials[:access_key_id], 
    :secret_access_key => @s3_credentials[:secret_access_key]
    )
  end
  def parse_credentials creds
  logger.info("*** parse_credentials ***")
        creds = find_credentials(creds).stringify_keys
        (creds[Rails.env] || creds).symbolize_keys
  end
  def find_credentials creds
  logger.info("*** find_credentials ***")
        case creds
        when File
          YAML::load(ERB.new(File.read(creds.path)).result)
        when String, Pathname
          YAML::load(ERB.new(File.read(creds)).result)
        when Hash
          creds
        else
          raise ArgumentError, "Credentials are not a path, file, or hash."
        end
  end
  
end