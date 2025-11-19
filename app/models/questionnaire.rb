class Questionnaire < ApplicationRecord
  belongs_to :created_by, class_name: 'User'
  
  has_many :questionnaire_responses, dependent: :destroy
  
  enum :questionnaire_type, { satisfaction: 0, development: 1 }
  enum :target_role, { all_roles: 0, seller: 1, buyer: 2, partner: 3 }
  
  serialize :questions, type: Array, coder: JSON
  
  validates :title, presence: true
  validates :questionnaire_type, presence: true
  validates :questions, presence: true
  validates :created_by_id, presence: true
  
  scope :active_questionnaires, -> { where(active: true) }
end
