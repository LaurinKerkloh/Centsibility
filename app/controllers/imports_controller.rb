class ImportsController < ApplicationController
  def index
    render_index
  end

  def create
    file = params.dig(:import, :file)
    return render_index(error: "Select a CSV file.") unless file.respond_to?(:read)

    result = Importer.new(Parsers::Dkb.parse(file.read)).call(import: Import.new(filename: file.original_filename))
    if result.import
      redirect_to result.import, notice: "Imported #{result.transactions.size} transactions."
    else
      redirect_to imports_path, notice: "Nothing new in #{file.original_filename}."
    end
  rescue Parsers::InvalidFile, ActiveRecord::RecordInvalid => error
    render_index(error: error.message)
  end

  def show
    import = Import.includes(:account, :balances).find(params[:id])
    transactions = import.transactions.includes(:counterparty).order(:booked_on, :id).load
    render Views::Imports::Show.new(import:, transactions:)
  end

  def destroy
    import = Import.find(params[:id])
    return redirect_to import, alert: "Only the latest import of an account can be deleted." unless import.latest?

    import.revert!
    redirect_to imports_path, notice: "Deleted the import of #{import.filename}."
  end

  private

  def render_index(error: nil)
    import = Import.new
    import.errors.add(:file, error) if error
    imports = Import.with_new_count.includes(:account).order(created_at: :desc).load
    render Views::Imports::Index.new(import:, imports:), status: error ? :unprocessable_content : :ok
  end
end
