# frozen_string_literal: true

module BlockFormatter
  module_function

  def block_for_statuses(statuses, show_actions: false)
    block = [ title_section, divider ]
    statuses.each do |status|
      block << header_for_user(status.user.slack_id)
      block = block + status_section(status, show_actions:)
    end
    block
  end

  def header_for_user(user_id)
    title = user_id.include?("@") ? user_id : "<@#{user_id}>"
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": title
      }
    }
  end

  def status_section(status, show_actions: false)
    section = []
    status.sections.each do |s|
      section << section_details(s)
    end
    section << edit_button(status) if show_actions
    section << divider
    section
  end

  def section_details(status_section)
    text = "*#{status_section["name"]}:* "

    status_section["content"].each do |line|
      text += "\n #{line}"
    end

    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": text
      }
    }
  end

  def date_range(start_time, end_time)
    "#{date_string(start_time)} - #{date_string(end_time)}"
  end

  def date_string(time)
    time.strftime("%A, %B %-d")
  end

  def title_section(text = "*Statuses For Today*")
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": text
      }
    }
  end

  def divider
    { "type": "divider" }
  end

  def edit_button(status)
    {
      "type": "actions",
      "elements": [
        {
          "type": "button",
          "text": {
            "type": "plain_text",
            "text": "Edit",
            "emoji": true
          },
          "value": status.id.to_s,
          "action_id": "edit-status"
        }
      ]
    }
  end
end
