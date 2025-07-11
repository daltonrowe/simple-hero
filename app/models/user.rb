class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :teams
  has_many :slack_users
  has_many :seats, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def display_name
    self.name || self.email_address.split("@")[0]
  end

  def all_teams
    [ *self.teams, *self.seats.map { |seat| seat.team } ]
  end

  def all_alone?
    all_teams.empty?
  end

  def multiple_teams?
    all_teams.length > 1
  end

  def member_of?(team)
    self == team.user || self.seats.where(team:).any?
  end

  def owns?(team)
    self == team.user
  end

  def default_team
    self&.teams&.first || self&.seats&.first&.team
  end

  def pending_seats
    PendingSeat.where(email_address: self.email_address)
  end

  def unconfirmed?
    self.confirmed_at.nil?
  end

  def confirmed?
    !unconfirmed?
  end
end
