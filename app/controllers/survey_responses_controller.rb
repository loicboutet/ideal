# frozen_string_literal: true

class SurveyResponsesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_survey, only: [:new, :create]
  before_action :check_already_responded, only: [:new, :create]

  def new
    @survey_response = SurveyResponse.new
    @questions = @survey.questions.present? ? JSON.parse(@survey.questions) : []
  end

  def create
    @survey_response = @survey.survey_responses.build(survey_response_params)
    @survey_response.user = current_user
    @survey_response.submitted_at = Time.current
    
    # For satisfaction surveys, ensure we have a satisfaction_score
    if @survey.satisfaction?
      @survey_response.satisfaction_score = survey_response_params[:satisfaction_score]
    end
    
    if @survey_response.save
      redirect_to survey_response_thank_you_path, notice: 'Merci pour votre réponse !'
    else
      @questions = @survey.questions.present? ? JSON.parse(@survey.questions) : []
      render :new, status: :unprocessable_entity
    end
  end

  def thank_you
    # Simple thank you page
  end

  private

  def set_survey
    @survey = Survey.find(params[:survey_id])
  end

  def check_already_responded
    if @survey.survey_responses.exists?(user: current_user)
      redirect_to root_path, alert: 'Vous avez déjà répondu à ce questionnaire.'
    end
  end

  def survey_response_params
    params.require(:survey_response).permit(:satisfaction_score, :answers)
  end
end
