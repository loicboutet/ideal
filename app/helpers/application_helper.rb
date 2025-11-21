module ApplicationHelper
  # Returns the appropriate dashboard path based on user's role
  def user_dashboard_path(user)
    return root_path unless user
    
    case user.role
    when 'admin'
      admin_root_path
    when 'seller'
      seller_root_path
    when 'buyer'
      buyer_root_path
    when 'partner'
      partner_root_path
    else
      root_path
    end
  end
end
