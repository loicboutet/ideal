# frozen_string_literal: true

module Admin
  class SurveysController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_admin!
    before_action :set_survey, only: [:show, :edit, :update, :destroy, :export]

    def index
      @surveys = Survey.includes(:admin_message).order(created_at: :desc)
      @active_surveys = Survey.active.current
      @satisfaction_avg = calculate_satisfaction_average
    end

    def show
      @response_stats = calculate_response_stats
      @question_results = calculate_question_results if @survey.development?
    end

    def new
      @survey = Survey.new
      @admin_message = AdminMessage.new
    end

    def create
      @admin_message = AdminMessage.new(admin_message_params)
      @admin_message.sent_by = current_user
      
      if @admin_message.save
        @survey = @admin_message.build_survey(survey_params)
        
        if @survey.save
          # Send the survey via admin message system
          send_survey_to_recipients
          
          redirect_to admin_survey_path(@survey), notice: 'Questionnaire créé et envoyé avec succès.'
        else
          render :new, status: :unprocessable_entity
        end
      else
        @survey = Survey.new(survey_params)
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @admin_message = @survey.admin_message
    end

    def update
      @admin_message = @survey.admin_message
      
      if @admin_message.update(admin_message_params) && @survey.update(survey_params)
        redirect_to admin_survey_path(@survey), notice: 'Questionnaire mis à jour avec succès.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @survey.destroy
      redirect_to admin_surveys_path, notice: 'Questionnaire supprimé avec succès.'
    end

    def export
      require 'csv'
      
      csv_data = CSV.generate(headers: true) do |csv|
        # Headers
        headers = ['User ID', 'Email', 'Nom', 'Role', 'Date de réponse']
        
        if @survey.satisfaction?
          headers << 'Score de satisfaction'
          headers << 'Commentaire'
        else
          # Add question headers
          questions = JSON.parse(@survey.questions || '[]')
          questions.each_with_index do |q, i|
            headers << "Q#{i + 1}: #{q['text']}"
          end
        end
        
        csv << headers
        
        # Data rows
        @survey.survey_responses.includes(:user).each do |response|
          row = [
            response.user_id,
            response.user.email,
            "#{response.user.first_name} #{response.user.last_name}".strip,
            I18n.t("user.roles.#{response.user.role}", default: response.user.role.humanize),
            response.submitted_at&.strftime('%d/%m/%Y %H:%M')
          ]
          
          if @survey.satisfaction?
            row << response.satisfaction_score
            answers = JSON.parse(response.answers || '{}')
            row << (answers['comment'] || '')
          else
            answers = JSON.parse(response.answers || '{}')
            questions = JSON.parse(@survey.questions || '[]')
            questions.each_with_index do |_, i|
              row << (answers["q#{i}"] || '')
            end
          end
          
          csv << row
        end
      end
      
      send_data csv_data, 
                filename: "survey_#{@survey.id}_responses_#{Date.current.strftime('%Y%m%d')}.csv",
                type: 'text/csv',
                disposition: 'attachment'
    end

    private

    def set_survey
      @survey = Survey.find(params[:id])
    end

    def survey_params
      params.require(:survey).permit(
        :title,
        :description,
        :survey_type,
        :questions,
        :active,
        :starts_at,
        :ends_at
      )
    end

    def admin_message_params
      params.require(:admin_message).permit(
        :subject,
        :body,
        :message_type,
        :target_role,
        recipient_ids: []
      )
    end

    def ensure_admin!
      unless current_user.admin?
        redirect_to root_path, alert: "Accès non autorisé."
      end
    end

    def send_survey_to_recipients
      # The admin message system will handle sending
      # Recipients will see the survey in their dashboard via the message
      SendAdminMessageJob.perform_later(@admin_message.id)
    end

    def calculate_satisfaction_average
      total_responses = SurveyResponse.joins(:survey)
                                      .where(surveys: { survey_type: :satisfaction })
                                      .count
      
      return 0 if total_responses.zero?
      
      avg = SurveyResponse.joins(:survey)
                          .where(surveys: { survey_type: :satisfaction })
                          .average(:satisfaction_score)
      
      (avg || 0).round(1)
    end

    def calculate_response_stats
      total_recipients = @survey.admin_message.recipients_count
      total_responses = @survey.survey_responses.count
      
      {
        total_recipients: total_recipients,
        total_responses: total_responses,
        response_rate: total_recipients.zero? ? 0 : (total_responses.to_f / total_recipients * 100).round(1),
        average_satisfaction: @survey.satisfaction? ? @survey.average_satisfaction : nil
      }
    end

    def calculate_question_results
      return [] unless @survey.questions.present?
      
      questions = JSON.parse(@survey.questions)
      responses = @survey.survey_responses
      
      questions.map.with_index do |question, index|
        answers = responses.map do |response|
          parsed_answers = JSON.parse(response.answers || '{}')
          parsed_answers["q#{index}"]
        end.compact
        
        result = {
          question: question['text'],
          type: question['type'],
          total_responses: answers.count
        }
        
        case question['type']
        when 'multiple_choice', 'yes_no'
          # Count occurrences of each answer
          result[:distribution] = answers.group_by(&:itself).transform_values(&:count)
        when 'rating'
          # Calculate average rating
          numeric_answers = answers.map(&:to_i)
          result[:average] = numeric_answers.any? ? (numeric_answers.sum.to_f / numeric_answers.count).round(1) : 0
          result[:distribution] = numeric_answers.group_by(&:itself).transform_values(&:count)
        when 'text', 'textarea'
          # Just list the text responses
          result[:responses] = answers
        when 'checkbox'
          # Multiple selections - flatten and count
          all_selections = answers.flat_map { |a| a.is_a?(Array) ? a : [a] }
          result[:distribution] = all_selections.group_by(&:itself).transform_values(&:count)
        end
        
        result
      end
    end
  end
end
