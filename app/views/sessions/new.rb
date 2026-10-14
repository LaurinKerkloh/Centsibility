class Views::Sessions::New < Views::Base
  include Phlex::Rails::Helpers::LinkTo

  def page_title = "Sign in"

  def view_template
    render Components::AuthForm.new(title: "Sign in", url: session_path) do |form|
      form.field :email_field, :email_address, "Email address", autofocus: true, autocomplete: "username"
      form.field :password_field, :password, "Password", autocomplete: "current-password", maxlength: 72

      div(class: "flex items-center gap-4") do
        form.submit "Sign in"
        link_to "Forgot password?", new_password_path, class: "text-sm text-gray-700 underline hover:no-underline"
      end
    end
  end
end
