class StoriesController < ApplicationController
  before_action :authorized, only: [:create]

  # GET /stories
  def index
    @stories = Story.order(created_at: :desc).limit(10)
    render json: @stories, status: :ok
  end

  # POST /stories
  def create
    @story = Story.new(story_params)
    if @story.save
      render json: @story, status: :created
    else
      render json: @story.errors, status: :unprocessable_entity
    end
  end

  private

  def story_params
    params.require(:story).permit(content: [:author, :title, paragraphs: [], images: []])
  end

end
