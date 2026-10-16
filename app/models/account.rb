class Account < ApplicationRecord
  include HasIban

  has_many :transactions, dependent: :restrict_with_error
  has_many :balances, dependent: :restrict_with_error
  has_many :imports, dependent: :restrict_with_error

  validates :name, presence: true
  validates :iban, presence: true, uniqueness: true

  # Balances are append-only, so the latest one for a date is the current one.
  def balance_on(date) = balances.where(recorded_on: date).order(:id).last

  def latest_balance = balances.order(:recorded_on, :id).last
end
