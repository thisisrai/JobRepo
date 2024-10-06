require "rails_helper"

RSpec.describe Story, type: :model do
  # Create a valid story with jsonb content
  let(:valid_content) do
    {
      "title" => "A Great Tale",
      "body" => "Once upon a time...",
      "author" => "John Doe"
    }
  end

  # Create an invalid story with non-JSON content (for validation testing)
  let(:invalid_content) { "This is not valid JSON" }

  # Validation tests
  describe 'validations' do
    it 'is valid with valid JSON content' do
      story = Story.new(content: valid_content)
      expect(story).to be_valid
    end

    it 'is invalid without content' do
      story = Story.new(content: nil)
      expect(story).not_to be_valid
    end

    it 'is invalid with non-JSON content' do
      story = Story.new(content: invalid_content)
      expect(story).not_to be_valid
    end
  end

  # Additional tests for jsonb behavior (optional)
  describe 'jsonb field content' do
    it 'stores JSON data correctly' do
      story = Story.create!(content: valid_content)
      expect(story.content).to eq(valid_content)
    end

    it 'allows access to JSON fields' do
      story = Story.create!(content: valid_content)
      expect(story.content['title']).to eq("A Great Tale")
    end
  end
end
