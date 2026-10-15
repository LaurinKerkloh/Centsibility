class Transaction < ApplicationRecord
  belongs_to :account
  belongs_to :counterparty, optional: true

  validates :booked_on, :value_on, :raw_row, presence: true
  validates :amount, numericality: true
end
