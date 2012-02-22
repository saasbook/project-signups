class ProjectPreferencesController < ApplicationController
  before_filter :authorize!

  # GET /project_preferences
  # GET /project_preferences.json
  def index
    @project_preferences = ProjectPreference.order('group_id ASC')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @project_preferences }
    end
  end

  # GET /project_preferences/1
  # GET /project_preferences/1.json
  def show
    @project_preference = ProjectPreference.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @project_preference }
    end
  end

  # GET /project_preferences/new
  # GET /project_preferences/new.json
  def new
    @project_preference = ProjectPreference.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @project_preference }
    end
  end

  # GET /project_preferences/1/edit
  def edit
    @project_preference = ProjectPreference.find(params[:id])
  end

  # POST /project_preferences
  # POST /project_preferences.json
  def create
    @project_preference = ProjectPreference.new(params[:project_preference])

    respond_to do |format|
      if @project_preference.save
        format.html { redirect_to @project_preference, notice: 'Project preference was successfully created.' }
        format.json { render json: @project_preference, status: :created, location: @project_preference }
      else
        format.html { render action: "new" }
        format.json { render json: @project_preference.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /project_preferences/1
  # PUT /project_preferences/1.json
  def update
    @project_preference = ProjectPreference.find(params[:id])

    respond_to do |format|
      if @project_preference.update_attributes(params[:project_preference])
        format.html { redirect_to @project_preference, notice: 'Project preference was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @project_preference.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /project_preferences/1
  # DELETE /project_preferences/1.json
  def destroy
    @project_preference = ProjectPreference.find(params[:id])
    @project_preference.destroy

    respond_to do |format|
      format.html { redirect_to project_preferences_url }
      format.json { head :ok }
    end
  end
end
