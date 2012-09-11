class SignupsController < ApplicationController
  def new
    @groups = Group.all
    @projects = Project.all
    @preference_levels = 1.upto(AdminSetting.first.max_project_preferences)
    @choices = {}
  end

  def create
    @groups = Group.all
    @projects = Project.all
    @preference_levels = 1.upto(AdminSetting.first.max_project_preferences)

    @choices = params[:choice]
    group_id = params[:group_id]
    p @choices

    begin
      ProjectPreference.transaction do
        @choices.each_pair do |i, choice|
          raise "Cannot select blank project"  if choice.blank? # Don't do anything if choice is blank
          @proj_pref = ProjectPreference.find_by_group_id_and_level(group_id, i)
          if @proj_pref
            @proj_pref.update_attribute(:project_id, choice)
            @proj_pref.save(:validate => false)
          else
            @proj_pref = ProjectPreference.new(:group_id => group_id, :level => i, :project_id => choice)
            @proj_pref.save(:validate => false)
          end
        end
        ProjectPreference.where(:group_id => group_id).where("level NOT IN (?)", @choices.keys).each do |pp|
          pp.destroy
        end
        ProjectPreference.find_all_by_group_id(group_id).each do |pp|
          p pp
          pp.save!
        end
      end

      flash[:notice] = "Successfully submitted project preferences"
      redirect_to action: 'new'
    rescue Exception => e
      flash.now[:error] = "Error saving preferences: #{e}"
      render action: 'new'
    end
  end
end
