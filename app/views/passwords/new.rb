class Views::Passwords::New < Views::Base
  def page_title = "Forgot password"

  def view_template
    render Components::Panel.new(title: "Forgot your password?") do
      render Components::Form.new(url: passwords_path) do |form|
        form.email_field :email_address, label: "Email address", required: true, autofocus: true, autocomplete: "username"
        form.submit "Email reset instructions"
      end
    end
  end
end
