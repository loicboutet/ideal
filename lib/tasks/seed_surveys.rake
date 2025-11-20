namespace :db do
  namespace :seed do
    desc "Seed surveys and responses for testing"
    task surveys: :environment do
      puts "🌱 Seeding surveys and responses..."

      # Find or create admin user
      admin = User.find_by(role: 'admin', email: 'admin@ideal.fr')
      unless admin
        admin = User.create!(
          email: 'admin@ideal.fr',
          password: 'password123',
          password_confirmation: 'password123',
          role: 'admin',
          status: 'active',
          first_name: 'Admin',
          last_name: 'User'
        )
        puts "  Created admin user"
      end

      # Create satisfaction survey
      satisfaction_message = AdminMessage.create!(
        subject: 'Votre avis compte - Enquête de satisfaction',
        body: 'Nous aimerions connaître votre avis sur votre expérience avec Idéal Reprise. Prenez quelques minutes pour répondre à notre enquête de satisfaction.',
        message_type: 'survey',
        target_role: 'all_roles',
        sent_by: admin
      )

      satisfaction_survey = Survey.create!(
        title: 'Enquête de satisfaction Q4 2025',
        description: 'Aidez-nous à améliorer notre plateforme en partageant votre expérience',
        survey_type: 'satisfaction',
        active: true,
        admin_message: satisfaction_message
      )

      # Create development survey
      development_message = AdminMessage.create!(
        subject: 'Questionnaire de développement - Nouvelles fonctionnalités',
        body: 'Nous développons de nouvelles fonctionnalités et aimerions connaître vos besoins. Ce questionnaire vous prendra environ 5 minutes.',
        message_type: 'survey',
        target_role: 'all_roles',
        sent_by: admin
      )

      questions = [
        {
          id: 1,
          type: 'multiple_choice',
          text: 'Quelle fonctionnalité vous intéresserait le plus ?',
          options: [
            'Analyse de marché automatisée',
            'Recommandations de repreneurs',
            'Outils de valorisation d\'entreprise',
            'Formation en ligne'
          ],
          required: true
        },
        {
          id: 2,
          type: 'rating',
          text: 'Comment évaluez-vous la facilité d\'utilisation de la plateforme ?',
          required: true
        },
        {
          id: 3,
          type: 'yes_no',
          text: 'Seriez-vous intéressé par un accompagnement personnalisé ?',
          required: true
        },
        {
          id: 4,
          type: 'textarea',
          text: 'Quelles améliorations souhaiteriez-vous voir sur la plateforme ?',
          required: false
        }
      ]

      development_survey = Survey.create!(
        title: 'Questionnaire de développement - Futures fonctionnalités',
        description: 'Aidez-nous à prioriser les nouvelles fonctionnalités',
        survey_type: 'development',
        questions: questions.to_json,
        active: true,
        admin_message: development_message
      )

      puts "  ✓ Created #{Survey.count} surveys"

      # Send messages to users
      active_users = User.where(status: 'active').where.not(role: 'admin')
      
      active_users.each do |user|
        # Create recipient for satisfaction survey
        MessageRecipient.find_or_create_by!(
          admin_message: satisfaction_message,
          user: user
        )

        # Create recipient for development survey
        MessageRecipient.find_or_create_by!(
          admin_message: development_message,
          user: user
        )
      end

      puts "  ✓ Created message recipients for #{active_users.count} users"

      # Create sample responses for satisfaction survey
      sample_users = active_users.sample([active_users.count / 2, 10].max)
      
      sample_users.each do |user|
        score = [3, 4, 4, 4, 5, 5, 5].sample
        comment = case score
        when 5
          ['Excellente plateforme !', 'Très satisfait du service', 'Interface intuitive et efficace', nil].sample
        when 4
          ['Bonne expérience globale', 'Quelques améliorations possibles', nil].sample
        when 3
          ['Correcte mais peut mieux faire', 'Quelques bugs à corriger'].sample
        else
          ['Déçu de certaines fonctionnalités', 'Besoin d\'améliorations'].sample
        end

        answers = comment ? { comment: comment }.to_json : nil

        SurveyResponse.create!(
          survey: satisfaction_survey,
          user: user,
          satisfaction_score: score,
          answers: answers
        )
      end

      puts "  ✓ Created #{SurveyResponse.count} survey responses"

      # Create some development survey responses
      dev_respondents = active_users.sample([active_users.count / 3, 5].max)
      
      dev_respondents.each do |user|
        answers = {
          'q0' => ['Analyse de marché automatisée', 'Recommandations de repreneurs', 'Outils de valorisation d\'entreprise', 'Formation en ligne'].sample,
          'q1' => rand(3..5).to_s,
          'q2' => ['Oui', 'Non'].sample,
          'q3' => ['Interface plus moderne', 'Plus de statistiques', 'Notifications améliorées', nil].sample
        }.compact

        SurveyResponse.create!(
          survey: development_survey,
          user: user,
          answers: answers.to_json
        )
      end

      puts "  ✓ Created #{SurveyResponse.where(survey: development_survey).count} development survey responses"
      puts "✅ Survey seeding completed!"
      puts ""
      puts "Summary:"
      puts "  - Surveys: #{Survey.count}"
      puts "  - Total Responses: #{SurveyResponse.count}"
      puts "  - Satisfaction Average: #{SurveyResponse.where(survey: satisfaction_survey).average(:satisfaction_score)&.round(2) || 'N/A'}"
    end
  end
end
