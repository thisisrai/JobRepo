class Story < ApplicationRecord
  validates :content, presence: true, json: true
end
