require 'rails_helper'

RSpec.describe StoriesController, type: :controller do
  # Mock valid story content in JSON format
  let(:valid_story_content) do
    {
      content: {
        author: "Kavin",
        title: "The Great Michael Jordan",
        paragraphs: [
          "Michael Jordan was denied from JV.",
          "He cried, but he didn't give up.",
          "So he practiced."
        ]
      }
    }
  end

  # Create some stories for testing index action
  let!(:story1) { Story.create(content: { author: "Author 1", title: "Title 1", paragraphs: ["Paragraph 1"] }) }
  let!(:story2) { Story.create(content: { author: "Author 2", title: "Title 2", paragraphs: ["Paragraph 2"] }) }

  # Test the `index` action
  describe "GET /stories" do
    before do
      allow(controller).to receive(:authorized).and_return(true)
    end

    it "returns all stories with a 200 status" do
      get :index
      expect(response).to have_http_status(:ok)
      stories = JSON.parse(response.body)
      expect(stories.length).to eq(2)
      expect(stories[1]["content"]["author"]).to eq("Author 1")
      expect(stories[0]["content"]["author"]).to eq("Author 2")
    end
  end

  # Test the `create` action
  describe "POST /stories" do
    before do
      allow(controller).to receive(:authorized).and_return(true)
    end

    context "with valid attributes" do
      it "creates a new story and returns a 201 status" do
        expect {
          post :create, params: { story: valid_story_content }
        }.to change(Story, :count).by(1)
        
        expect(response).to have_http_status(:created)
        created_story = JSON.parse(response.body)
        expect(created_story["content"]["author"]).to eq("Kavin")
        expect(created_story["content"]["title"]).to eq("The Great Michael Jordan")
        expect(created_story["content"]["paragraphs"].length).to eq(3)
      end
    end
  end
end
