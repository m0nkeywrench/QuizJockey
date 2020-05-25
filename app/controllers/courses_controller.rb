class CoursesController < ApplicationController
  
  before_action :set_course, only: [:show, :edit, :update]
  
  def index
    @courses = Course.includes(:questions, :user)
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
  end

  private
  def course_params
    params.require(:course).permit(:name, :description, :private).merge(user_id: current_user.id)
  end

  def set_course
    @course = Course.find(params[:id])
  end
end
