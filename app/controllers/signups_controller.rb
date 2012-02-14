class SignupsController < ApplicationController
  def new
    @groups = Group.all
    @projects = Project.all
  end

  def create
    group_id = params[:group_id]
    first_choice = params[:first_choice]
    second_choice = params[:second_choice]
    third_choice = params[:third_choice]

    begin
      ProjectPreference.transaction do
        ProjectPreference.create!(:group_id => group_id, :level => 1, :project_id => first_choice)
        ProjectPreference.create!(:group_id => group_id, :level => 2, :project_id => second_choice)
        ProjectPreference.create!(:group_id => group_id, :level => 3, :project_id => third_choice)
      end

      flash[:notice] = "Successfully submitted project preferences"
      redirect_to action: 'new'
    rescue Exception => e
      flash[:error] = "Error saving preferences: #{e}"
      redirect_to action: 'new'
    end
  end
end
