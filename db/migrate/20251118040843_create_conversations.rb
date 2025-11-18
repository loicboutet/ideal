class CreateConversations < ActiveRecord::Migration[8.0]
  def change
    create_table :conversations do |t|
      t.references :listing, null: true, foreign_key: true
      t.string :subject

      t.timestamps
    end
  end
end
