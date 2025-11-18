class Deal < ApplicationRecord
  belongs_to :buyer_profile
  belongs_to :listing
  
  has_many :deal_history_events, dependent: :destroy
  
  # Enums
  enum status: {
    favorited: 0, to_contact: 1, info_exchange: 2, analysis: 3,
    project_alignment: 4, negotiation: 5, loi: 6, audits: 7,
    financing: 8, signed: 9, released: 10, abandoned: 11
  }
  
  # Validations
  validates :buyer_profile_id, presence: true
  validates :listing_id, presence: true
  validates :buyer_profile_id, uniqueness: { scope: :listing_id, conditions: -> { where(released_at: nil) } }
  
  # Scopes
  scope :active, -> { where(released_at: nil) }
  scope :reserved_deals, -> { where(reserved: true) }
  scope :by_status, ->(status) { where(status: status) }
  
  # Callbacks
  after_update :track_status_change, if: :saved_change_to_status?
  
  # Instance methods
  def reserve!
    update!(reserved: true, reserved_at: Time.current, reserved_until: calculate_reserved_until)
  end
  
  def release!(reason = nil)
    credits_earned = calculate_release_credits
    update!(
      released_at: Time.current,
      release_reason: reason,
      total_credits_earned: credits_earned
    )
    buyer_profile.add_credits(credits_earned)
  end
  
  def timer_expired?
    reserved_until.present? && reserved_until < Time.current
  end
  
  private
  
  def calculate_reserved_until
    case status
    when 'to_contact'
      7.days.from_now
    when 'info_exchange', 'analysis', 'project_alignment'
      33.days.from_now
    when 'negotiation'
      20.days.from_now
    else
      nil
    end
  end
  
  def calculate_release_credits
    base_credit = 1
    doc_credits = enrichments.where(validated: true).count
    base_credit + doc_credits
  end
  
  def track_status_change
    deal_history_events.create!(
      event_type: :status_change,
      from_status: status_before_last_save,
      to_status: status,
      user_id: buyer_profile.user_id
    )
  end
end
