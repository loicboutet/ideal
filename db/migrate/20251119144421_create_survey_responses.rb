class CreateSurveyResponses < ActiveRecord::Migration[8.0]
  def change
    create_table :survey_responses do |t|
      t.references :survey, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.json :answers
      t.integer :satisfaction_score
      t.datetime :submitted_at

      t.timestamps
    end
    
    add_index :survey_responses, [:survey_id, :user_id], unique: true
  end
end
