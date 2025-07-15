ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "webmock/minitest"
require "minitest/mock"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    SIGNED_COOKIE_SALT = "signed cookie"

    def sign_in(user)
      cookies[:session_id] = Rails.application.message_verifier(SIGNED_COOKIE_SALT).generate(user.sessions.create.id)
    end

    def basic_status_content
      [
        { name: "Yesterday", content: [ "i", "love", "tacos", "yesterday" ] },
        { name: "Today", content: [ "i", "love", "tacos", "today" ] },
        { name: "Links", content: [ "i", "love", "tacos", "all the time" ] }
      ]
    end

    def basic_status_user_input
      { "sections"=>{ "Yesterday"=>"- I love pizza\n- And taco's\n- oh yes", "Today"=>"- ", "Links"=>"" } }
    end

    def with_captcha_success
      stub_request(:any, Rails.application.credentials.turnstile_challenge_url).
          to_return(body: { "success" => true }.to_json, headers: {
            "Content-Type" => "application/json"
          })
    end

    def with_captcha_failure
      stub_request(:any, Rails.application.credentials.turnstile_challenge_url).
          to_return(body: { "success" => false }.to_json, headers: {
            "Content-Type" => "application/json"
          })
    end
  end
end
