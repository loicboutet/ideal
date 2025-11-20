class CreditTransaction < ApplicationRecord
  belongs_to :seller_profile
  belongs_to :source, polymorphic: true, optional: true
  
  # Transaction types enum
  enum :transaction_type, {
    deal_release: 0,           # Earned from buyer releasing deal
    enrichment_validated: 1,   # Earned from validated enrichment
    push_to_buyer: 2,          # Spent pushing listing
    partner_contact: 3,        # Spent contacting partner
    admin_adjustment: 4,       # Manual admin adjustment
    purchase: 5                # Credit pack purchase (future)
  }
  
  # Validations
  validates :amount, presence: true, numericality: { other_than: 0 }
  validates :transaction_type, presence: true
  validates :balance_after, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  # Scopes
  scope :earned, -> { where('amount > 0') }
  scope :spent, -> { where('amount < 0') }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(transaction_type: type) }
  scope :this_month, -> { where('created_at >= ?', Time.current.beginning_of_month) }
  
  # Callbacks
  after_create :send_notification
  
  # Instance methods
  def earned?
    amount > 0
  end
  
  def spent?
    amount < 0
  end
  
  def absolute_amount
    amount.abs
  end
  
  def source_description
    return description if description.present?
    
    case transaction_type.to_sym
    when :deal_release
      "Dossier libéré par l'acheteur"
    when :enrichment_validated
      "Document validé par le cédant"
    when :push_to_buyer
      "Annonce poussée à un acheteur"
    when :partner_contact
      "Contact avec un partenaire"
    when :admin_adjustment
      "Ajustement administrateur"
    when :purchase
      "Achat de crédits"
    else
      "Transaction"
    end
  end
  
  private
  
  def send_notification
    return unless earned?
    
    Notification.create!(
      user: seller_profile.user,
      notification_type: :credit_earned,
      title: "Crédits gagnés",
      message: "Vous avez gagné #{absolute_amount} crédit(s) : #{source_description}",
      link_url: Rails.application.routes.url_helpers.seller_credits_path
    )
  end
end
