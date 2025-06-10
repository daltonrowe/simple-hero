require "json"
class StatusesController < ApplicationController
  user_must_have_seat
  before_action :find_fresh_status, only: %i[update]


  def index
    @pending_seats = Current.user.pending_seats
    @team_statuses = @team&.current_statuses
    @status = @team_statuses&.where(user: Current.user)&.first
    @draft_status = draft_status

    render layout: "wide"
  end

  def history
    # TODO: List all statuses in paginated view
    @team_statuses = @team&.previous_statuses(before: "some-date", after: "other-date")
  end

  def create
    status = Status.new(user: Current.user, team: @team, id: SecureRandom.uuid)
    status.update_sections(params[:sections])

    if params[:is_draft]
      cookies[:draft_status] = status.sections.to_json
      return redirect_to team_statuses_path(@team), notice: "Draft saved!"
    end

    if status.save
      delete cookies[:draft_status]
      redirect_to team_statuses_path(@team), notice: "Status saved!"
    else
      redirect_to team_statuses_path(@team), alert: "Something went wrong."
    end
  end

  def update
    @status.update_sections(params[:sections])

    if @status.save
      redirect_to team_statuses_path(@team), notice: "Status saved!"
    else
      redirect_to team_statuses_path(@team), alert: "Something went wrong."
    end
  end

  private

  def find_fresh_status
    @status = Status.find(params[:id])
    redirect_to dashboard_path, alert: "Status too old, cannot be updated." unless @status.fresh?
  end

  def draft_status
    draft_status = Status.new(team: @team, user: Current.user, id: SecureRandom.uuid)

    if cookies[:draft_status]
      cookie_data = JSON.parse cookies[:draft_status]
      draft_status.import_draft(cookie_data)
    end

    draft_status
  end
end
