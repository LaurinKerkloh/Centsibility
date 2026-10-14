class Views::Passwords::New < Views::Base
  def page_title = "Forgot password"

  def view_template
    render Components::AuthForm.new(title: "Forgot your password?", url: passwords_path) do |form|
      form.field :email_field, :email_address, "Email address", autofocus: true, autocomplete: "username"
      form.submit "Email reset instructions"
    end
  end
end
