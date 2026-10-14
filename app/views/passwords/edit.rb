class Views::Passwords::Edit < Views::Base
  def initialize(token:)
    @token = token
  end

  def page_title = "Reset password"

  def view_template
    div(class: "mx-auto w-full max-w-sm") do
      h1(class: "mb-6 text-2xl font-bold") { "Update your password" }

      render Components::Form.new(url: password_path(@token), method: :put) do |form|
        form.password_field :password, label: "New password", required: true, autocomplete: "new-password", maxlength: 72
        form.password_field :password_confirmation, label: "Repeat new password", required: true, autocomplete: "new-password", maxlength: 72
        form.submit "Save"
      end
    end
  end
end
