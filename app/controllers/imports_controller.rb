class ImportsController < ApplicationController
  def index
    imports = Import.with_new_count.includes(:account).order(created_at: :desc).load
    render Views::Imports::Index.new(imports:)
  end

  def new
    render Views::Imports::New.new(import: Import.new)
  end

  def create
    file = params.dig(:import, :file)
    return render_upload_error("Select a CSV file.") unless file.respond_to?(:read)

    result = Importer.new(Parsers::Dkb.parse(file.read)).call(import: Import.new(filename: file.original_filename))
    if result.import
      redirect_to result.import, notice: "Imported #{helpers.pluralize(result.transactions.size, "transaction")}."
    else
      redirect_to imports_path, notice: "Nothing new in #{file.original_filename}."
    end
  rescue Parsers::InvalidFile, ActiveRecord::RecordInvalid => error
    render_upload_error(error.message)
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

  def render_upload_error(message)
    import = Import.new
    import.errors.add(:file, message)
    render Views::Imports::New.new(import:), status: :unprocessable_content
  end
end
