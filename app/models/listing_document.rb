class ListingDocument < ApplicationRecord
  belongs_to :listing
  belongs_to :uploaded_by, class_name: 'User'
  
  has_one_attached :file
  
  enum :document_category, {
    balance_n1: 0, balance_n2: 1, balance_n3: 2, org_chart: 3,
    tax_return: 4, income_statement: 5, vehicle_list: 6, lease: 7,
    property_title: 8, scorecard: 9, other: 10
  }
  
  # Callbacks to populate file metadata from Active Storage
  before_validation :set_file_metadata, if: -> { file.attached? }
  
  validates :listing_id, presence: true
  validates :uploaded_by_id, presence: true
  validates :document_category, presence: true
  validates :title, presence: true
  validates :file, presence: true, unless: :not_applicable?
  
  # French labels for document categories
  def self.category_options
    [
      ['Bilan N-1', 'balance_n1'],
      ['Bilan N-2', 'balance_n2'],
      ['Bilan N-3', 'balance_n3'],
      ['Organigramme', 'org_chart'],
      ['Liasse fiscale', 'tax_return'],
      ['Compte de résultat', 'income_statement'],
      ['Liste véhicules et matériel lourd', 'vehicle_list'],
      ['Bail', 'lease'],
      ['Titre de propriété', 'property_title'],
      ['Rapport Scorecard', 'scorecard'],
      ['Autre (à spécifier)', 'other']
    ]
  end
  
  def category_label
    self.class.category_options.find { |label, value| value == document_category.to_s }&.first || document_category.humanize
  end
  
  private
  
  def set_file_metadata
    self.file_name = file.filename.to_s
    self.file_path = file.key
    self.file_size = file.byte_size
    self.content_type = file.content_type
  end
end
