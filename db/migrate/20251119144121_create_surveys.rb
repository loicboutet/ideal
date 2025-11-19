class CreateSurveys < ActiveRecord::Migration[8.0]
  def change
    create_table :surveys do |t|
      t.references :admin_message, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.integer :survey_type, default: 0, null: false
      t.json :questions
      t.boolean :active, default: true
      t.datetime :starts_at
      t.datetime :ends_at

      t.timestamps
    end
    
    add_index :surveys, :survey_type
    add_index :surveys, :active
  end
end
