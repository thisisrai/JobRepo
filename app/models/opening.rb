class Opening < ApplicationRecord
  validates :job_url, presence: true, uniqueness: true

end
