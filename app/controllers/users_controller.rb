class UsersController < ApplicationController
  before_action :move_to_login, only: [:show, :profile_edit, :profile_update]
  before_action :set_user, only: [:profile_edit, :profile_update]

  def show
    @courses = current_user.courses.includes(:questions)
  end

  def profile_edit; end

  def profile_update
    if @user.update(user_params)
      redirect_to user_path(id: current_user.id), notice: "ユーザー情報を編集しました"
    else
      render action: :profile_edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :nickname)
  end

  def move_to_login
    redirect_to new_user_session_path unless user_signed_in?
  end

  def set_user
    @user = current_user
  end
end
