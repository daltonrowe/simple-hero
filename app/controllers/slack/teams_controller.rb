require 'securerandom'

module Slack
  class TeamsController < ApplicationController
    allow_unauthenticated_access only: %i[ create ]

    def create
      options = {
        client_id: Settings.slack.client_id,
        client_secret: Settings.slack.client_secret,
        code: params[:code]
      }

      auth = Slack::Web::Client.new.oauth_v2_access(options)
      access_token = auth.access_token
      token = auth.access_token
      user_id = auth.authed_user&.id
      bot_user_id = auth.bot_user_id
      team_id = auth.team&.id
      team_name = auth.team&.name
      oauth_scope = auth.scope

      team = Team.where(token: token).first
      team ||= Team.where(team_id: team_id, oauth_version: :v2).first
      team ||= Team.where(team_id: team_id).first

      if team
        team.ping_if_active!
        team.update!(
          oauth_version: :v2,
          oauth_scope:,
          activated_user_id: user_id,
          activated_user_access_token: access_token,
          bot_user_id:
        )

        raise "Team #{team.name} is already registered." if team.active?

        team.activate!(token)
      else
        client = Slack::Web::Client.new(token: token)
        user_info = client.users_info(user: user_id).user.profile
        user = User.create_with(
                      id: SecureRandom.uuid,
                      email_address: user_info.email,
                      name: user_info.real_name,
                      password: SecureRandom.uuid,
                      slack_id: user_id)
                   .find_or_create_by!(slack_id: user_id)

        Team.create!(
          id: SecureRandom.uuid,
          user:,
          token:,
          oauth_version: :v2,
          oauth_scope:,
          team_id:,
          name: team_name,
          activated_user_id: user_id,
          activated_user_access_token: access_token,
          bot_user_id:
        )

        redirect_to root_path, notice: "Team created!"
      end
    end
  end
end
