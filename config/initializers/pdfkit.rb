PDFKit.configure do |config|       
  
  
     config.wkhtmltopdf = Rails.root.join('bin', 'wkhtmltopdf-i386').to_s  
  
  
end
