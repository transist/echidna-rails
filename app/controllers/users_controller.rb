class UsersController < ApplicationController
  before_filter :authenticate_user!

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def add_stopword
    current_user.add_stopword params[:word]
    render json: {}
  end
end
