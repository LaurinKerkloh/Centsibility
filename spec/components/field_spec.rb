RSpec.describe Components::Field do
  it "renders every error message of the attribute", :aggregate_failures do
    user = User.new
    user.errors.add(:email_address, :blank)
    user.errors.add(:email_address, :invalid)

    rendered = render(Components::Form.new(model: user, url: "/users")) do |form|
      form.email_field :email_address, label: "Email address"
    end

    expect(rendered).to have_css("#user_email_address_errors p", count: 2)
    expect(rendered).to have_css("#user_email_address_errors", text: "Email address can't be blank")
    expect(rendered).to have_css("#user_email_address_errors", text: "Email address is invalid")
  end
end
