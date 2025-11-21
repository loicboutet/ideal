class ListingPush < ApplicationRecord
  belongs_to :listing
  belongs_to :buyer_profile
  belongs_to :seller_profile
  
  # Validations
  validates :listing_id, presence: true
  validates :buyer_profile_id, presence: true
  validates :seller_profile_id, presence: true
  validates :pushed_at, presence: true
  
  # Prevent duplicate pushes
  validates :listing_id, uniqueness: { 
    scope: [:buyer_profile_id, :seller_profile_id],
    message: "a déjà été proposée à ce repreneur" 
  }
  
  # Scopes
  scope :recent, -> { order(pushed_at: :desc) }
  scope :for_buyer, ->(buyer_profile_id) { where(buyer_profile_id: buyer_profile_id) }
  scope :for_seller, ->(seller_profile_id) { where(seller_profile_id: seller_profile_id) }
  scope :for_listing, ->(listing_id) { where(listing_id: listing_id) }
  
  # Callbacks
  before_validation :set_pushed_at, on: :create
  before_create :check_credit_balance
  after_create :deduct_push_credit
  
  private
  
  def set_pushed_at
    self.pushed_at ||= Time.current
  end
  
  def check_credit_balance
    unless Payment::CreditService.has_sufficient_credits?(seller_profile.user, 1)
      errors.add(:base, "Crédits insuffisants pour pousser cette annonce")
      throw(:abort)
    end
  end
  
  def deduct_push_credit
    Payment::CreditService.deduct_push_credits(self)
  rescue Payment::CreditService::InsufficientCreditsError => e
    Rails.logger.error "Failed to deduct push credits: #{e.message}"
    # Don't fail the push creation if credit deduction fails after validation
  end
end
