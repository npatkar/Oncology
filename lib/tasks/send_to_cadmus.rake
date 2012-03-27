task :build_zip_file  => :environment  do
#as = ArticleSubmission.find(515)
Rails.logger.info "In rake task *************asdfsafd*****************************8"
as = ArticleSubmission.find(ENV['id'])
Rails.logger.info "In rake task ******************************************8"
p "about to run"
FileSender.create_zip_file(as)
p "finished"
end


task :get_submission => :environment do
  @as = ArticleSubmission.find(515)  
end

task :all=>[:get_submission,:build_zip_file]