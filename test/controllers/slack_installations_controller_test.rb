require "test_helper"
require "ostruct"

class SlackInstallationsControllerTest < ActionDispatch::IntegrationTest
  AUTH_CODE = SecureRandom.hex(10)

  def with_stubbed_slack_client
    mock_slack_client = Minitest::Mock.new
    oauth_v2_access_response = OpenStruct.new(
      access_token: SecureRandom.hex(10),
      authed_user: OpenStruct.new(id: 99),
      bot_user_id: 100,
      team: OpenStruct.new(id: 101, name: "Dalmatians"),
      scope: "users:read",
    )
    mock_slack_client.expect :oauth_v2_access,
                             oauth_v2_access_response,
                             [ {
                                    client_id: Rails.configuration.x.slack.client_id,
                                    client_secret: Rails.configuration.x.slack.client_secret,
                                    code: AUTH_CODE
                                  } ]

    users_info_response = OpenStruct.new(
      user: OpenStruct.new(
        profile: OpenStruct.new(
          real_name: "Kit", email: "kit@example.com"
        )
      ),
    )
    mock_slack_client.expect :users_info, users_info_response, user: 99

    Slack::Web::Client.stub :new, mock_slack_client do
      yield
    end
  end

  test "Creates a slack installation and user without requiring authentication" do
    with_stubbed_slack_client do
      get slack_create_team_path, params: { code: AUTH_CODE }

      installation = SlackInstallation.find_by(name: "Dalmatians")
      user = User.find_by(email_address: "Kit@example.com")

      assert installation.present?
      assert user.present?
      assert SlackUser.find_by(user_id: user, slack_user_id: 99).present?

      assert flash[:notice], "Slack Team created!"
      assert_redirected_to root_path
    end
  end
end
