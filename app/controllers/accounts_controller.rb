class AccountsController < ApplicationController
  def index
    render Views::Accounts::Index.new(accounts: Account.order(:name).load)
  end
end
