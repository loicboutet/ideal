# frozen_string_literal: true

module Buyer
  class FavoritesController < ApplicationController
    layout 'buyer'
    
    before_action :authenticate_user!
    before_action :ensure_buyer!
    before_action :set_buyer_profile

    def index
      # Get all favorited listings with pagination
      @favorited_listings = @buyer_profile.favorites
                                          .includes(listing: :seller_profile)
                                          .order(created_at: :desc)
                                          .page(params[:page])
                                          .per(20)
      
      # Get the actual listings for easier rendering
      @listings = @favorited_listings.map(&:listing)
    end

    def destroy
      @favorite = @buyer_profile.favorites.find(params[:id])
      @listing = @favorite.listing
      
      @favorite.destroy!
      
      redirect_to buyer_favorites_path, notice: "Annonce retirée des favoris."
    end

    private

    def set_buyer_profile
      @buyer_profile = current_user.buyer_profile
      
      unless @buyer_profile
        redirect_to root_path, alert: "Vous devez avoir un profil repreneur pour accéder à cette page."
      end
    end

    def ensure_buyer!
      unless current_user&.buyer?
        redirect_to root_path, alert: "Accès non autorisé."
      end
    end
  end
end
