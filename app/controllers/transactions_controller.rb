class TransactionsController < ApplicationController
  def index
    filter = Transaction::Filter.new(account: Account.find(params[:account_id]), **filter_params)

    respond_to do |format|
      format.html { render Views::Transactions::Index.new(filter:) }
      format.turbo_stream { render Views::Transactions::Batch.new(filter:) }
    end
  end

  private

  def filter_params = params.permit(:q, :from, :to, :direction, :page).to_h.symbolize_keys
end
