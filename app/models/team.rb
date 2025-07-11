class Team < ApplicationRecord
  belongs_to :slack_installation, optional: true
  belongs_to :user
  has_many :seats, dependent: :destroy
  has_many :pending_seats, dependent: :destroy

  validates :name, presence: true, length: { maximum: 120 }

  alias_attribute :original_end_of_day, :end_of_day
  alias_attribute :original_notifaction_time, :notifaction_time

  # metadata json:
  # ticket_link
  # slack_webhook

  def end_of_day
    self.original_end_of_day
      .change({
        year: Time.zone.now.year,
        month: Time.zone.now.month,
        day: Time.zone.now.day
      })
  end

  def notifaction_time
    self.original_notifaction_time
      .change({
        year: Time.zone.now.year,
        month: Time.zone.now.month,
        day: Time.zone.now.day
      })
  end

  def previous_cutoff
    next_cutoff - 1.day
  end

  def next_cutoff
    cutoff_date = Time.zone.now.change(
      { hour: self.end_of_day.hour, minutes: self.end_of_day.min }
    )

    if Time.zone.now >= cutoff_date
      cutoff_date + 1.day
    else
      cutoff_date
    end
  end

  def current_statuses
    Status.where(
      team: self,
      created_at: self.previous_cutoff..self.next_cutoff
    ).order(created_at: :desc)
  end

  def previous_statuses(before:, after:)
    Status.where(
      team: self,
      created_at: after..before
    ).order(created_at: :desc)
  end

  def most_recent_statuses
    Status.where(
      team: self,
    ).order(created_at: :desc).limit(member_count)
  end

  def pending_seats_for(user)
    self.pending_seats.find_by(email_address: user.email_address)
  end

  def member_count
    self.seats.length + 1
  end
end
