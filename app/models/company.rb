class Company < ApplicationRecord
  validates :company, presence: true, uniqueness: true
end
