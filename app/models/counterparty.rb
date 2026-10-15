class Counterparty < ApplicationRecord
  include HasIban

  has_many :transactions, dependent: :restrict_with_error

  validates :name, presence: true
  validates :name, uniqueness: {conditions: -> { where(iban: nil) }}, if: -> { iban.nil? }
  validates :iban, uniqueness: true, allow_nil: true

  # The attributes that identify a counterparty, matching the uniqueness rules above.
  def self.identity(name:, iban:)
    iban = normalize_value_for(:iban, iban)
    iban ? {iban:} : {iban: nil, name:}
  end
end
