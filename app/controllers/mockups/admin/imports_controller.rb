class Mockups::Admin::ImportsController < Mockups::AdminController
  def index
    # Import history list
  end

  def new
    # Upload Excel file form
  end

  def show
    # Import results/errors
    @import_id = params[:id]
  end
end
