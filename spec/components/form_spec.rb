RSpec.describe Components::Form do
  it "renders a form for a url with the given method", :aggregate_failures do
    rendered = render(described_class.new(url: "/passwords/abc", method: :put)) do |form|
      form.password_field :password, label: "New password", required: true, autocomplete: "new-password"
      form.submit "Save"
    end

    expect(rendered).to have_css("form[action='/passwords/abc'][method='post'] input[name='_method'][value='put']", visible: :hidden)
    expect(rendered).to have_field("New password", type: "password")
    expect(rendered).to have_css("input#password[required][autocomplete='new-password']")
    expect(rendered).to have_css("button[type='submit'].bg-primary", text: "Save")
    expect(rendered).to have_no_css("form[enctype]")
  end

  it "renders each field type with a linked label", :aggregate_failures do
    rendered = render(described_class.new(url: "/rules")) do |form|
      form.text_field :name, label: "Name"
      form.email_field :email, label: "Email"
      form.number_field :amount, label: "Amount", step: 0.01
      form.select :kind, [["Income", "income"], ["Spending", "spending"]], label: "Kind"
    end

    expect(rendered).to have_field("Name", type: "text")
    expect(rendered).to have_field("Email", type: "email")
    expect(rendered).to have_field("Amount", type: "number")
    expect(rendered).to have_css("input#amount[step='0.01']")
    expect(rendered).to have_select("Kind", options: %w[Income Spending])
  end

  it "submits as multipart when it contains a file field", :aggregate_failures do
    rendered = render(described_class.new(url: "/imports")) do |form|
      form.file_field :file, label: "CSV file", accept: ".csv"
    end

    expect(rendered).to have_css("form[enctype='multipart/form-data']")
    expect(rendered).to have_field("CSV file", type: "file")
  end

  it "renders the secondary submit variant" do
    rendered = render(described_class.new(url: "/rules")) { |form| form.submit "Preview", variant: :secondary }

    expect(rendered).to have_css("button[type='submit'].border-border", text: "Preview")
  end

  context "with a model" do
    let(:user) { User.new(email_address: "someone@example.com").tap(&:validate) }

    it "fills in the values and shows errors for invalid attributes", :aggregate_failures do
      rendered = render(described_class.new(model: user, url: "/users")) do |form|
        form.email_field :email_address, label: "Email address"
        form.password_field :password, label: "Password"
      end

      expect(rendered).to have_field("Email address", with: "someone@example.com")
      expect(rendered).to have_no_css("input#user_email_address[aria-invalid]")
      expect(rendered).to have_css("input#user_password.border-danger[aria-invalid='true'][aria-describedby='user_password_errors']")
      expect(rendered).to have_css("#user_password_errors", text: "Password can't be blank")
    end
  end
end
