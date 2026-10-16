RSpec.describe Parsers::Dkb do
  let(:header) do
    <<~CSV
      \uFEFF"Tagesgeld";"DE45120300001234567890"

      "Kontostand vom 14.10.2026:";"1.616,35 €"
      ""
      "Buchungsdatum";"Wertstellung";"Status";"Zahlungspflichtige*r";"Zahlungsempfänger*in";"Verwendungszweck";"Umsatztyp";"IBAN";"Betrag (€)";"Gläubiger-ID";"Mandatsreferenz";"Kundenreferenz"
    CSV
  end
  let(:booked_row) { '"14.10.26";"13.10.26";"Gebucht";"Max Mustermann";"Muster Versicherung AG";"Haftpflicht";"Ausgang";"DE27700202700015012345";"-6,9";"DE33ZZZ00000111222";"VS-1";"KK5"' }
  let(:pending_row) { '"15.10.26";"15.10.26";"Vorgemerkt";"ISSUER";"REWE";"VISA";"Ausgang";"DE96120300009005290904";"-1,04";"";"";""' }

  def parse(*rows, head: header) = described_class.parse(head + rows.map { "#{it}\n" }.join)

  def expect_invalid(content, message)
    expect { described_class.parse(content) }.to raise_error(Parsers::InvalidFile, message)
  end

  describe "the sample export" do
    subject(:statement) { described_class.parse(file_fixture("dkb/girokonto.csv").read) }

    it "reads the header block" do
      expect(statement).to have_attributes(account_type: "Girokonto", account_iban: "DE45120300001234567890",
        balance: BigDecimal("1616.35"), balance_on: Date.new(2026, 10, 14))
    end

    it "returns one entry per booked row, each keeping its original line" do
      lines = file_fixture("dkb/girokonto.csv").read.lines(chomp: true).drop(5)

      expect(statement.entries.map(&:raw_row)).to eq(lines)
    end

    it "parses a row" do
      expect(statement.entries.first).to have_attributes(booked_on: Date.new(2026, 10, 14), value_on: Date.new(2026, 10, 14),
        amount: BigDecimal("-6.9"), counterparty_name: "Muster Versicherung AG", counterparty_iban: "DE27700202700015012345",
        reference: "Haftpflicht 10/2026 Vertrag 1234567", creditor_id: "DE33ZZZ00000111222",
        mandate_reference: "VS-1234567-01", customer_reference: "KKKKKKKKKKKKKKK5")
    end

    it "takes the payer as counterparty for incoming amounts" do
      salary = statement.entries.find { it.reference == "GEHALT 9/26" }

      expect(salary).to have_attributes(amount: BigDecimal("1932.91"), counterparty_name: "Beispiel Software GmbH")
    end

    it "turns placeholder IBANs and empty fields into nil" do
      card_payment = statement.entries.find { it.customer_reference == "400000000000027" }

      expect(card_payment).to have_attributes(counterparty_name: "Treatwell", counterparty_iban: nil, creditor_id: nil,
        mandate_reference: nil)
    end
  end

  it "takes the merchant without IBAN as counterparty for card refunds" do
    refund = '"15.06.23";"15.06.23";"Gebucht";"ISSUER";"Kiosk.Muster/Berlin";"ABWE+Kiosk.Muster/Berlin/../DE";"Eingang";"DE18120300001234567891";"14,23";"";"";"400000000000099"'

    expect(parse(refund).entries.sole).to have_attributes(counterparty_name: "Kiosk.Muster/Berlin", counterparty_iban: nil)
  end

  it "drops internal DKB account numbers from the IBAN column" do
    row = booked_row.sub("DE27700202700015012345", "1012345678")

    expect(parse(row).entries.sole).to have_attributes(counterparty_name: "Muster Versicherung AG", counterparty_iban: nil)
  end

  it "accepts other account types with the same columns" do
    expect(parse(booked_row).account_type).to eq("Tagesgeld")
  end

  it "parses the row fields" do
    expect(parse(booked_row).entries.sole).to have_attributes(booked_on: Date.new(2026, 10, 14),
      value_on: Date.new(2026, 10, 13), amount: BigDecimal("-6.9"), raw_row: booked_row)
  end

  it "drops pending rows" do
    expect(parse(pending_row, booked_row).entries.map(&:raw_row)).to eq([booked_row])
  end

  it "skips blank lines" do
    expect(parse("", booked_row, "").entries.size).to eq(1)
  end

  it "handles CRLF line endings" do
    statement = described_class.parse((header + "#{booked_row}\n").gsub("\n", "\r\n"))

    expect(statement.entries.sole.raw_row).to eq(booked_row)
  end

  it "keeps identical lines" do
    expect(parse(booked_row, booked_row).entries.size).to eq(2)
  end

  ["1.616,35€", "1.616,35 €"].each do |balance|
    it "reads the balance #{balance.inspect}" do
      expect(parse(head: header.sub("1.616,35 €", balance)).balance).to eq(BigDecimal("1616.35"))
    end
  end

  it "accepts a file without BOM" do
    expect(parse(booked_row, head: header.delete_prefix("\uFEFF")).account_iban).to eq("DE45120300001234567890")
  end

  it "accepts content read as binary" do
    expect(described_class.parse((header + booked_row).b).entries.size).to eq(1)
  end

  {
    "-6,9" => "-6.9", "1932,91" => "1932.91", "1.616,35" => "1616.35", "-1.000" => "-1000", "250" => "250", "0,05" => "0.05"
  }.each do |raw, expected|
    it "parses the amount #{raw}" do
      row = booked_row.sub('"-6,9"', %("#{raw}"))

      expect(parse(row).entries.sole.amount).to eq(BigDecimal(expected))
    end
  end

  describe "invalid input" do
    it "rejects invalid UTF-8" do
      expect_invalid("\xFF\xFE".b + header.b, /UTF-8/)
    end

    it "rejects an unexpected account line" do
      expect_invalid(header.sub('"Tagesgeld";', ""), /Line 1/)
    end

    it "rejects a missing balance line" do
      expect_invalid(header.sub("Kontostand vom", "Saldo vom"), /Line 3/)
    end

    it "rejects an unparseable balance date" do
      expect_invalid(header.sub("14.10.2026", "14.10.26"), /Line 3/)
    end

    it "rejects other column headers" do
      expect_invalid(header.sub("Kundenreferenz", "Kunde"), /Line 5/)
    end

    it "rejects a truncated header block" do
      expect_invalid(header.lines.first(3).join, /header/i)
    end

    it "rejects a wrong field count" do
      expect { parse(booked_row, booked_row.sub(/;"KK5"\z/, "")) }.to raise_error(Parsers::InvalidFile, /Line 7.*12 fields/)
    end

    it "rejects an unknown status" do
      expect { parse(booked_row.sub("Gebucht", "Storniert")) }.to raise_error(Parsers::InvalidFile, /Line 6.*Storniert/)
    end

    it "rejects an unparseable date" do
      expect { parse(booked_row.sub('"14.10.26"', '"2026-10-14"')) }.to raise_error(Parsers::InvalidFile, /Line 6.*2026-10-14/)
    end

    it "rejects an impossible date" do
      expect { parse(booked_row.sub('"14.10.26"', '"31.02.26"')) }.to raise_error(Parsers::InvalidFile, /Line 6/)
    end

    %w[-6.9 1,2,3 abc 1.61,35 -6,999].each do |amount|
      it "rejects the amount #{amount}" do
        expect { parse(booked_row.sub('"-6,9"', %("#{amount}"))) }.to raise_error(Parsers::InvalidFile, /Line 6/)
      end
    end

    it "rejects malformed quoting" do
      expect { parse('"14.10.26";"broken') }.to raise_error(Parsers::InvalidFile, /Line 6/)
    end
  end
end
