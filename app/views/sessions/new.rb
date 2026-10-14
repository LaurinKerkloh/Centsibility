class Views::Sessions::New < Views::Base
  def page_title = "Sign in"

  def view_template
    render Components::Panel.new(title: "Sign in") do
      render Components::Form.new(url: session_path) do |form|
        form.email_field :email_address, label: "Email address", required: true, autofocus: true, autocomplete: "username"
        form.password_field :password, label: "Password", required: true, autocomplete: "current-password", maxlength: 72

        div(class: "flex items-center gap-4") do
          form.submit "Sign in"
          render Components::Link.new(href: new_password_path, class: "text-sm") { "Forgot password?" }
        end
      end
    end
  end
end
