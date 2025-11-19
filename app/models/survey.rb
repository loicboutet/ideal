class Survey < ApplicationRecord
  belongs_to :admin_message
  has_many :survey_responses, dependent: :destroy
  
  enum survey_type: { satisfaction: 0, development: 1 }
  
  validates :title, presence: true
  
  scope :active, -> { where(active: true) }
  scope :current, -> { 
    where('starts_at <= ? AND (ends_at IS NULL OR ends_at >= ?)', 
          Time.current, Time.current) 
  }
  
  def response_rate
    return 0 if admin_message.recipients_count.zero?
    (survey_responses.count.to_f / admin_message.recipients_count * 100).round(1)
  end
  
  def average_satisfaction
    return 0 if survey_type != 'satisfaction'
    survey_responses.average(:satisfaction_score)&.round(1) || 0
  end
end
