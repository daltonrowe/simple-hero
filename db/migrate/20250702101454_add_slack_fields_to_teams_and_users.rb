class AddSlackFieldsToTeamsAndUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :teams, :team_id, :string
    add_column :teams, :domain, :string
    add_column :teams, :token, :string
    add_column :teams, :oauth_scope, :string
    add_column :teams, :oauth_version, :string, null: false, default: 'v1'
    add_column :teams, :bot_user_id, :string
    add_column :teams, :activated_user_id, :string
    add_column :teams, :activated_user_access_token, :string
    add_column :teams, :active, :boolean, default: true

    add_column :users, :slack_id, :string
  end
end
