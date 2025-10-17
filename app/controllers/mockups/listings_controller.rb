# frozen_string_literal: true

module Mockups
  class ListingsController < MockupsController
    def index
      # Browse all listings (limited info for freemium users)
    end

    def show
      # Single listing view with teaser and paywall
      @listing_id = params[:id]
    end

    def search
      # Search and filter listings
    end
  end
end
