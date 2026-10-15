class Counterparty < ApplicationRecord
  include HasIban

  has_many :transactions, dependent: :restrict_with_error

  validates :name, presence: true
  validates :name, uniqueness: {conditions: -> { where(iban: nil) }}, if: -> { iban.nil? }
  validates :iban, uniqueness: true, allow_nil: true

  # Mirrors the uniqueness rules above, so lookups never pick a record the validations would treat as different.
  def self.identity(name:, iban:)
    iban = normalize_value_for(:iban, iban)
    iban ? {iban:} : {iban: nil, name:}
  end
end
