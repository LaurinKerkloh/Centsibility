module StatementHelpers
  def entry(raw_row, counterparty_name: "Bäckerei", counterparty_iban: nil, amount: "-3.5")
    Parsers::Entry.new(booked_on: Date.new(2026, 10, 15), value_on: Date.new(2026, 10, 15), amount: BigDecimal(amount),
      counterparty_name:, counterparty_iban:, reference: "Brötchen", creditor_id: nil, mandate_reference: nil,
      customer_reference: nil, raw_row:)
  end

  def statement(*entries, iban: accounts.girokonto.iban, balance: "100", balance_on: Date.new(2026, 10, 15))
    Parsers::Statement.new(account_iban: iban, account_type: "Tagesgeld", balance: BigDecimal(balance), balance_on:, entries:)
  end
end

RSpec.configure do |config|
  config.include StatementHelpers, type: :model
end
