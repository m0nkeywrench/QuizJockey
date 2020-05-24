class UsersController < ApplicationController
  def show
    @courses = current_user.courses.includes(:questions)
  end
end
