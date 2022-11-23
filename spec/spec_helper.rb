ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb", __FILE__)
require "rspec/rails"
require "factory_bot_rails"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"
end

def post_request(content_type = "application/scim+json")
  # params need to be transformed into a string to test if they are being parsed by Rack

  post "/scim/v2/Users",
    params: {
      name: {
        givenName: "New",
        familyName: "User"
      },
      emails: [
        {
          value: "new@example.com"
        }
      ]
    }.to_json,
    headers: {
      Authorization: authorization,
      "Content-Type": content_type
    }
end
