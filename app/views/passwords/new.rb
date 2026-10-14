class Views::Passwords::New < Views::Base
  def page_title = "Forgot password"

  def view_template
    div(class: "mx-auto w-full max-w-sm") do
      h1(class: "mb-6 text-2xl font-bold") { "Forgot your password?" }

      render Components::Form.new(url: passwords_path) do |form|
        form.email_field :email_address, label: "Email address", required: true, autofocus: true, autocomplete: "username"
        form.submit "Email reset instructions"
      end
    end
  end
end
