class MockupsController < ApplicationController
  # Skip authentication for mockups as per routes.md specification
  skip_before_action :authenticate_user!, raise: false
  
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

  private

  # Determine which layout to use based on the action name
  def resolve_layout
    public_pages = %w[index about how_it_works pricing contact]

    if public_pages.include?(action_name)
      "mockup"
    elsif action_name.start_with?("admin_")
      "mockup_admin"
    else
      "mockup"
    end
  end
end
