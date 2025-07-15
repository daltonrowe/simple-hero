class AddSlackInstallations < ActiveRecord::Migration[8.0]
  def change
    create_table :slack_installations, id: :string do |t|
      t.belongs_to :user, null: true, foreign_key: true, type: :string
      t.string :slack_team_id
      t.string :name
      t.string :domain
      t.string :token
      t.string :oauth_scope
      t.string :oauth_version, default: 'v2', null: false
      t.string :bot_user_id
      t.string :activated_user_id
      t.string :activated_user_access_token
      t.boolean :active, default: true
      t.timestamps
    end

    add_reference :teams, :slack_installation, null: true, foreign_key: true, type: :string
  end
end
