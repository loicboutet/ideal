class Mockups::Seller::InterestsController < Mockups::SellerController
  def index
  end

  def show
    @interest_id = params[:id]
  end
end
