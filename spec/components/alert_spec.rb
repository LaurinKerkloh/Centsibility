RSpec.describe Components::Alert do
  it "renders an info alert by default that dismisses itself", :aggregate_failures do
    rendered = render(described_class.new) { "Import started" }

    expect(rendered).to have_css("[role='status'][data-controller='alert'][data-alert-timeout-value='5000']", text: "Import started")
    expect(rendered).to have_css(".text-info")
  end

  it "renders success alerts as a status that dismisses itself" do
    rendered = render(described_class.new(kind: :success)) { "Saved" }

    expect(rendered).to have_css("[role='status'][data-alert-timeout-value='5000'] .text-success", text: "Saved")
  end

  it "renders warning and error alerts as alerts that stay", :aggregate_failures do
    {warning: "text-warning", error: "text-danger"}.each do |kind, color|
      rendered = render(described_class.new(kind:)) { "Careful" }

      expect(rendered).to have_css("[role='alert'][data-controller='alert'] .#{color}", text: "Careful")
      expect(rendered).to have_no_css("[data-alert-timeout-value]")
    end
  end

  it "has a close button" do
    rendered = render(described_class.new) { "Hello" }

    expect(rendered).to have_css("button[type='button'][aria-label='Dismiss'][data-action='alert#dismiss']")
  end
end
