class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  # has_secure_password skips blank passwords and a missing confirmation on update, which would turn a reset into a no-op.
  validates :password, :password_confirmation, presence: true, on: :password_reset

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
