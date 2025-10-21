class Mockups::Buyer::ReservationsController < Mockups::BuyerController
  def index
    # My active reservations with timers
  end

  def show
    # Reservation detail
    @reservation_id = params[:id]
  end

  def release_confirm
    # Release reservation confirmation
    @reservation_id = params[:id]
  end
end
