class Account < ApplicationRecord
  include HasIban

  has_many :transactions, dependent: :restrict_with_error
  has_many :balances, dependent: :restrict_with_error

  validates :name, presence: true
  validates :iban, presence: true, uniqueness: true
end
