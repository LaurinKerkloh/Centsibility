RSpec.describe "Authentication routes" do
  it "has no sign-up route", :aggregate_failures do
    expect(get: "/users/new").not_to be_routable
    expect(post: "/users").not_to be_routable
    expect(get: "/registrations/new").not_to be_routable
    expect(get: "/sign_up").not_to be_routable
  end

  it "only routes implemented session and password actions", :aggregate_failures do
    expect(get: "/session").not_to be_routable
    expect(get: "/passwords").not_to be_routable
    expect(delete: "/passwords/token").not_to be_routable
  end
end
