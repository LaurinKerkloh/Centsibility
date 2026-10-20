categories.create :income, name: "Income", color: "green"
categories.create :living, name: "Living", color: "orange"
categories.create :food, name: "Food", color: "lime"
categories.create :mobility, name: "Mobility", color: "blue"
categories.create :insurance, name: "Insurance", color: "teal"
categories.create :health, name: "Health", color: "red"
categories.create :leisure, name: "Leisure", color: "violet"
categories.create :shopping, name: "Shopping", color: "pink"
categories.create :finance, name: "Finance", color: "gray"
categories.create :savings, name: "Savings", color: "cyan"
categories.create :gifts_and_donations, name: "Gifts & donations", color: "amber"

{
  income: {salary: "Salary", interest: "Interest", refunds: "Refunds"},
  living: {rent: "Rent", utilities: "Utilities", internet_and_phone: "Internet & phone", household: "Household"},
  food: {groceries: "Groceries", restaurants: "Restaurants"},
  mobility: {public_transport: "Public transport", car: "Car", bike: "Bike"},
  insurance: {liability: "Liability", health_insurance: "Health insurance"},
  health: {pharmacy: "Pharmacy", doctor: "Doctor"},
  leisure: {hobbies: "Hobbies", travel: "Travel", subscriptions: "Subscriptions"},
  shopping: {clothing: "Clothing", electronics: "Electronics"},
  finance: {bank_fees: "Bank fees", taxes: "Taxes"}
}.each do |parent, subcategories|
  categories.with parent: categories.public_send(parent) do |categories|
    subcategories.each { |label, name| categories.create label, name: }
  end
end
