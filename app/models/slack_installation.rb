class SlackInstallation < ApplicationRecord
  validates_uniqueness_of :token, message: "has already been used"

  has_many :teams, dependent: :destroy
  belongs_to :user, optional: true

  scope :active, -> { where(active: true) }

  def deactivate!
    update!(active: false)
  end

  def activate!(token)
    update!(active: true, token: token)
  end

  def ping!
    client = Slack::Web::Client.new(token: token)

    auth = client.auth_test

    presence = begin
                 client.users_getPresence(user: auth["user_id"])
               rescue Slack::Web::Api::Errors::MissingScope
                 nil
               end

    {
      auth: auth,
      presence: presence
    }
  end

  def ping_if_active!
    return unless active?

    ping!
  rescue Slack::Web::Api::Errors::SlackError => e
    logger.warn "Active team #{self} ping, #{e.message}."
    case e.message
    when "account_inactive", "invalid_auth"
      deactivate!
    end
  end
end
