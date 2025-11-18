class Enrichment < ApplicationRecord
  belongs_to :buyer_profile
  belongs_to :listing
  belongs_to :validated_by, class_name: 'User', optional: true
  
  enum :document_category, {
    balance_n1: 0, balance_n2: 1, balance_n3: 2, org_chart: 3,
    tax_return: 4, income_statement: 5, vehicle_list: 6, lease: 7,
    property_title: 8, scorecard: 9, other: 10
  }
  
  validates :buyer_profile_id, presence: true
  validates :listing_id, presence: true
  validates :document_category, presence: true
  
  scope :validated_enrichments, -> { where(validated: true) }
  scope :pending, -> { where(validated: false) }
end
