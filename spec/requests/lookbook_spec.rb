RSpec.describe "Lookbook" do
  it "renders the index without sign-in" do
    get "/lookbook"

    expect(response).to have_http_status(:ok)
  end

  it "has previews for the components" do
    expect(Lookbook.previews.map(&:name)).to include("button", "link", "alert", "form")
  end

  Lookbook.previews.each do |preview|
    preview.scenarios.each do |scenario|
      it "renders #{preview.name}/#{scenario.name} in the dark theme", :aggregate_failures do
        get scenario.preview_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("bg-background")
      end
    end
  end
end
