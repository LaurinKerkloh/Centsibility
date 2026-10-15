module Parsers
  Entry = Data.define(:booked_on, :value_on, :amount, :counterparty_name, :counterparty_iban,
    :reference, :creditor_id, :mandate_reference, :customer_reference, :raw_row)
end
