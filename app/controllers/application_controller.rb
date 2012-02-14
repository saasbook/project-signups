class ApplicationController < ActionController::Base
  protect_from_forgery

  protected

  def check_authorization
    @authorized ||= session[:passwd] == "password"
  end

  def authorize!
    if session[:passwd] != "password"
      flash[:error] = "You do not have permission to access this page"
      redirect_to :root and return false
    end
  end
end
