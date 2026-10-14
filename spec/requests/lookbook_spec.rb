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
      it "renders #{preview.name}/#{scenario.name} with the app stylesheet", :aggregate_failures do
        get scenario.preview_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to have_css("link[rel='stylesheet'][href^='/assets/app']", visible: :all)
      end
    end
  end
end
