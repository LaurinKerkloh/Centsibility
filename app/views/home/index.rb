class Views::Home::Index < Views::Base
  def view_template
    h1(class: "text-2xl font-bold") { "Home" }
  end
end
