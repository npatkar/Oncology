class UserSubjectController < ApplicationController
  
  
def index
  
  
  
end


def list  
  @user = User.find(params[:id])
  @is_editor = params[:role] == "editor"
  respond_to do |format|
     # format.html {render :partial=>'subjects'}
      format.js {render :partial=>"subjects"}
   end 
end
  

def update     
     @user = User.find(params[:id])
     @is_editor = params[:role] == "editor"
     @user.save_subjects(params[:article_section_ids]||[],params[:role])
     respond_to do |format|
        format.html # show.html.erb
        format.js
     end
end


  
end
