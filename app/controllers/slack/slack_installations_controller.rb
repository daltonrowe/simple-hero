require "securerandom"

module Slack
  class SlackInstallationsController < ApplicationController
    allow_unauthenticated_access only: %i[ create ]

    def create
      options = {
        client_id: Rails.configuration.x.slack.client_id,
        client_secret: Rails.configuration.x.slack.client_secret,
        code: params[:code]
      }

      auth = Slack::Web::Client.new.oauth_v2_access(options)
      token = auth.access_token
      user_id = auth.authed_user&.id
      bot_user_id = auth.bot_user_id
      team_id = auth.team&.id
      team_name = auth.team&.name
      oauth_scope = auth.scope

      installation = SlackInstallation.where(token: token).first
      installation ||= SlackInstallation.where(slack_team_id: team_id).first

      if installation
        installation.ping_if_active!
        installation.update!(
          oauth_scope:,
          activated_user_id: user_id,
          activated_user_access_token: token,
          bot_user_id:
        )

        if installation.active?
          redirect_to root_path, notice: "Slack Team already exists!"
        else
          installation.activate!(token)
        end
      else


        SlackInstallation.create!(
          id: SecureRandom.uuid,
          user: find_or_create_user(user_id, token),
          token:,
          oauth_version: :v2,
          oauth_scope:,
          slack_team_id: team_id,
          name: team_name,
          activated_user_id: user_id,
          activated_user_access_token: token,
          bot_user_id:
        )

        redirect_to root_path, notice: "Slack Team created!"
      end
    end

    private

    def find_or_create_user(slack_user_id, token)
      client = Slack::Web::Client.new(token: token)
      user_info = client.users_info(user: slack_user_id).user.profile
      slack_user = SlackUser.find_by(slack_user_id: slack_user_id)

      if slack_user
        slack_user.user
      else
        user = User.create_with(
                      id: SecureRandom.uuid,
                      name: user_info.real_name,
                      email_address: user_info.email,
                      password: SecureRandom.uuid)
                   .find_or_create_by!(email_address: user_info.email)
        SlackUser.create!(id: SecureRandom.uuid, slack_user_id:, user_id: user.id)
        user
      end
    end
  end
end
