RSpec.configure do |config|
  config.include Capybara::RSpecMatchers, type: :request
end
