class Components::Layout < Components::Base
  include Phlex::Rails::Helpers::CSRFMetaTags
  include Phlex::Rails::Helpers::CSPMetaTag
  include Phlex::Rails::Helpers::StyleSheetLinkTag
  include Phlex::Rails::Helpers::JavaScriptImportmapTags
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

      body(class: "min-h-screen bg-background text-text") do
        header(class: "container mx-auto flex justify-end px-5 py-4") do
          if Current.session
            render Components::Button.new(variant: :secondary, href: session_path, method: :delete) { "Sign out" }
          end
        end

        flash_messages
        main(class: "container mx-auto mt-16 px-5 flex", &)
      end
    end
  end

  FLASH_KINDS = {
    "notice" => :success,
    "alert" => :error,
    "info" => :info,
    "warning" => :warning
  }.freeze
  private_constant :FLASH_KINDS

  private

  def flash_messages
    messages = flash.to_hash.slice(*FLASH_KINDS.keys)
    return if messages.empty?

    div(class: "container mx-auto mt-4 px-5 space-y-2") do
      messages.each do |key, message|
        render Components::Alert.new(kind: FLASH_KINDS[key]) { message }
      end
    end
  end
end
