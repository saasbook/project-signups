class SignupsController < ApplicationController
  def new
    @groups = Group.all
    @projects = Project.all
  end
end
