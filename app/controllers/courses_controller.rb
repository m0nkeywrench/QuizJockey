class CoursesController < ApplicationController
  before_action :move_to_login, except: [:index, :show]
  before_action :set_course, only: [:show, :edit, :update]
  
  def index
    @courses = Course.get_course_list
  end

  def new
    @course = Course.new
  end

  def show
  end

  def create
    @course = Course.new(course_params)
    if @course.save
      redirect_to new_course_question_path(course_id: @course.id)
    else
      render action: :new
    end
  end

  def edit
  end

  def update
    if @course.update(course_params)
      redirect_to new_course_question_path(@course.id)
    else
      render action: :edit
    end
  end
  
  def destroy
    Course.find(params[:id]).destroy
    redirect_to user_path(current_user.id)
  end

  private
  def course_params
    params.require(:course).permit(:name, :description, :private).merge(user_id: current_user.id)
  end

  def move_to_login
    redirect_to new_user_session_path unless user_signed_in?
  end

  def set_course
    @course = Course.find(params[:id])
  end
end
