class PaymentTransaction < ApplicationRecord
  belongs_to :user

  # Transaction types
  enum :transaction_type, {
    subscription_payment: 'subscription_payment',
    credit_purchase: 'credit_purchase',
    credit_award: 'credit_award',
    credit_deduction: 'credit_deduction',
    refund: 'refund'
  }, prefix: true

  # Transaction statuses
  enum :status, {
    pending: 'pending',
    processing: 'processing',
    succeeded: 'succeeded',
    failed: 'failed',
    canceled: 'canceled',
    refunded: 'refunded'
  }, prefix: true

  # Validations
  validates :user_id, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, presence: true
  validates :status, presence: true
  validates :transaction_type, presence: true

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :successful, -> { where(status: 'succeeded') }
  scope :by_type, ->(type) { where(transaction_type: type) }
  scope :this_month, -> { where(created_at: Time.current.beginning_of_month..Time.current.end_of_month) }

  # Store metadata as JSON
  serialize :metadata, coder: JSON

  # Helper methods
  def amount_in_euros
    amount / 100.0
  end

  def successful?
    status == 'succeeded'
  end

  def failed?
    status == 'failed'
  end
end
