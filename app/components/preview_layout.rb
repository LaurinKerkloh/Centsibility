class Components::PreviewLayout < Components::Base
  include Phlex::Rails::Layout
  include Phlex::Rails::Helpers::StyleSheetLinkTag
  include Phlex::Rails::Helpers::JavaScriptImportmapTags

  def view_template(&)
    doctype

    html do
      head do
        meta(name: "viewport", content: "width=device-width,initial-scale=1")
        stylesheet_link_tag :app
        javascript_importmap_tags
      end

      body(class: "bg-background p-6 text-text", &)
    end
  end
end
