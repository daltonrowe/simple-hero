require "json"
class StatusesController < ApplicationController
  user_must_have_seat
  before_action :find_fresh_status, only: %i[update]
  before_action :ensure_one_status, only: %i[create]

  def index
    @date = Time.zone.parse(params[:date]).end_of_day if params[:date].present?

    if @date
      @team_statuses = @team.previous_statuses(before: @date, after: @date - 1.day)
    else
      recent_statuses = @team&.most_recent_statuses

      if recent_statuses.any?
        @date = recent_statuses[0].created_at.end_of_day
        @team_statuses = recent_statuses.select { |s| s.created_at.between?(@date - 1.day, @date) }
      end
    end

    @next = (@date + 1.day).end_of_day
    @prev = (@date - 1.day).end_of_day
  end

  def new
    @pending_seats = Current.user.pending_seats
    @team_statuses = @team&.current_statuses
    @status = @team_statuses&.where(user: Current.user)&.first
    @draft_status = draft_status

    render layout: "wide"
  end
  def create
    status = Status.new(user: Current.user, team: @team, id: SecureRandom.uuid)
    status.update_sections(params[:sections])

    if status.save
      cookies.delete :draft_status
      redirect_to new_team_status_path(@team), notice: "Status saved!"
    else
      redirect_to new_team_status_path(@team), alert: "Something went wrong."
    end
  end

  def update
    @status.update_sections(params[:sections])

    if @status.save
      redirect_to new_team_status_path(@team), notice: "Status saved!"
    else
      redirect_to new_team_status_path(@team), alert: "Something went wrong."
    end
  end

  def draft
    status = Status.new(user: Current.user, team: @team, id: SecureRandom.uuid)
    status.update_sections(params[:sections])

    cookies[:draft_status] = status.sections.to_json
    redirect_to new_team_status_path(@team), notice: "Draft saved!"
  end

  private

  def find_fresh_status
    @status = Status.find(params[:id])
    redirect_back fallback_location: dashboard_path, alert: "Status too old, cannot be updated." unless @status.fresh?
  end

  def draft_status
    draft_status = Status.new(team: @team, user: Current.user, id: SecureRandom.uuid)

    if cookies[:draft_status]
      cookie_data = JSON.parse cookies[:draft_status]
      draft_status.import_draft(cookie_data)
    end

    draft_status
  end

  def ensure_one_status
    @team_statuses = @team&.current_statuses
    @status = @team_statuses&.where(user: Current.user)&.first

    redirect_back fallback_location: dashboard_path, alert: "Only one status per day please." if @status&.fresh?
  end
end
