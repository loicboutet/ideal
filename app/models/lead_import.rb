class LeadImport < ApplicationRecord
  belongs_to :imported_by, class_name: 'User'
  
  enum :import_status, { pending: 0, processing: 1, completed: 2, failed: 3 }
  
  validates :imported_by_id, presence: true
  validates :file_name, presence: true
  validates :total_rows, presence: true, numericality: { greater_than: 0 }
  validates :import_status, presence: true
end
