class HomeController < ApplicationController

  def index
    if current_user
      redirect_to :controller => 'manuscripts'
    end
  end
  
end
