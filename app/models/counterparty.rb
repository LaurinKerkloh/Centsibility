class Counterparty < ApplicationRecord
  has_many :transactions, dependent: :restrict_with_error

  validates :name, presence: true
  validates :name, uniqueness: {conditions: -> { where(iban: nil) }}, if: -> { iban.nil? }
  validates :iban, uniqueness: true, allow_nil: true
end
