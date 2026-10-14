RSpec.configure do |config|
  config.include ActiveJob::TestHelper, type: :system

  config.before(:each, type: :system) do
    driven_by :selenium, using: :headless_chrome
  end
end
