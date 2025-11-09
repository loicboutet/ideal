class Mockups::Admin::ListingsController < Mockups::AdminController
  def index
    # All listings (all statuses)
  end

  def pending
    # Pending validation queue
  end

  def new
    # Create new listing for a seller
  end

  def show
    # Listing detail for validation
    @listing_id = params[:id]
  end

  def validate_form
    # Approve listing form
    @listing_id = params[:id]
  end

  def reject_form
    # Reject listing form
    @listing_id = params[:id]
  end
end
