class QuestionsController < ApplicationController

  def index
  end

  def new
    @question = Question.new
  end

  def create
  end
  
end
