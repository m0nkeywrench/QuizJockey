class QuestionsController < ApplicationController
  before_action :move_to_login, except: :index
  before_action :set_course, only: [:index, :new, :create, :edit, :update, :destroy]
  before_action :move_to_course_detail, except: :index

  def index
    @questions = @course.questions
  end

  def new
    @question = Question.new
  end

  def create
    @question = Question.new(question_params)
    if @question.save
      redirect_to action: :new
    else
      render action: :new
    end
  end

  def edit
    @question = Question.find(params[:id])
    @questions = @course.questions
  end

  def update
    @question = Question.find(params[:id])
    if @question.update(question_params)
      redirect_to action: :new
    else
      render action: :edit
    end
  end

  def destroy
    Question.find(params[:id]).destroy
    redirect_to new_course_question_path(course_id: params[:course_id]), notice: "削除しました"
  end

  private

  def question_params
    params.require(:question).permit(:sentence, :answer, :wrong1, :wrong2, :wrong3, :commentary).merge(course_id: params[:course_id])
  end

  def move_to_login
    redirect_to new_user_session_path unless user_signed_in?
  end

  def set_course
    @course = Course.find(params[:course_id])
  end

  def move_to_course_detail
    redirect_to course_path(@course.id) unless @course.user_id == current_user.id
  end
end
