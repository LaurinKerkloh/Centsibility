class ImportsController < ApplicationController
  def index
    render_index Import.new
  end

  def create
    file = params.dig(:import, :file)
    import = Import.new(filename: file.try(:original_filename))
    return render_index(import, error: "Select a CSV file.") unless file.respond_to?(:read)

    result = Importer.new(Parsers::Dkb.parse(file.read)).call(import:)
    if result.import
      redirect_to result.import, notice: "Imported #{result.transactions.size} transactions."
    else
      redirect_to imports_path, notice: "Nothing new in #{file.original_filename}."
    end
  rescue Parsers::InvalidFile, ActiveRecord::RecordInvalid => error
    render_index(Import.new(filename: import.filename), error: error.message)
  end

  def show
    import = Import.includes(:account, :balances).find(params[:id])
    render Views::Imports::Show.new(import:, transactions: import.transactions.includes(:counterparty).order(:booked_on, :id))
  end

  def destroy
    import = Import.find(params[:id])
    return redirect_to import, alert: "Only the latest import of an account can be deleted." unless import.latest?

    import.revert!
    redirect_to imports_path, notice: "Deleted the import of #{import.filename}."
  end

  private

  def render_index(import, error: nil)
    import.errors.add(:file, error) if error
    imports = Import.includes(:account).left_joins(:transactions).group(:id)
      .select("imports.*, COUNT(transactions.id) AS new_count").order(created_at: :desc)
    render Views::Imports::Index.new(import:, imports:), status: error ? :unprocessable_content : :ok
  end
end
