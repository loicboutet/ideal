class Mockups::Buyer::NdaController < Mockups::BuyerController
  def show
    # View/sign platform NDA
  end

  def listing_nda
    # Sign listing-specific NDA
    @listing_id = params[:id]
  end
end
