class Transaction < ApplicationRecord
  belongs_to :account
  belongs_to :counterparty, optional: true
  belongs_to :import, optional: true

  validates :booked_on, :value_on, :raw_row, presence: true
  validates :amount, numericality: true

  scope :income, -> { where.not(amount: ..0) }
  scope :spending, -> { where(amount: ...0) }
end
