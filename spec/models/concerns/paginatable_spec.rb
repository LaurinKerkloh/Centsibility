RSpec.describe Paginatable do
  let(:newest_first) { Transaction.order(booked_on: :desc) }

  it "returns the records of the page and that more follow", :aggregate_failures do
    page = newest_first.paginate("2", per: 2)

    expect(page.records).to eq([transactions.account_fee, transactions.salary])
    expect(page.number).to eq(2)
    expect(page.more?).to be(true)
    expect(page.next_number).to eq(3)
  end

  it "says when the last page is reached", :aggregate_failures do
    page = newest_first.paginate("3", per: 2)

    expect(page.records).to eq([transactions.savings_transfer])
    expect(page.more?).to be(false)
    expect(page.next_number).to be_nil
  end

  it "has no more on a last page that is exactly full" do
    expect(newest_first.paginate("1", per: 5).more?).to be(false)
  end

  it "treats a missing or invalid page as the first", :aggregate_failures do
    expect(newest_first.paginate(nil, per: 2).number).to eq(1)
    expect(newest_first.paginate("0", per: 2).records.first).to eq(transactions.direct_debit)
  end

  it "keeps the relation's scope" do
    expect(Transaction.spending.order(:booked_on).paginate("1", per: 10).records).to eq(Transaction.spending.order(:booked_on).to_a)
  end
end
