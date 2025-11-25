class SubscriptionWebhookLog < ApplicationRecord
  belongs_to :user

  validates :event_id, presence: true, uniqueness: true
  validates :event_type, presence: true
  validates :status, presence: true

  # Scopes for filtering
  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :by_event_type, ->(event_type) { where(event_type: event_type) if event_type.present? }
  scope :by_user, ->(user_id) { where(user_id: user_id) if user_id.present? }
  scope :successful, -> { where(status: 'success') }
  scope :failed, -> { where(status: 'failed') }

  # Parse JSON payload
  def parsed_payload
    return nil if payload.blank?
    JSON.parse(payload)
  rescue JSON::ParserError
    nil
  end

  # Human-readable event type
  def event_type_display
    event_type.to_s.titleize.gsub('.', ' - ')
  end

  # Status badge color
  def status_color
    case status
    when 'success'
      'green'
    when 'failed'
      'red'
    else
      'yellow'
    end
  end
end
