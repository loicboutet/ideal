class Mockups::Buyer::DealsController < Mockups::BuyerController
  def index
    # My deals (list view)
  end

  def show
    # Deal detail with notes
    @deal_id = params[:id]
  end

  def edit
    # Edit deal notes/status
    @deal_id = params[:id]
  end

  def new
    # Add listing to pipeline (from listing page)
  end

  def new_document
    # Buyer uploads documents to deal (enrichment replacement)
    @deal_id = params[:id]
  end
end
