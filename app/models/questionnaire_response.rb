class QuestionnaireResponse < ApplicationRecord
  belongs_to :questionnaire
  belongs_to :user
  
  serialize :answers, type: Hash, coder: JSON
  
  validates :questionnaire_id, presence: true
  validates :user_id, presence: true
  validates :answers, presence: true
  validates :completed_at, presence: true
end
