class Buyer::DealsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_buyer_role
  before_action :set_buyer_profile
  before_action :set_deal, only: [:show, :edit, :update, :destroy, :move_stage, :release]

  def index
    @deals = @buyer_profile.deals.active.includes(:listing).order(stage_entered_at: :desc)
  end

  def show
    @listing = @deal.listing
    @deal_history = @deal.deal_history_events.order(created_at: :desc)
  end

  def new
    @deal = @buyer_profile.deals.new
  end

  def create
    @deal = @buyer_profile.deals.new(deal_params)
    @deal.status = :favorited
    @deal.stage_entered_at = Time.current
    
    if @deal.save
      redirect_to buyer_deal_path(@deal), notice: "Deal ajouté au pipeline avec succès"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @deal.update(deal_params)
      redirect_to buyer_deal_path(@deal), notice: "Deal mis à jour avec succès"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @deal.destroy
    redirect_to buyer_deals_path, notice: "Deal supprimé avec succès"
  end

  def move_stage
    new_status = params[:new_status]
    
    # Validate forward-only movement
    unless can_move_to_status?(@deal.status, new_status)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "deal_#{@deal.id}",
            partial: "buyer/deals/deal_card",
            locals: { deal: @deal, error: "Mouvement arrière non autorisé" }
          )
        end
        format.html { redirect_to buyer_pipeline_path, alert: "Mouvement arrière non autorisé" }
      end
      return
    end
    
    # Update status (callbacks will handle timer updates)
    if @deal.update(status: new_status)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove("deal_#{@deal.id}"),
            turbo_stream.append(
              "stage_#{new_status}",
              partial: "buyer/deals/deal_card",
              locals: { deal: @deal }
            )
          ]
        end
        format.html { redirect_to buyer_pipeline_path, notice: "Deal déplacé vers #{Deal.human_attribute_name("status.#{new_status}")}" }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "deal_#{@deal.id}",
            partial: "buyer/deals/deal_card",
            locals: { deal: @deal, error: "Erreur lors du déplacement" }
          )
        end
        format.html { redirect_to buyer_pipeline_path, alert: "Erreur lors du déplacement du deal" }
      end
    end
  end

  def release
    reason = params[:reason]
    
    if @deal.release!(reason)
      redirect_to buyer_pipeline_path, notice: "Deal libéré avec succès. Vous avez gagné #{@deal.total_credits_earned} crédits."
    else
      redirect_to buyer_deal_path(@deal), alert: "Erreur lors de la libération du deal"
    end
  end

  private

  def set_buyer_profile
    @buyer_profile = current_user.buyer_profile
  end

  def set_deal
    @deal = @buyer_profile.deals.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to buyer_deals_path, alert: "Deal non trouvé"
  end

  def deal_params
    params.require(:deal).permit(:listing_id, :notes)
  end

  def ensure_buyer_role
    unless current_user.buyer?
      redirect_to root_path, alert: "Accès non autorisé"
    end
  end

  def can_move_to_status?(current_status, new_status)
    # Get numeric values for comparison
    current_index = Deal.statuses[current_status]
    new_index = Deal.statuses[new_status]
    
    # Only allow forward movement (or same status)
    # Exclude 'released' and 'abandoned' from normal progression
    return false if ['released', 'abandoned'].include?(new_status)
    return false if ['released', 'abandoned'].include?(current_status)
    
    new_index >= current_index
  end
end
