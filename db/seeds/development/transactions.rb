# Enough history to page through the transaction list. A fixed seed keeps it the same on every reset.
random = Random.new(42)
payees = {
  counterparties.rewe => ["VISA Debitkartenumsatz", -80..-2],
  counterparties.insurance => ["Haftpflicht Vertrag 1234567", -15..-5],
  counterparties.dkb => ["Rechnung Entgelt", -5..-1],
  counterparties.savings => ["Sparen", -300..-50],
  counterparties.employer => ["GEHALT", 1800..2100]
}

transactions.with account: accounts.girokonto do |transactions|
  200.times do |index|
    counterparty, (reference, range) = payees.to_a.sample(random:)
    booked_on = Date.current - random.rand(365)
    amount = BigDecimal(random.rand(range).to_s) + BigDecimal(random.rand(100)) / 100

    transactions.create counterparty:, booked_on:, value_on: booked_on, amount:, reference: "#{reference} #{index}",
      raw_row: "seed-#{index}"
  end
end
