class Buyer::EnrichmentsController < ApplicationController
  layout 'buyer'
  
  before_action :authenticate_user!
  before_action :authorize_buyer!
  before_action :set_buyer_profile
  before_action :set_enrichment, only: [:show]
  before_action :set_listing, only: [:new, :create]
  
  def index
    @filter = params[:filter] || 'pending'
    
    # Get enrichments for buyer's profile
    @enrichments = @buyer_profile.enrichments.includes(:listing, :validated_by)
    
    case @filter
    when 'pending'
      @enrichments = @enrichments.pending_validation
    when 'approved'
      @enrichments = @enrichments.approved_enrichments
    when 'rejected'
      @enrichments = @enrichments.rejected_enrichments
    end
    
    @enrichments = @enrichments.order(created_at: :desc)
    
    # Stats for dashboard
    @stats = {
      total: @buyer_profile.enrichments.count,
      pending: @buyer_profile.enrichments.pending_validation.count,
      approved: @buyer_profile.enrichments.approved_enrichments.count,
      rejected: @buyer_profile.enrichments.rejected_enrichments.count
    }
  end
  
  def show
    # Display enrichment details
  end
  
  def new
    @enrichment = @buyer_profile.enrichments.build(listing: @listing)
    
    # Get existing enrichments for this listing
    @existing_enrichments = @buyer_profile.enrichments.where(listing: @listing)
    
    # Get listing documents added by seller
    @listing_documents = @listing.listing_documents.where.not(not_applicable: true)
  end
  
  def create
    @enrichment = @buyer_profile.enrichments.build(enrichment_params)
    @enrichment.listing = @listing
    
    if @enrichment.save
      # Notify seller about new enrichment
      create_enrichment_notification(@enrichment)
      
      redirect_to buyer_enrichments_path,
                  notice: "Document enrichi soumis avec succès. Le cédant sera notifié pour validation."
    else
      @existing_enrichments = @buyer_profile.enrichments.where(listing: @listing)
      @listing_documents = @listing.listing_documents.where.not(not_applicable: true)
      render :new, status: :unprocessable_entity
    end
  end
  
  private
  
  def set_buyer_profile
    @buyer_profile = current_user.buyer_profile
    
    unless @buyer_profile
      redirect_to root_path, alert: 'Accès refusé. Privilèges de repreneur requis.'
    end
  end
  
  def set_enrichment
    @enrichment = @buyer_profile.enrichments.includes(:listing, :validated_by).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to buyer_enrichments_path, alert: 'Enrichissement introuvable.'
  end
  
  def set_listing
    @listing = Listing.approved.find(params[:listing_id])
    
    # Verify buyer has access to this listing (must have a deal for it)
    unless @buyer_profile.deals.exists?(listing_id: @listing.id)
      redirect_to buyer_listings_path, 
                  alert: 'Vous devez avoir un dossier pour cette annonce pour ajouter des documents.'
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to buyer_listings_path, alert: 'Annonce introuvable.'
  end
  
  def authorize_buyer!
    unless current_user&.buyer_profile
      redirect_to root_path, alert: 'Accès refusé. Privilèges de repreneur requis.'
    end
  end
  
  def enrichment_params
    params.require(:enrichment).permit(:document_category, :description, :document)
  end
  
  def create_enrichment_notification(enrichment)
    # Notify seller via notification system
    seller_user = enrichment.listing.seller_profile.user
    
    Notification.create(
      user: seller_user,
      notification_type: :enrichment_submitted,
      title: "Nouveau document enrichi",
      message: "#{current_user.full_name} a soumis un document (#{enrichment.category_label}) pour validation sur l'annonce \"#{enrichment.listing.title}\".",
      link_url: Rails.application.routes.url_helpers.seller_enrichment_path(enrichment)
    )
  rescue => e
    Rails.logger.error "Failed to create enrichment notification: #{e.message}"
  end
end
