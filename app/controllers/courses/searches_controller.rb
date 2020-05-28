class Courses::SearchesController < ApplicationController

  def index
    @keyword = params[:keyword]
    @courses = Course.search(@keyword).paginate(params[:page])
  end
end
