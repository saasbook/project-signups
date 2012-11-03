class AdminController < ApplicationController
  before_filter :authenticate_admin!

  def index
    if request.xhr?
      filters = { :iteration_id => params[:iteration_id] }
      @grouped_team_evaluations = TeamEvaluation.grouped_team_evaluations(filters)
    else
      @settings = AdminSetting.first || AdminSetting.new
      @max_project_preferences = @settings.max_project_preferences || 5
      @grouped_team_evaluations = TeamEvaluation.grouped_team_evaluations
      @iteration_select_options = Iteration.get_iteration_select_options
    end
  end

  def update
    @settings = AdminSetting.first || AdminSetting.new
    @settings.max_project_preferences = params[:admin_setting][:max_project_preferences]
    if @settings.save
      flash[:notice] = "Preferences saved!"
    else
      flash[:error] = "Could not save preferences"
    end

    redirect_to admin_path and return
  end

  def update_team_evaluation
    team_evaluation_id = params[:team_evaluation_id]
    @team_evaluation = TeamEvaluation.find_by_id(team_evaluation_id)
    render :nothing => true and return if @team_evaluation.nil?

    @score = params[:score]

    @team_evaluation.score = @score
    if @team_evaluation.save
      @message = "Evaluation score updated!"
      @success = true
    else
      @message = "Please enter a valid score (0-10)"
      @success = false
    end
  end

end
