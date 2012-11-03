class TeamEvaluationsController < ApplicationController
  def index
    @iteration_select_options = Iteration.get_iteration_select_options
    @group_select_options     = Group.get_group_select_options
  end


  def create
    @group = Group.find_by_id(params[:group_id])
    @iteration = Iteration.find_by_id(params[:iteration_id])
    @grader = Student.find_by_id(params[:grader_id])

    @message = TeamEvaluation.validate_evaluation(@group, @iteration, @grader)
    render "error" and return if @message != "success"

    @team_evaluations = TeamEvaluation.parse_and_create_team_evaluations(@group, @iteration, @grader, params)
    if @team_evaluations.nil?
      @message = "There was something wrong with your evaluation. Please refresh and try again"
      render "error" and return
    else
      @message = "Evaluation submitted"
    end
  end

  def new
    @group = Group.find_by_id(params[:group_id])
    if @group.nil?
      @message = "Please select a valid group"
      render "error" and return
    end

    @iteration = Iteration.find_by_id(params[:iteration_id])
    if @iteration.nil?
      @message = "Please select a valid iteration"
      render "error" and return
    end

    # assume no grader is selected
    @grader_selected = false
    grader_id = params[:grader_id]
    @grader = Student.find_by_id(grader_id)
    @grader_selected = true if @grader.present?

    if @grader_selected
      # render form for rest of group
      @other_group_students = @group.students.find(:all, :conditions => ["id != ?", grader_id], :order => "id asc")
    else
      # render just grader name select options
      @grader_select_options = @group.get_all_students_select_options
    end
  end

end
