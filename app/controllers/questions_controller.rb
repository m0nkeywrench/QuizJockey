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

  def edit
    @course = Course.find(params[:course_id])
    @question = Question.find(params[:id])
  end

  def update
    @course = Course.find(params[:course_id])
    @question = Question.find(params[:id])
    if @question.update(question_params)
      redirect_to action: :new
    else
      render action: :edit
    end
  end

  def destroy
    question = Question.find(params[:id])
    question.destroy
    redirect_to new_course_question_path(course_id: params[:course_id])
  end
  
  private
  def question_params
    params.require(:question).permit(:sentence, :answer, :wrong1, :wrong2, :wrong3, :commentary).merge(course_id: params[:course_id])
  end
end
