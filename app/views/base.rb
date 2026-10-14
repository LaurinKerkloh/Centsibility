# frozen_string_literal: true

class Views::Base < Components::Base
  def cache_store = Rails.cache

  def page_title = "Banking"

  def around_template
    render Components::Layout.new(title: page_title) { super }
  end
end
