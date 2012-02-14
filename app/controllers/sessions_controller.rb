class SessionsController < ApplicationController
  def new
  end

  def create
    puts "YO"
    session[:passwd] = params[:passwd]
    flash[:notice] = "Login successful."
    redirect_to :root
  end

  def destroy
    session.delete(:passwd)
    flash[:notice] = "Logout successful."
    redirect_to :root
  end
end
