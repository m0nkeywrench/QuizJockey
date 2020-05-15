class QuestionsController < ApplicationController

  def index
    @questions = Course.find(params[:course_id]).questions
  end

  def new
    @course = Course.find(params[:course_id])
    @question = Question.new
  end

  def create
    Question.create(question_params)
    @course = Course.find(params[:course_id])
    redirect_to new_course_question_path(params[:course_id])
  end
  
  private
  def question_params
    params.require(:question).permit(:sentence, :answer, :wrong1, :wrong2, :wrong3, :commentary).merge(course_id: params[:course_id])
  end
end
