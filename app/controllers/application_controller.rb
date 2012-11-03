class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :check_authorization
  layout "application"

  protected

  def check_authorization
    @authorized ||= admin_signed_in?
  end

  def authorize!
    if !admin_signed_in?
      flash[:error] = "You do not have permission to access this page"
      redirect_to :root and return false
    end
  end
end
