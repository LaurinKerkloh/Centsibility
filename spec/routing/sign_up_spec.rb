RSpec.describe "Sign-up" do
  it "has no route", :aggregate_failures do
    expect(get: "/users/new").not_to be_routable
    expect(post: "/users").not_to be_routable
    expect(get: "/registrations/new").not_to be_routable
    expect(get: "/sign_up").not_to be_routable
  end
end
