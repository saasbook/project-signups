class StudentsController < ApplicationController
  before_filter :authenticate_admin!

  # GET /students
  # GET /students.json
  def index
    @students = Student.find(:all, :include => [:received_team_evaluations, :group], :order => "group_id asc")
    @iterations = Iteration.find(:all, :order => "due_date asc")
    @students_for_group_hash = @students.group_by { |student| student.group_id }

    team_evaluations = TeamEvaluation.get_recent_evaluations([:grader])

    @evaluations_for_gradee_hash = TeamEvaluation.get_evaluations_for_gradee_hash(team_evaluations)
    @all_evaluations_delivered_for_group_hash = TeamEvaluation.get_evaluations_delivered_for_group_hash(team_evaluations, @students_for_group_hash)

    respond_to do |format|
      format.html { render :layout => "students" } # index.html.erb
      format.json { render json: @students }
    end
  end

  # GET /students/1
  # GET /students/1.json
  def show
    @student = Student.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @student }
    end
  end

  # GET /students/new
  # GET /students/new.json
  def new
    @student = Student.new
    @groups = Group.order('id ASC')

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @student }
    end
  end

  # GET /students/1/edit
  def edit
    @student = Student.find(params[:id])
    @groups = Group.order('id ASC')
  end

  # POST /students
  # POST /students.json
  def create
    @student = Student.new(params[:student])

    respond_to do |format|
      if @student.save
        format.html { redirect_to @student, notice: 'Student was successfully created.' }
        format.json { render json: @student, status: :created, location: @student }
      else
        format.html { render action: "new" }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /students/1
  # PUT /students/1.json
  def update
    @student = Student.find(params[:id])

    respond_to do |format|
      if @student.update_attributes(params[:student])
        format.html { redirect_to @student, notice: 'Student was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /students/1
  # DELETE /students/1.json
  def destroy
    @student = Student.find(params[:id])
    @student.destroy

    respond_to do |format|
      format.html { redirect_to students_url }
      format.json { head :ok }
    end
  end
end
