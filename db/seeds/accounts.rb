girokonto = accounts.create :girokonto, name: "Girokonto", iban: "DE45120300001234567890", account_type: "Girokonto"

transactions.with account: girokonto do |transactions|
  transactions.create :savings_transfer, counterparty: counterparties.savings,
    booked_on: "2026-08-29", value_on: "2026-08-29", amount: "-300", reference: "Sparen",
    raw_row: '"29.08.26";"29.08.26";"Gebucht";"Erika Mustermann und Max Mustermann";"Erika Mustermann und Max Mustermann";"Sparen";"Ausgang";"DE18120300001234567891";"-300";"";"";""'
  transactions.create :salary, counterparty: counterparties.employer,
    booked_on: "2026-09-29", value_on: "2026-09-29", amount: "1932.91", reference: "GEHALT 9/26",
    customer_reference: "KKKKKKKKKKKKKKKKKKKKK2",
    raw_row: '"29.09.26";"29.09.26";"Gebucht";"Beispiel Software GmbH";"MAX MUSTERMANN";"GEHALT 9/26";"Eingang";"DE31100700000004455667";"1932,91";"";"";"KKKKKKKKKKKKKKKKKKKKK2"'
  transactions.create :account_fee, counterparty: counterparties.dkb,
    booked_on: "2026-10-02", value_on: "2026-10-02", amount: "-2.5",
    reference: "Rechnung Entgelt für Zusatzkonto 20261002-BY111-00000000003",
    raw_row: '"02.10.26";"02.10.26";"Gebucht";"DKB AG";"DKB AG";"Rechnung Entgelt für Zusatzkonto 20261002-BY111-00000000003";"Ausgang";"0000000000";"-2,5";"";"";""'
  transactions.create :card_payment, counterparty: counterparties.rewe,
    booked_on: "2026-10-05", value_on: "2026-10-05", amount: "-1.04", reference: "VISA Debitkartenumsatz vom 04.10.2026",
    customer_reference: "400000000000020",
    raw_row: '"05.10.26";"05.10.26";"Gebucht";"ISSUER";"REWE";"VISA Debitkartenumsatz vom 04.10.2026";"Ausgang";"DE96120300009005290904";"-1,04";"";"";"400000000000020"'
  transactions.create :direct_debit, counterparty: counterparties.insurance,
    booked_on: "2026-10-14", value_on: "2026-10-14", amount: "-6.9", reference: "Haftpflicht 10/2026 Vertrag 1234567",
    creditor_id: "DE33ZZZ00000111222", mandate_reference: "VS-1234567-01", customer_reference: "KKKKKKKKKKKKKKK5",
    raw_row: '"14.10.26";"14.10.26";"Gebucht";"Max Mustermann";"Muster Versicherung AG";"Haftpflicht 10/2026 Vertrag 1234567";"Ausgang";"DE27700202700015012345";"-6,9";"DE33ZZZ00000111222";"VS-1234567-01";"KKKKKKKKKKKKKKK5"'
end

balances.create :girokonto_current, account: girokonto, recorded_on: "2026-10-14", amount: "1616.35"
