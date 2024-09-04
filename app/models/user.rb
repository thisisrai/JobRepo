class User < ApplicationRecord
  has_secure_password
  has_many :jobs, dependent: :destroy

  validates :username, presence: true, uniqueness: true

  # Generates a unique token for password reset
  def generate_password_reset_token!
    self.reset_password_token = SecureRandom.urlsafe_base64
    self.reset_password_sent_at = Time.current
    save!
  end

  # Checks if the password reset token is still valid (e.g., within 2 hours)
  def reset_password_period_valid?
    reset_password_sent_at && reset_password_sent_at > 2.hours.ago
  end

  # Clears the password reset token after a successful password reset
  def clear_password_reset_token!
    update(reset_password_token: nil, reset_password_sent_at: nil)
  end
end
