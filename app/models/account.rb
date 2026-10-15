class Account < ApplicationRecord
  IBAN_FORMAT = /\A[A-Z]{2}\d{2}[A-Z0-9]{11,30}\z/

  has_many :transactions, dependent: :restrict_with_error
  has_many :balances, dependent: :restrict_with_error

  normalizes :iban, with: ->(iban) { iban.delete(" ").upcase }

  validates :name, presence: true
  validates :iban, presence: true, uniqueness: true
  validate :iban_must_be_valid

  private

  def iban_must_be_valid
    return if iban.blank?

    errors.add(:iban, :invalid) unless IBAN_FORMAT.match?(iban) && iban_checksum_valid?
  end

  # ISO 13616: move the country code and check digits to the end, turn letters into 10..35, and the result mod 97 is 1.
  def iban_checksum_valid?
    (iban[4..] + iban[0, 4]).gsub(/[A-Z]/) { (it.ord - 55).to_s }.to_i % 97 == 1
  end
end
