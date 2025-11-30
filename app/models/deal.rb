class Deal < ApplicationRecord
  include DealTimer
  
  belongs_to :buyer_profile
  belongs_to :listing
  
  has_many :deal_history_events, dependent: :destroy
  
  # Enums
  enum :status, {
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
  before_save :update_timer_on_status_change, if: :status_changed?
  after_update :track_status_change, if: :saved_change_to_status?
  
  # Instance methods
  def enrichments
    listing.enrichments.where(buyer_profile_id: buyer_profile_id)
  end
  
  def reserve!
    update!(reserved: true, reserved_at: Time.current, reserved_until: calculate_reserved_until)
  end
  
  def release!(reason = nil)
    credits_earned = calculate_release_credits
    
    transaction do
      update!(
        released_at: Time.current,
        release_reason: reason,
        total_credits_earned: credits_earned
      )
      
      # Award credits using the centralized credit service
      # Note: CreditService will check if deal was actually reserved before awarding
      Payment::CreditService.award_deal_release_credits(self)
    end
  end
  
  # Timer expiry is now handled by DealTimer concern
  
  # Check if deal was actually reserved (moved beyond favorited stage)
  # Used to determine if credits should be awarded on release
  def was_reserved?
    # A deal is considered "reserved" if:
    # 1. It has the reserved flag set to true, OR
    # 2. Its current status is beyond "favorited" (meaning it progressed in the pipeline)
    return true if reserved?
    
    # Check if current status is beyond favorited but not in terminal states
    current_status_value = Deal.statuses[status]
    return true if current_status_value > 0 && current_status_value < Deal.statuses[:released]
    
    # Check history for any status beyond favorited
    deal_history_events
      .where(event_type: :status_change)
      .where.not(to_status: [:favorited, :released, :abandoned])
      .exists?
  end
  
  def calculate_release_credits
    # No credits for deals that were only favorited, never reserved
    return 0 unless was_reserved?
    
    base_credit = 1
    # Count validated enrichments for this listing by this buyer
    doc_credits = listing.enrichments
      .where(buyer_profile_id: buyer_profile_id, validated: true)
      .count
    base_credit + doc_credits
  end
  
  private
  
  def track_status_change
    deal_history_events.create!(
      event_type: :status_change,
      from_status: status_before_last_save,
      to_status: status,
      user_id: buyer_profile.user_id
    )
  end
end
