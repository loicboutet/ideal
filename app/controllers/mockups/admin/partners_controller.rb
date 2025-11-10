class Mockups::Admin::PartnersController < Mockups::AdminController
  def index
    # All partners (all statuses)
  end

  def pending
    # Pending partner validation
  end

  def new
    # Create new partner profile
  end

  def show
    # Partner detail
    @partner_id = params[:id]
  end

  def approve_form
    # Approve partner form
    @partner_id = params[:id]
  end

  def reject_form
    # Reject partner form
    @partner_id = params[:id]
  end
end
