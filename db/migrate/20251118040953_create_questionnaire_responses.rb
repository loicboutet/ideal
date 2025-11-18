class CreateQuestionnaireResponses < ActiveRecord::Migration[8.0]
  def change
    create_table :questionnaire_responses do |t|
      t.references :questionnaire, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      
      t.text :answers, null: false
      t.datetime :completed_at, null: false

      t.timestamps
    end
    
    add_index :questionnaire_responses, [:questionnaire_id, :user_id]
  end
end
