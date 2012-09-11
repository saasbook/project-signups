class AdminSettingsController < ApplicationController
  before_filter :authenticate_admin!
  
  def index
    @settings = AdminSetting.first || AdminSetting.new
    @max_project_preferences = @settings.max_project_preferences || 5
  end
  
  def update
    @settings = AdminSetting.first || AdminSetting.new
    @settings.max_project_preferences = params[:admin_setting][:max_project_preferences]
    if @settings.save
      flash[:notice] = "Preferences saved!"
    else
      flash[:error] = "Could not save preferences"
    end
    
    redirect_to admin_settings_path and return
  end
  
end
