class FormPreview < Lookbook::Preview
  def fields
    render Components::Form.new(url: "#") do |form|
      form.text_field :name, label: "Name"
      form.email_field :email, label: "Email address"
      form.password_field :password, label: "Password"
      form.number_field :amount, label: "Amount", step: 0.01
      form.select :kind, [["Income", "income"], ["Spending", "spending"]], label: "Kind"
      form.file_field :file, label: "CSV file", accept: ".csv"
      form.submit "Save"
    end
  end

  def with_errors
    user = User.new(email_address: "someone@example.com").tap(&:validate)
    user.errors.add(:email_address, :taken)

    render Components::Form.new(model: user, url: "#") do |form|
      form.email_field :email_address, label: "Email address"
      form.password_field :password, label: "Password"
      form.submit "Save"
    end
  end

  # @param input select [text_field, email_field, password_field, number_field, file_field]
  # @param label text
  # @param error text
  # @param submit_variant select [primary, secondary, danger]
  def playground(input: :text_field, label: "Email address", error: "", submit_variant: :primary)
    user = User.new
    user.errors.add(:email_address, error) if error.present?

    render Components::Form.new(model: user, url: "#") do |form|
      form.public_send(input.to_sym, :email_address, label:)
      form.submit "Save", variant: submit_variant.to_sym
    end
  end
end
