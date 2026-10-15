RSpec.describe "Imports" do
  let(:sample) { file_fixture("dkb/girokonto.csv") }

  before { sign_in_as users.user }

  def upload(content = sample.read, filename: "girokonto.csv")
    file = Tempfile.new(["upload", ".csv"]).tap { it.binmode.write(content) && it.rewind }
    post imports_path, params: {import: {file: Rack::Test::UploadedFile.new(file.path, "text/csv", original_filename: filename)}}
  end

  def import_sample = Importer.new(Parsers::Dkb.parse(sample.read)).call(import: Import.new(filename: "girokonto.csv")).import

  it "redirects to the login page when signed out" do
    delete session_path
    get imports_path

    expect(response).to redirect_to(new_session_path)
  end

  describe "GET /imports" do
    it "shows the upload form and the history, newest first", :aggregate_failures do
      older = import_sample
      newer = Importer.new(Parsers::Dkb.parse(sample.read.sub("DE45120300001234567890", "DE08500105170007654321")))
        .call(import: Import.new(filename: "tagesgeld.csv")).import
      newer.update_columns(created_at: older.created_at + 1.day)

      get imports_path

      expect(response.body).to have_title("Imports")
      expect(response.body).to have_css("form[action='/imports'][enctype='multipart/form-data'] input[type='file'][name='import[file]'][accept='.csv,text/csv']")
      expect(response.body).to have_css("tbody tr", count: 2)
      expect(response.body).to have_css("tbody tr:first-child a[href='/imports/#{newer.id}']", text: "tagesgeld.csv")
      expect(response.body).to have_css("tbody tr:last-child", text: /girokonto\.csv.*Girokonto.*#{older.transactions.count}.*5/)
      expect(response.body).to have_css("tbody tr:last-child", text: older.created_at.strftime("%d.%m.%Y"))
    end

    it "says when nothing was imported yet" do
      get imports_path

      expect(response.body).to have_text("No imports yet.")
    end
  end

  describe "POST /imports" do
    it "imports the file and redirects to the import", :aggregate_failures do
      expect { upload }.to change(Import, :count).by(1)

      import = Import.last
      expect(response).to redirect_to(import_path(import))
      expect(flash[:notice]).to eq("Imported #{import.transactions.count} transactions.")
    end

    it "records nothing when the file adds nothing new", :aggregate_failures do
      import_sample

      expect { upload }.not_to change(Import, :count)
      expect(response).to redirect_to(imports_path)
      expect(flash[:notice]).to eq("Nothing new in girokonto.csv.")
    end

    it "asks for a file when none was selected", :aggregate_failures do
      post imports_path

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to have_css("#import_file_errors", text: "Select a CSV file.")
    end

    it "shows the parser error for an invalid file", :aggregate_failures do
      expect { upload("not a bank export") }.not_to change(Transaction, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to have_css("#import_file_errors", text: "The file is missing the DKB header block.")
    end

    it "shows the parser error for a file in the wrong encoding" do
      upload("\"Gesch\xE4ftskonto\";\"DE45120300001234567890\"".b)

      expect(response.body).to have_css("#import_file_errors", text: "not valid UTF-8")
    end

    it "shows the error when a record can't be saved", :aggregate_failures do
      invalid = Transaction.new.tap(&:validate)
      allow(Importer).to receive(:new).and_wrap_original do |original, statement|
        original.call(statement).tap { allow(it).to receive(:call).and_raise(ActiveRecord::RecordInvalid, invalid) }
      end

      expect { upload }.not_to change(Import, :count)
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to have_css("#import_file_errors", text: "Validation failed")
    end
  end

  describe "GET /imports/:id" do
    it "shows the summary and the added transactions", :aggregate_failures do
      import = import_sample

      get import_path(import)

      first = import.transactions.order(:booked_on, :id).first
      expect(response.body).to have_title("girokonto.csv")
      expect(response.body).to have_css("dd", exact_text: "Girokonto")
      expect(response.body).to have_css("dd", exact_text: "None")
      expect(response.body).to have_css("tbody tr", count: import.transactions.count)
      expect(response.body).to have_css("tbody tr:first-child",
        text: /#{first.booked_on.strftime("%d.%m.%Y")}.*#{first.counterparty.name}.*#{Regexp.escape(first.reference)}/)
      expect(response.body).to have_button("Delete import")
    end

    it "marks an account the import created and shows the balance it added", :aggregate_failures do
      content = sample.read.sub("DE45120300001234567890", "DE08500105170007654321")
      import = Importer.new(Parsers::Dkb.parse(content)).call(import: Import.new(filename: "neu.csv")).import

      get import_path(import)

      expect(response.body).to have_css("dd", exact_text: "Girokonto new")
      expect(response.body).to have_css("dd", exact_text: "1.616,35 € on 14.10.2026")
    end

    it "offers no delete button for an older import" do
      older = import_sample
      Importer.new(Parsers::Dkb.parse(sample.read.sub("1.616,35", "1.700,00"))).call(import: Import.new(filename: "later.csv"))

      get import_path(older)

      expect(response.body).to have_no_button("Delete import")
    end
  end

  describe "DELETE /imports/:id" do
    it "reverts the latest import", :aggregate_failures do
      import = import_sample

      expect { delete import_path(import) }.to change(Import, :count).by(-1).and change(Transaction, :count).by(-import.transactions.count)
      expect(response).to redirect_to(imports_path)
      expect(flash[:notice]).to eq("Deleted the import of girokonto.csv.")
    end

    it "refuses to delete an older import", :aggregate_failures do
      older = import_sample
      Importer.new(Parsers::Dkb.parse(sample.read.sub("1.616,35", "1.700,00"))).call(import: Import.new(filename: "later.csv"))

      expect { delete import_path(older) }.not_to change(Import, :count)
      expect(response).to redirect_to(import_path(older))
      expect(flash[:alert]).to eq("Only the latest import of an account can be deleted.")
    end
  end
end
