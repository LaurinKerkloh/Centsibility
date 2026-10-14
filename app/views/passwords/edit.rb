class Views::Passwords::Edit < Views::Base
  include Phlex::Rails::Helpers::FormWith

  def initialize(token:)
    @token = token
  end

  def page_title = "Reset password"

  def view_template
    div(class: "mx-auto w-full max-w-sm") do
      h1(class: "text-2xl font-bold") { "Update your password" }

      form_with(url: password_path(@token), method: :put, class: "mt-6 space-y-5") do |form|
        div do
          form.label :password, "New password", class: "block text-sm font-medium"
          form.password_field :password, required: true, autocomplete: "new-password", maxlength: 72, class: "mt-1 block w-full rounded-md border border-gray-400 px-3 py-2 shadow-sm focus:outline-blue-600"
        end

        div do
          form.label :password_confirmation, "Repeat new password", class: "block text-sm font-medium"
          form.password_field :password_confirmation, required: true, autocomplete: "new-password", maxlength: 72, class: "mt-1 block w-full rounded-md border border-gray-400 px-3 py-2 shadow-sm focus:outline-blue-600"
        end

        form.submit "Save", class: "cursor-pointer rounded-md bg-blue-600 px-3.5 py-2.5 font-medium text-white hover:bg-blue-500"
      end
    end
  end
end
