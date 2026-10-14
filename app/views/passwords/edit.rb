class Views::Passwords::Edit < Views::Base
  def initialize(token:)
    @token = token
  end

  def page_title = "Reset password"

  def view_template
    render Components::AuthForm.new(title: "Update your password", url: password_path(@token), method: :put) do |form|
      form.field :password_field, :password, "New password", autocomplete: "new-password", maxlength: 72
      form.field :password_field, :password_confirmation, "Repeat new password", autocomplete: "new-password", maxlength: 72
      form.submit "Save"
    end
  end
end
