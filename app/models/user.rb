class User < ApplicationRecord
  include UserAuthenticator

  def issue_access_token
    self.access_token = SecureRandom.hex(32)
    self.access_token_expire_date = 30.minutes.from_now
    save!
  end
end
