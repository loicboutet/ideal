class PartnerContact < ApplicationRecord
  belongs_to :partner_profile
  belongs_to :user
  
  enum :contact_type, { view: 0, contact: 1, directory_contact: 2 }
  
  validates :partner_profile_id, presence: true
  validates :user_id, presence: true
  validates :contact_type, presence: true
  
  # Callbacks - only for actual contacts, not views
  before_create :check_credit_balance, if: :requires_credits?
  after_create :deduct_contact_credit, if: :requires_credits?
  
  private
  
  def requires_credits?
    # Only charge for actual contacts (not views), and only after 6 months
    contact? && user.created_at <= 6.months.ago
  end
  
  def check_credit_balance
    required_credits = 5
    unless Payment::CreditService.has_sufficient_credits?(user, required_credits)
      errors.add(:base, "Crédits insuffisants pour contacter ce partenaire (#{required_credits} crédits requis)")
      throw(:abort)
    end
  end
  
  def deduct_contact_credit
    Payment::CreditService.deduct_partner_contact_credits(user, partner_profile)
  rescue Payment::CreditService::InsufficientCreditsError => e
    Rails.logger.error "Failed to deduct partner contact credits: #{e.message}"
    # Don't fail the contact creation if credit deduction fails after validation
  end
end
