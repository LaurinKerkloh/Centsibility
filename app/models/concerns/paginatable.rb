module Paginatable
  extend ActiveSupport::Concern

  Page = Data.define(:records, :number, :more) do
    def more?
      more
    end

    def next_number
      number + 1 if more
    end
  end

  class_methods do
    # Loads one record more than asked for to know whether another page follows, without counting.
    def paginate(page, per:)
      number = [page.to_i, 1].max
      records = offset((number - 1) * per).limit(per + 1).to_a
      Page.new(records: records.first(per), number:, more: records.size > per)
    end
  end
end
