class Mockups::Buyer::ListingsController < Mockups::BuyerController
  def index
    # Browse all available listings
  end

  def search
    # Advanced search/filters
  end

  def show
    # Full listing detail (after NDA)
    @listing_id = params[:id]
  end
end
