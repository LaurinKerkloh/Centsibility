class Components::AuthForm < Components::Base
  include Phlex::Rails::Helpers::FormWith

  def initialize(title:, url:, method: :post)
    @title = title
    @url = url
    @method = method
  end

  def view_template
    div(class: "mx-auto w-full max-w-sm") do
      h1(class: "text-2xl font-bold") { @title }

      form_with(url: @url, method: @method, class: "mt-6 space-y-5") do |form|
        @form = form
        yield self
      end
    end
  end

  def field(type, name, label, **attributes)
    div do
      @form.label name, label, class: "block text-sm font-medium"
      @form.public_send(type, name, required: true, class: "mt-1 block w-full rounded-md border border-gray-400 px-3 py-2 shadow-sm focus:outline-blue-600", **attributes)
    end
  end

  def submit(text)
    @form.submit text, class: "cursor-pointer rounded-md bg-blue-600 px-3.5 py-2.5 font-medium text-white hover:bg-blue-500"
  end
end
