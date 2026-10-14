RSpec.describe Components::Form do
  context "with a url and a method" do
    let(:rendered) do
      render(described_class.new(url: "/passwords/abc", method: :put)) do |form|
        form.password_field :password, label: "New password", required: true, autocomplete: "new-password"
        form.submit "Save"
      end
    end

    it "renders the form with the method override", :aggregate_failures do
      expect(rendered).to have_css("form[action='/passwords/abc'][method='post'] input[name='_method'][value='put']", visible: :hidden)
      expect(rendered).to have_no_css("form[enctype]")
    end

    it "passes extra attributes to the input", :aggregate_failures do
      expect(rendered).to have_field("New password", type: "password")
      expect(rendered).to have_css("input#password[required][autocomplete='new-password']")
    end

    it "renders a primary submit button" do
      expect(rendered).to have_css("button[type='submit'].bg-primary", text: "Save")
    end
  end

  context "with every field type" do
    let(:rendered) do
      render(described_class.new(url: "/rules")) do |form|
        form.text_field :name, label: "Name"
        form.email_field :email, label: "Email"
        form.number_field :amount, label: "Amount"
        form.select :kind, [["Income", "income"], ["Spending", "spending"]], label: "Kind"
      end
    end

    it "renders the inputs with linked labels", :aggregate_failures do
      expect(rendered).to have_field("Name", type: "text")
      expect(rendered).to have_field("Email", type: "email")
      expect(rendered).to have_field("Amount", type: "number")
    end

    it "renders the select with its choices" do
      expect(rendered).to have_select("Kind", options: %w[Income Spending])
    end
  end

  it "submits as multipart when it contains a file field", :aggregate_failures do
    rendered = render(described_class.new(url: "/imports")) { |form| form.file_field :file, label: "CSV file" }

    expect(rendered).to have_css("form[enctype='multipart/form-data']")
    expect(rendered).to have_field("CSV file", type: "file")
  end

  it "passes Rails select options to the builder and the rest to the select", :aggregate_failures do
    rendered = render(described_class.new(url: "/rules")) do |form|
      form.select :kind, %w[income spending], label: "Kind", include_blank: true, selected: "spending", required: true
    end

    expect(rendered).to have_select("Kind", options: ["", "income", "spending"], selected: "spending")
    expect(rendered).to have_css("select[required]:not([include_blank])")
  end

  it "adds extra classes to its own" do
    rendered = render(described_class.new(url: "/rules", class: "mt-4")) { |form| form.submit "Save" }

    expect(rendered).to have_css("form.space-y-5.mt-4")
  end

  it "renders the secondary submit variant" do
    rendered = render(described_class.new(url: "/rules")) { |form| form.submit "Preview", variant: :secondary }

    expect(rendered).to have_css("button[type='submit'].border-border", text: "Preview")
  end

  context "with an invalid model" do
    let(:user) { User.new(email_address: "someone@example.com").tap(&:validate) }
    let(:rendered) do
      render(described_class.new(model: user, url: "/users")) do |form|
        form.email_field :email_address, label: "Email address"
        form.password_field :password, label: "Password"
      end
    end

    it "fills in the values of valid attributes", :aggregate_failures do
      expect(rendered).to have_field("Email address", with: "someone@example.com")
      expect(rendered).to have_no_css("input#user_email_address[aria-invalid]")
    end

    it "marks invalid attributes and shows their errors", :aggregate_failures do
      expect(rendered).to have_css("input#user_password.border-danger[aria-invalid='true'][aria-describedby='user_password_errors']")
      expect(rendered).to have_css("#user_password_errors", text: "Password can't be blank")
    end
  end
end
