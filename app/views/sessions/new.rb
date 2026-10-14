class Views::Sessions::New < Views::Base
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::LinkTo

  def page_title = "Sign in"

  def view_template
    div(class: "mx-auto w-full max-w-sm") do
      h1(class: "text-2xl font-bold") { "Sign in" }

      form_with(url: session_path, class: "mt-6 space-y-5") do |form|
        div do
          form.label :email_address, "Email address", class: "block text-sm font-medium"
          form.email_field :email_address, required: true, autofocus: true, autocomplete: "username", class: "mt-1 block w-full rounded-md border border-gray-400 px-3 py-2 shadow-sm focus:outline-blue-600"
        end

        div do
          form.label :password, "Password", class: "block text-sm font-medium"
          form.password_field :password, required: true, autocomplete: "current-password", maxlength: 72, class: "mt-1 block w-full rounded-md border border-gray-400 px-3 py-2 shadow-sm focus:outline-blue-600"
        end

        div(class: "flex items-center gap-4") do
          form.submit "Sign in", class: "cursor-pointer rounded-md bg-blue-600 px-3.5 py-2.5 font-medium text-white hover:bg-blue-500"
          link_to "Forgot password?", new_password_path, class: "text-sm text-gray-700 underline hover:no-underline"
        end
      end
    end
  end
end
