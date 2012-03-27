class PdfsController < ApplicationController

  before_filter :must_be_admin

  def get_pdf
    pdf = Pdf.find(params[:id])
    sendfile_via_litespeed(pdf.path)
    add_audit_trail(:details => "Downloading a pdf: #{pdf.file}")
  end

  def destroy
    if Pdf.destroy(params[:id])
      render :update do |page|
        page["pdf_#{params[:id]}"].up('li').remove
      end
      add_audit_trail(:details => "Deleted a pdf: #{pdf.file}")
    else
      respond_to do |format|
        flash[:error] = "Couldn't delete the pdf"
        format.html { redirect_to(:action => :show, :id => params[:id]) }
        format.xml { render :status => 400 }
      end
      add_audit_trail(:details => "Unsuccessfully tried to delete a pdf: #{pdf.file}")
    end
  end
end
