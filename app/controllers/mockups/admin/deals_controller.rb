class Mockups::Admin::DealsController < Mockups::AdminController
  def index
    # All deals across platform
  end

  def show
    # Deal detail view
    @deal_id = params[:id]
  end

  def assign_form
    # Assign deal exclusively to buyer
    @deal_id = params[:id]
  end
end
