class Mockups::AuthController < MockupsController
  layout 'mockup'

  def login
    # Login page for all user types
  end

  def register
    # Registration choice page - select user type
  end

  def register_seller
    # Seller registration form
  end

  def register_buyer
    # Buyer registration form
  end

  def register_partner
    # Partner registration form
  end

  def register_intermediary
    # Intermediary/Broker registration form
  end

  def forgot_password
    # Password reset request form
  end

  def reset_password
    # Password reset form
  end
end
