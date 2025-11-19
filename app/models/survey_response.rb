class SurveyResponse < ApplicationRecord
  belongs_to :survey
  belongs_to :user
  
  validates :user_id, uniqueness: { scope: :survey_id }
  
  before_save :set_submitted_at, if: -> { answers.present? && submitted_at.nil? }
  
  private
  
  def set_submitted_at
    self.submitted_at = Time.current
  end
end
