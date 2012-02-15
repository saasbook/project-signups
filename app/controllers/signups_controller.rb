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
        choices = [nil, first_choice, second_choice, third_choice]
        1.upto(3).each do |i|
          @proj_pref = ProjectPreference.find_by_group_id_and_level(group_id, i)
          if @proj_pref
            @proj_pref.update_attributes!(:project_id => choices[i])
          else
            ProjectPreference.create!(:group_id => group_id, :level => i, :project_id => choices[i])
          end
        end
      end

      flash[:notice] = "Successfully submitted project preferences"
      redirect_to action: 'new'
    rescue Exception => e
      flash[:error] = "Error saving preferences: #{e}"
      redirect_to action: 'new'
    end
  end
end
