require "test_helper"

class SlackInstallationTest < ActiveSupport::TestCase
  test "validates uniqueness of token" do
    slack_installation = slack_installations(:default)
    assert SlackInstallation.new(token: SecureRandom.uuid).valid?
    assert_not SlackInstallation.new(token: slack_installation.token).valid?
  end

  test "can be activated with a token" do
    slack_installation = slack_installations(:inactive)

    token = SecureRandom.uuid
    slack_installation.activate!(token)
    assert(slack_installation.active?)
    assert(slack_installation.token == token)
  end

  test "can be deactivated" do
    slack_installation = slack_installations(:default)

    assert_changes -> { slack_installation.active }, from: true, to: false do
      slack_installation.deactivate!
    end
  end

  test "can be pinged to remain active" do
    slack_installation = slack_installations(:default)

    mock_slack_client = Minitest::Mock.new
    mock_slack_client.expect :auth_test, { "user_id" => slack_installation.user_id }
    mock_slack_client.expect :users_getPresence, true, user: slack_installation.user_id

    Slack::Web::Client.stub :new, mock_slack_client do
      assert_no_changes -> { slack_installation.active } do
        slack_installation.ping_if_active!
      end
    end
  end

  test "cannot be pinged to reactivate" do
    slack_installation = slack_installations(:inactive)

    assert_no_changes -> { slack_installation.active } do
      slack_installation.ping_if_active!
    end
  end
end
