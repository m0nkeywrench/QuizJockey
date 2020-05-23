class QuestionsController < ApplicationController

  def index
    @course = Course.find(params[:course_id])
    @questions = @course.questions
  end

  def new
    @course = Course.find(params[:course_id])
    @question = Question.new
  end

  def create
    @question = Question.new(question_params)
    @course = Course.find(params[:course_id])
    if @question.save
      redirect_to action: :new
    else
      render action: :new
    end
  end
  
  private
  def question_params
    params.require(:question).permit(:sentence, :answer, :wrong1, :wrong2, :wrong3, :commentary).merge(course_id: params[:course_id])
  end
end
