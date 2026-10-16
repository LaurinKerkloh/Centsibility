class TransactionsController < ApplicationController
  def index
    filter = Transaction::Filter.new(params.permit(:account_id, :q, :from, :to, :direction, :page))

    respond_to do |format|
      format.html { render Views::Transactions::Index.new(filter:) }
      format.turbo_stream { render Views::Transactions::Batch.new(filter:) }
    end
  end
end
