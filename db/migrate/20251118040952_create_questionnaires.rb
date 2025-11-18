class CreateQuestionnaires < ActiveRecord::Migration[8.0]
  def change
    create_table :questionnaires do |t|
      t.string :title, null: false
      t.text :description
      t.integer :questionnaire_type, null: false
      t.text :questions, null: false
      t.integer :target_role
      t.boolean :active, default: true, null: false
      t.references :created_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
    
    add_index :questionnaires, :questionnaire_type
    add_index :questionnaires, :active
  end
end
