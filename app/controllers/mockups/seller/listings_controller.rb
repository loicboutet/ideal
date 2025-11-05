class Mockups::Seller::ListingsController < Mockups::SellerController
  def index
  end

  def new
  end

  def new_confidential
    # Step 2: Confidential data
  end

  def show
    @listing_id = params[:id]
  end

  def edit
    @listing_id = params[:id]
  end

  def documents
    @listing_id = params[:id]
  end

  def new_document
    @listing_id = params[:id]
  end
end
