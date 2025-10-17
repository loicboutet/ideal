class Mockups::Admin::EnrichmentsController < Mockups::AdminController
  def index
    # Pending enrichments to validate
  end

  def show
    # Enrichment detail
    @enrichment_id = params[:id]
  end

  def approve_form
    # Approve & award credits
    @enrichment_id = params[:id]
  end
end
