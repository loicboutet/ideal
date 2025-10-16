class MockupsController < ApplicationController
  # Set the layout based on the action
  layout :resolve_layout

  def index
    # Landing page / homepage
  end

  def about
    # About Idéal Reprise
  end

  def how_it_works
    # How the platform works
  end

  def pricing
    # Pricing plans for all user types
  end

  def contact
    # Contact form
  end

  # User journey pages
  def user_dashboard
    # User dashboard mockup
  end

  def user_profile
    # User profile mockup
  end

  def user_settings
    # User settings mockup
  end

  # Admin journey pages
  def admin_dashboard
    # Admin dashboard mockup
  end

  def admin_users
    # Admin users management mockup
  end

  def admin_analytics
    # Admin analytics mockup
  end

  private

  # Determine which layout to use based on the action name
  def resolve_layout
    public_pages = %w[index about how_it_works pricing contact]

    if public_pages.include?(action_name)
      "mockup"
    elsif action_name.start_with?("user_")
      "mockup_user"
    elsif action_name.start_with?("admin_")
      "mockup_admin"
    else
      "mockup"
    end
  end
end
