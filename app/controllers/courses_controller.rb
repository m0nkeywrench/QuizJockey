class CoursesController < ApplicationController
  
  def index
    @courses = Course.includes(:questions)
  end

  def new
    @course = Course.new
  end

  def show
    @course = Course.find(params[:id])
  end

  def create
    course = Course.create(course_params)
    redirect_to new_course_question_path(course_id: course.id)
  end

  private
  def course_params
    params.require(:course).permit(:name, :description, :private).merge(user_id: current_user.id)
  end
end
