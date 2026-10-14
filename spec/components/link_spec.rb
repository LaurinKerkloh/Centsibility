RSpec.describe Components::Link do
  it "renders a primary link with extra attributes" do
    rendered = render(described_class.new(href: "/passwords/new", data: {turbo_frame: "_top"})) { "Forgot password?" }

    expect(rendered).to have_css("a[href='/passwords/new'][data-turbo-frame='_top'].text-primary", text: "Forgot password?")
  end
end
