class Components::Layout < Components::Base
  include Phlex::Rails::Helpers::CSRFMetaTags
  include Phlex::Rails::Helpers::CSPMetaTag
  include Phlex::Rails::Helpers::StyleSheetLinkTag
  include Phlex::Rails::Helpers::JavaScriptImportmapTags
  include Phlex::Rails::Helpers::ButtonTo
  include Phlex::Rails::Helpers::Flash

  def initialize(title:)
    @title = title
  end

  def view_template(&)
    doctype

    html do
      head do
        title { @title }
        meta(name: "viewport", content: "width=device-width,initial-scale=1")
        meta(name: "apple-mobile-web-app-capable", content: "yes")
        meta(name: "application-name", content: "Banking")
        meta(name: "mobile-web-app-capable", content: "yes")
        csrf_meta_tags
        csp_meta_tag

        link(rel: "icon", href: "/icon.png", type: "image/png")
        link(rel: "icon", href: "/icon.svg", type: "image/svg+xml")
        link(rel: "apple-touch-icon", href: "/icon.png")

        stylesheet_link_tag :app, "data-turbo-track": "reload"
        javascript_importmap_tags
      end

      body do
        header(class: "container mx-auto flex justify-end px-5 py-4") do
          if Current.user
            button_to "Sign out", session_path, method: :delete, class: "cursor-pointer text-sm text-gray-700 underline hover:no-underline"
          end
        end

        flash_messages
        main(class: "container mx-auto mt-16 px-5 flex", &)
      end
    end
  end

  private

  def flash_messages
    return unless flash[:alert] || flash[:notice]

    div(class: "container mx-auto mt-4 px-5 space-y-2") do
      p(role: "alert", class: "rounded-lg bg-red-50 px-3 py-2 font-medium text-red-600") { flash[:alert] } if flash[:alert]
      p(role: "status", class: "rounded-lg bg-green-50 px-3 py-2 font-medium text-green-600") { flash[:notice] } if flash[:notice]
    end
  end
end
