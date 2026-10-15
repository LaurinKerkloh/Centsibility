class Import < ApplicationRecord
  belongs_to :account

  has_many :transactions, dependent: :restrict_with_error
  has_many :balances, dependent: :restrict_with_error
  has_many :counterparties, dependent: :nullify

  validates :filename, presence: true
  validates :skipped_count, numericality: {only_integer: true, greater_than_or_equal_to: 0}
end
