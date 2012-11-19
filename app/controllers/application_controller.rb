class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :check_authorization
  # before_filter :prepare_for_mobile
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


  private
    def mobile_device?
      request.user_agent =~ /Mobile|webOS/
    end

    def prepare_for_mobile
      request.format = :mobile if mobile_device?
    end
end
