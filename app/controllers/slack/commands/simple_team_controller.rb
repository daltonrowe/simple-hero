require "securerandom"
require "block_formatter"

module Slack
  module Commands
    class SimpleTeamController < BaseController

      def index
        case params[:text]
        when "status"
          render json: list_status
        when "add"
          render json: { response_type: "ephemeral", text: "Not built yet" }
        else
          render json: { response_type: "ephemeral", text: "Unknown option: #{params[:text]}" }
        end
      end

      private

      def list_status
        statuses = @team.current_statuses
        if statuses.empty?
          { response_type: "ephemeral", text: "No statuses have been submitted." }
        else
          {
            response_type: "ephemeral",
            blocks: BlockFormatter.block_for_statuses(statuses)
          }
        end
      end
    end
  end
end
