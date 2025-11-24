class AdminMessage < ApplicationRecord
  belongs_to :sent_by, class_name: 'User'
  has_many :message_recipients, dependent: :destroy
  has_many :recipients, through: :message_recipients, source: :user
  has_one :survey, dependent: :destroy
  
  enum :message_type, { broadcast: 0, direct: 1, survey: 2, questionnaire: 3 }
  enum :target_role, { all_roles: 0, seller: 1, buyer: 2, partner: 3 }
  
  validates :subject, :body, presence: true
  
  scope :sent, -> { where.not(sent_at: nil) }
  scope :unsent, -> { where(sent_at: nil) }
  scope :recent, -> { order(created_at: :desc) }
  
  def mark_as_sent!
    update!(sent_at: Time.current)
  end
  
  def read_count
    message_recipients.where(read: true).count
  end
  
  def unread_count
    message_recipients.where(read: false).count
  end
  
  def read_rate
    return 0 if recipients_count.zero?
    (read_count.to_f / recipients_count * 100).round(1)
  end
end
