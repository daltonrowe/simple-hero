module Slack
  module Commands
    class BaseController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :authenticate_slack_request!
      before_action :set_team

      allow_unauthenticated_access

      def authenticate_slack_request!
        Slack::Events::Request.new(request).verify!
      rescue
        render json: { error: "Invalid Signature" }, status: 401
      end

      def set_team
        @team = Team.find_by(team_id: params[:team_id])

        render json: { error: "Could not find team: #{params[:team_id]}" }, status: 404 unless @team
      end

      def set_user
        @user = User.find_by(slack_id: params[:user_id])

        render json: { error: "Could not find user: #{params[:user_id]}" }, status: 404 unless @user
      end

      def slack_client
        @slack_client ||= Slack::Web::Client.new({ token: @team.token })
      end
    end
  end
end
