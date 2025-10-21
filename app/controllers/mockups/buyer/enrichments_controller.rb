class Mockups::Buyer::EnrichmentsController < Mockups::BuyerController
  def index
    # My enrichment submissions
  end

  def new
    # Submit enrichment form
  end

  def show
    # Enrichment detail/status
    @enrichment_id = params[:id]
  end
end
