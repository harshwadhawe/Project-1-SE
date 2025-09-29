class User < ApplicationRecord
  before_validation { self.email = email.to_s.strip.downcase }
  validates :name, presence: true
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    'valid_email_2/email': true

  has_many :builds, dependent: :nullify
end
