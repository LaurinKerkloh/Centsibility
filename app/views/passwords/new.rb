class Views::Passwords::New < Views::Base
  include Phlex::Rails::Helpers::FormWith

  def page_title = "Forgot password"

  def view_template
    div(class: "mx-auto w-full max-w-sm") do
      h1(class: "text-2xl font-bold") { "Forgot your password?" }

      form_with(url: passwords_path, class: "mt-6 space-y-5") do |form|
        div do
          form.label :email_address, "Email address", class: "block text-sm font-medium"
          form.email_field :email_address, required: true, autofocus: true, autocomplete: "username", class: "mt-1 block w-full rounded-md border border-gray-400 px-3 py-2 shadow-sm focus:outline-blue-600"
        end

        form.submit "Email reset instructions", class: "cursor-pointer rounded-md bg-blue-600 px-3.5 py-2.5 font-medium text-white hover:bg-blue-500"
      end
    end
  end
end
