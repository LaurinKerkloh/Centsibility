class Components::Panel < Components::Base
  def initialize(title:)
    @title = title
  end

  def view_template
    div(class: "mx-auto w-full max-w-sm") do
      h1(class: "mb-6 text-2xl font-bold") { @title }
      yield
    end
  end
end
