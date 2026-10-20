# A year of history up to today, enough to page through the transaction list and to filter by most categories. The
# fixed seed keeps the mix of counterparties and amounts the same on every reset.
random = Random.new(42)

landlord = counterparties.create :landlord, name: "Hausverwaltung Beispiel GmbH"
utilities = counterparties.create :utilities, name: "Stadtwerke Musterstadt"
telecom = counterparties.create :telecom, name: "Muster Telekom AG"
streaming = counterparties.create :streaming, name: "Streamingdienst Beispiel"
transit = counterparties.create :transit, name: "Verkehrsverbund Musterstadt"
gym = counterparties.create :gym, name: "Fitnessstudio Muster"
pizzeria = counterparties.create :pizzeria, name: "Pizzeria Beispiel"
bakery = counterparties.create :bakery, name: "Bäckerei Muster"
pharmacy = counterparties.create :pharmacy, name: "Muster Apotheke"
fuel = counterparties.create :fuel, name: "Tankstelle Beispiel"
fashion = counterparties.create :fashion, name: "Modehaus Muster"
electronics = counterparties.create :electronics, name: "Elektronikmarkt Beispiel"
charity = counterparties.create :charity, name: "Hilfswerk Beispiel e.V."
paypal = counterparties.create :paypal, name: "PayPal Europe"
atm = counterparties.create :atm, name: "Geldautomat"

# Counterparty, category, reference, amount, day of the month.
monthly = [
  [counterparties.employer, categories.salary, "GEHALT", "1932.91", 28],
  [landlord, categories.rent, "Miete Wohnung 3. OG", "-850", 1],
  [utilities, categories.utilities, "Abschlag Strom und Gas", "-95", 3],
  [telecom, categories.internet_and_phone, "Internet und Mobilfunk", "-44.99", 5],
  [counterparties.insurance, categories.liability, "Haftpflicht Vertrag 1234567", "-6.9", 14],
  [streaming, categories.subscriptions, "Abo Premium", "-13.99", 15],
  [transit, categories.public_transport, "Deutschlandticket", "-58", 1],
  [gym, categories.hobbies, "Mitgliedsbeitrag", "-29.9", 1],
  [counterparties.savings, categories.savings, "Sparen", "-300", 29],
  [counterparties.dkb, categories.bank_fees, "Rechnung Entgelt", "-2.5", 2]
]

# Counterparty, category or nil for the uncategorised ones, reference, amount range.
everyday = [
  [counterparties.rewe, categories.groceries, "VISA Debitkartenumsatz", -80..-2],
  [bakery, categories.groceries, "VISA Debitkartenumsatz", -12..-2],
  [pizzeria, categories.restaurants, "VISA Debitkartenumsatz", -45..-12],
  [pharmacy, categories.pharmacy, "VISA Debitkartenumsatz", -30..-3],
  [fuel, categories.car, "VISA Debitkartenumsatz", -90..-40],
  [fashion, categories.clothing, "VISA Debitkartenumsatz", -120..-20],
  [electronics, categories.electronics, "VISA Debitkartenumsatz", -300..-15],
  [charity, categories.gifts_and_donations, "Spende", -50..-10],
  [paypal, nil, "PayPal Zahlung", -60..-5],
  [atm, nil, "Bargeldauszahlung", -200..-50]
]

transactions.with account: accounts.girokonto do |transactions|
  12.times do |months_ago|
    month = Date.current.beginning_of_month << months_ago

    monthly.each do |counterparty, category, reference, amount, day|
      booked_on = month.change(day: [day, month.end_of_month.day].min)
      next if booked_on > Date.current

      transactions.create counterparty:, category:, booked_on:, value_on: booked_on, amount:,
        reference: "#{reference} #{booked_on.strftime("%m/%Y")}", raw_row: "seed-#{reference}-#{booked_on}"
    end
  end

  200.times do |index|
    counterparty, category, reference, range = everyday.sample(random:)
    booked_on = Date.current - random.rand(365)
    amount = BigDecimal(random.rand(range).to_s) + BigDecimal(random.rand(100)) / 100

    transactions.create counterparty:, category:, booked_on:, value_on: booked_on, amount:,
      reference: "#{reference} #{index}", raw_row: "seed-#{index}"
  end
end
