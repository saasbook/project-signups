class AdminController < ApplicationController
  before_filter :authenticate_admin!

  def index
    @settings = AdminSetting.first || AdminSetting.new
    @iterations = Iteration.all
    @iteration = Iteration.new
    @max_project_preferences = @settings.max_project_preferences || 5
  end

  def update
    @settings = AdminSetting.first || AdminSetting.new
    @settings.max_project_preferences = params[:max_project_preferences]
    if @settings.save
      flash[:notice] = "Preferences saved!"
    else
      flash[:error] = "Could not save preferences"
    end



    redirect_to admin_path and return
  end

  def update_team_evaluation
    evaluation_id = params[:evaluation_id]
    @evaluation = TeamEvaluation.find_by_id(evaluation_id)
    render :nothing => true and return if @evaluation.nil?

    @score = params[:score]

    @evaluation.score = @score
    if @evaluation.save
      @message = "Evaluation score updated!"
      @success = true
    else
      @message = "Please enter a valid score (0-10)"
      @success = false
    end
  end

  def email_team_evaluations
    @iteration = Iteration.find_by_id(params[:iteration_id])
    @group = Group.find_by_id(params[:group_id])
    if @iteration.present?
      if @group.blank?
        TeamEvaluation.send_all_team_evaluations(@iteration.id)
        @message = "Sent all team evaluations for #{@iteration.name}"
      else
        TeamEvaluation.send_group_team_evaluations(@iteration.id, @group.id)
        @message = "Sent group #{@group.id} evaluations for #{@iteration.name}"
      end
      @success = true
    else
      @success = false
      @message = "Cannot send team evaluations for nonexistent iteration"
    end
  end

  def show_iteration_evaluations
    if request.xhr?
      iteration_id  = params[:iteration_id]
      @iteration = Iteration.find_by_id(iteration_id)
      render :nothing => true and return if @iteration.nil?

      includes_clause = [:grader, :gradee, :group]
      @team_evaluations = TeamEvaluation.get_recent_evaluations(includes_clause, iteration_id, group_id = nil, ignore_delivered = true)

      @team_evaluations_for_group_hash = @team_evaluations.group_by { |evaluation| evaluation.group_id }

      @team_evaluations_for_group_hash.each_pair do |group_id, evaluations|
        # index each one by recipient and grader. ezpz
        @team_evaluations_for_group_hash[group_id] = evaluations.index_by { |evaluation| [evaluation.gradee_id, evaluation.grader_id] }
      end
      @team_evaluations_for_group_hash = Hash[@team_evaluations_for_group_hash.sort]

      @students_for_group_hash = Student.all.group_by {|student| student.group_id}
    else
      @iteration_select_options = Iteration.get_iteration_select_options
    end

  end


  def delete_iteration
    @iteration = Iteration.find_by_id(params[:iteration_id])
    render :nothing => true and return if @iteration.nil?
    @iteration.destroy
  end

end
