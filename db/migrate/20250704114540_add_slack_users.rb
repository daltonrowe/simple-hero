class AddSlackUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :slack_users, id: :string do |t|
      t.belongs_to :user, null: true, foreign_key: true, type: :string
      t.string :slack_user_id
    end
  end
end
