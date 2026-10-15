class Import < ApplicationRecord
  belongs_to :account

  has_many :transactions
  has_many :balances
  has_many :counterparties

  validates :filename, presence: true
  validates :skipped_count, numericality: {only_integer: true, greater_than_or_equal_to: 0}
end
