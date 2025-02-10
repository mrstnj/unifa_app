class User < ApplicationRecord
  include UserAuthenticator

  validates :login, uniqueness: true, presence: true
  validates :password, presence: true, on: :create, length: { in: 8..100 }, format: { with: /\A(?=.*?[a-z])(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[!@#\$%\^&\*])[a-zA-Z0-9!@#\$%\^&\*]+\z/ }

  def issue_access_token
    self.access_token = SecureRandom.hex(32)
    self.access_token_expire_date = 30.minutes.from_now
    save!
  end

  def self.authenticate_with_lock(login, password)
    user = authenticate(login, password) do |user|
      user.lock_check
      user.update_columns(lock_count: user.lock_count + 1, unlock_time: 30.minute.from_now)
    end
    if user.present?
      user.lock_check
      user.update_column(:lock_count, 0) unless user.lock_count == 0
    end
    return user
  end

  def lock_check
    self.update_column(:lock_count, 0) unless self.unlock_time.present? && self.unlock_time >= Time.now
    raise Exceptions::LockedError if self.lock_count >= 6
  end
end
