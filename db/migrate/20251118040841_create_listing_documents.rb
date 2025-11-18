class CreateListingDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :listing_documents do |t|
      t.references :listing, null: false, foreign_key: true
      t.references :uploaded_by, null: false, foreign_key: { to_table: :users }
      
      t.integer :document_category, null: false
      t.string :title, null: false
      t.text :description
      t.string :file_name, null: false
      t.string :file_path, null: false
      t.integer :file_size, null: false
      t.string :content_type, null: false
      t.boolean :not_applicable, default: false, null: false
      t.boolean :nda_required, default: true, null: false
      t.boolean :validated_by_seller, default: true, null: false

      t.timestamps
    end
    
    add_index :listing_documents, :document_category
    add_index :listing_documents, [:listing_id, :document_category]
  end
end
