class Admin::EnrichmentsController < ApplicationController
  layout 'admin'
  
  before_action :authenticate_user!
  before_action :authorize_admin!
  before_action :set_enrichment, only: [:show, :approve, :reject, :approve_form]

  def index
    @enrichments = Enrichment.includes(:buyer_profile, :listing)
                              .order(created_at: :desc)
    
    # Filter by validation_status
    if params[:status].present? && params[:status] != 'all'
      @enrichments = @enrichments.where(validation_status: params[:status])
    end
    
    # Paginate
    @enrichments = @enrichments.page(params[:page]).per(20)
    
    # Stats
    @stats = {
      pending: Enrichment.where(validation_status: :pending).count,
      approved_this_week: Enrichment.where(validation_status: :approved).where('updated_at >= ?', 7.days.ago).count,
      rejected_this_week: Enrichment.where(validation_status: :rejected).where('updated_at >= ?', 7.days.ago).count,
      total_credits_awarded: Enrichment.where(validation_status: :approved).sum(:credits_awarded)
    }
  end

  def show
    @listing = @enrichment.listing
    @buyer = @enrichment.buyer_profile
    @documents = @enrichment.documents if @enrichment.respond_to?(:documents)
  end

  def approve_form
    @listing = @enrichment.listing
    @buyer = @enrichment.buyer_profile
  end

  def approve
    credits = params[:credits_awarded].to_i
    
    if @enrichment.update(validation_status: :approved, credits_awarded: credits, validated_at: Time.current, validated_by_id: current_user.id)
      # Award credits to buyer
      if @enrichment.buyer_profile
        @enrichment.buyer_profile.increment!(:credits, credits)
      end
      
      redirect_to admin_enrichments_path, notice: "Enrichissement approuvé. #{credits} crédit(s) attribué(s)."
    else
      redirect_to admin_enrichment_path(@enrichment), alert: "Erreur lors de l'approbation."
    end
  end

  def reject
    reason = params[:rejection_reason]
    
    if @enrichment.update(validation_status: :rejected, rejection_reason: reason, validated_at: Time.current, validated_by_id: current_user.id)
      redirect_to admin_enrichments_path, notice: "Enrichissement rejeté."
    else
      redirect_to admin_enrichment_path(@enrichment), alert: "Erreur lors du rejet."
    end
  end

  private

  def authorize_admin!
    unless current_user&.admin? && current_user&.active?
      redirect_to root_path, alert: 'Access denied. Admin privileges required.'
    end
  end

  def set_enrichment
    @enrichment = Enrichment.find(params[:id])
  end
end
