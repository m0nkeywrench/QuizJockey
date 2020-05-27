class UsersController < ApplicationController

  def show
    @courses = current_user.courses.includes(:questions)
  end

  def profile_edit
    @user = User.find(params[:id])
  end

  def profile_update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to user_path(id: current_user.id)
    else
      render action: :profile_edit
    end
  end

  private
  def user_params
    params.require(:user).permit(:name, :nickname)
  end
end
