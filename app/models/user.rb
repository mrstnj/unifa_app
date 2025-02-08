class User < ApplicationRecord
  include UserAuthenticator

  validates :login, uniqueness: true, presence: true
  validates :password, presence: true, on: :create, length: { in: 8..100 }, format: { with: /\A(?=.*?[a-z])(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[!@#\$%\^&\*])[a-zA-Z0-9!@#\$%\^&\*]+\z/ }

  def issue_access_token
    self.access_token = SecureRandom.hex(32)
    self.access_token_expire_date = 30.minutes.from_now
    save!
  end
end
