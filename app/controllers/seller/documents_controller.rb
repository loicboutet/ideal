class Seller::DocumentsController < ApplicationController
  layout 'seller'
  
  before_action :authenticate_user!
  before_action :authorize_seller!
  before_action :set_listing
  before_action :set_document, only: [:show, :edit, :update, :destroy]
  
  def new
    @listing_document = @listing.listing_documents.build
  end
  
  def create
    @listing_document = @listing.listing_documents.build(listing_document_params)
    @listing_document.uploaded_by = current_user
    
    if @listing_document.save
      redirect_to seller_listing_path(@listing), 
                  notice: 'Document ajouté avec succès.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def show
    # Download the document
    if @listing_document.file.attached?
      redirect_to rails_blob_path(@listing_document.file, disposition: "attachment")
    else
      redirect_to seller_listing_path(@listing), 
                  alert: 'Fichier non disponible.'
    end
  end
  
  def edit
  end
  
  def update
    if @listing_document.update(listing_document_params)
      redirect_to seller_listing_path(@listing), 
                  notice: 'Document mis à jour avec succès.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @listing_document.destroy
    redirect_to seller_listing_path(@listing), 
                notice: 'Document supprimé avec succès.'
  end
  
  private
  
  def set_listing
    @listing = current_user.seller_profile.listings.find(params[:listing_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to seller_listings_path, alert: 'Annonce introuvable.'
  end
  
  def set_document
    @listing_document = @listing.listing_documents.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to seller_listing_path(@listing), alert: 'Document introuvable.'
  end
  
  def authorize_seller!
    unless current_user&.seller_profile
      redirect_to root_path, alert: 'Accès refusé. Privilèges de cédant requis.'
    end
  end
  
  def listing_document_params
    params.require(:listing_document).permit(
      :document_category, 
      :title, 
      :description, 
      :file,
      :not_applicable
    )
  end
end
