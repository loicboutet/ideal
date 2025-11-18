class ListingDocument < ApplicationRecord
  belongs_to :listing
  belongs_to :uploaded_by, class_name: 'User'
  
  enum :document_category, {
    balance_n1: 0, balance_n2: 1, balance_n3: 2, org_chart: 3,
    tax_return: 4, income_statement: 5, vehicle_list: 6, lease: 7,
    property_title: 8, scorecard: 9, other: 10
  }
  
  validates :listing_id, presence: true
  validates :uploaded_by_id, presence: true
  validates :document_category, presence: true
  validates :title, presence: true
  validates :file_name, presence: true
end
