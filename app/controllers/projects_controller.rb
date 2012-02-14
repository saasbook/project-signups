class ProjectsController < ApplicationController
  before_filter :authorize!, :except => [:index, :show]

  # GET /projects
  # GET /projects.json
  def index
    @projects = Project.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @projects }
    end
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    @project = Project.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @project }
    end
  end

  # GET /projects/new
  # GET /projects/new.json
  def new
    @project = Project.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @project }
    end
  end

  # GET /projects/1/edit
  def edit
    @project = Project.find(params[:id])
    if @project.private
      @group_id = @project.group ? @project.group.id : ''
    end
  end

  # POST /projects
  # POST /projects.json
  def create
    @group_id = params[:group_id]
    @project = Project.new(params[:project])
    success = @project.save
    if params[:project][:private]
      success &&= SelfProject.create!(:project => @project, :group_id => @group_id)
    end

    respond_to do |format|
      if success
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render json: @project, status: :created, location: @project }
      else
        format.html { render action: "new" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.json
  def update
    @group_id = params[:group_id]
    @project = Project.find(params[:id])
    success = @project.update_attributes(params[:project])
    if params[:project][:private]
      success &&= SelfProject.create!(:project => @project, :group_id => @group_id)
    end

    respond_to do |format|
      if success
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project = Project.find(params[:id])
    @project.destroy

    respond_to do |format|
      format.html { redirect_to projects_url }
      format.json { head :ok }
    end
  end

  def bulk_import
  end

  def bulk_create
    json = params[:content]
    projects = JSON.parse(json)
    projects.each do |project|
      Project.create!(project) unless Project.find_by_id(project['id'])
    end
    flash[:notice] = "Success"
    redirect_to action: 'bulk_import'
  end
end
