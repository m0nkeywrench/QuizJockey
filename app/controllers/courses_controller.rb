class CoursesController < ApplicationController
  
  def index
    @courses = Course.includes(:questions, :user)
  end

  def new
    @course = Course.new
  end

  def show
    @course = Course.find(params[:id])
  end

  def create
    @course = Course.new(course_params)
    if @course.save
      redirect_to new_course_question_path(course_id: @course.id)
    else
      render action: :new
    end
  end

  private
  def course_params
    params.require(:course).permit(:name, :description, :private).merge(user_id: current_user.id)
  end
end
