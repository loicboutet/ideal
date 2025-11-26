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

  # Check if a menu item should be marked as active based on controller name(s)
  # Usage: menu_active?('deals') or menu_active?(['deals', 'pipeline'])
  def menu_active?(controllers, actions = nil)
    controllers = Array(controllers).map(&:to_s)
    
    # Get the controller name without namespace (e.g., 'deals' from 'buyer/deals')
    current_controller_name = controller_name
    
    # Check if current controller matches any of the specified controllers
    is_controller_match = controllers.include?(current_controller_name)
    
    # If actions are specified, also check if current action matches
    if actions.present?
      actions = Array(actions).map(&:to_s)
      is_controller_match && actions.include?(action_name)
    else
      is_controller_match
    end
  end
end
