module Slack
  module Commands
    class BaseController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :authenticate_slack_request!
      before_action :set_slack_installation

      allow_unauthenticated_access

      def authenticate_slack_request!
        Slack::Events::Request.new(request).verify!
      rescue
        render json: { error: "Invalid Signature" }, status: 401
      end

      def set_slack_installation
        @slack_installation = SlackInstallation.find_by(slack_team_id: params[:team_id])

        render json: { error: "Could not find slack team: #{params[:team_id]}" }, status: 404 unless @slack_installation
      end

      def set_user
        @user = User.find_by(slack_id: params[:user_id])

        render json: { error: "Could not find user: #{params[:user_id]}" }, status: 404 unless @user
      end

      def slack_client
        @slack_client ||= Slack::Web::Client.new({ token: @slack_installation.token })
      end
    end
  end
end
