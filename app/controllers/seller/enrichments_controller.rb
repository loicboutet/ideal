class Seller::EnrichmentsController < ApplicationController
  layout 'seller'
  
  before_action :authenticate_user!
  before_action :authorize_seller!
  before_action :set_enrichment, only: [:show, :approve, :reject]
  
  def index
    @filter = params[:filter] || 'pending'
    
    # Get enrichments for seller's listings
    listing_ids = current_user.seller_profile.listings.pluck(:id)
    @enrichments = Enrichment.where(listing_id: listing_ids)
                              .includes(:listing, :buyer_profile => :user)
    
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
      total: Enrichment.where(listing_id: listing_ids).count,
      pending: Enrichment.where(listing_id: listing_ids).pending_validation.count,
      approved: Enrichment.where(listing_id: listing_ids).approved_enrichments.count,
      rejected: Enrichment.where(listing_id: listing_ids).rejected_enrichments.count
    }
  end
  
  def show
    # Display enrichment details for review
  end
  
  def approve
    if @enrichment.update(
      validation_status: :approved,
      validated_by: current_user,
      validated_at: Time.current
    )
      redirect_to seller_enrichments_path(filter: 'pending'),
                  notice: "Document enrichi approuvé. 1 crédit gagné."
    else
      redirect_to seller_enrichment_path(@enrichment),
                  alert: "Erreur lors de l'approbation du document."
    end
  end
  
  def reject
    rejection_reason = params[:rejection_reason]
    
    if rejection_reason.blank?
      redirect_to seller_enrichment_path(@enrichment),
                  alert: "Veuillez fournir une raison pour le rejet."
      return
    end
    
    if @enrichment.update(
      validation_status: :rejected,
      rejection_reason: rejection_reason,
      validated_by: current_user,
      validated_at: Time.current
    )
      # Notify buyer about rejection
      create_rejection_notification(@enrichment, rejection_reason)
      
      redirect_to seller_enrichments_path(filter: 'pending'),
                  notice: "Document enrichi rejeté."
    else
      redirect_to seller_enrichment_path(@enrichment),
                  alert: "Erreur lors du rejet du document."
    end
  end
  
  private
  
  def set_enrichment
    # Make sure enrichment belongs to one of seller's listings
    listing_ids = current_user.seller_profile.listings.pluck(:id)
    @enrichment = Enrichment.where(listing_id: listing_ids)
                           .includes(:listing, :buyer_profile => :user)
                           .find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to seller_enrichments_path, alert: 'Enrichissement introuvable.'
  end
  
  def authorize_seller!
    unless current_user&.seller_profile
      redirect_to root_path, alert: 'Accès refusé. Privilèges de cédant requis.'
    end
  end
  
  def create_rejection_notification(enrichment, reason)
    Notification.create(
      user: enrichment.buyer_profile.user,
      notification_type: :enrichment_rejected,
      title: "Document rejeté",
      message: "Votre enrichissement (#{enrichment.category_label}) pour l'annonce \"#{enrichment.listing.title}\" a été rejeté. Raison : #{reason}",
      link_url: Rails.application.routes.url_helpers.buyer_listing_path(enrichment.listing)
    )
  rescue => e
    Rails.logger.error "Failed to create rejection notification: #{e.message}"
  end
end
