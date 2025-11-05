# frozen_string_literal: true

module Mockups
  class MessagesController < MockupsController
    # Use role-specific layout based on user context
    # For mockup, we'll use buyer layout as default
    layout 'mockup_buyer'

    def index
      # Messages inbox
    end

    def show
      # Single conversation thread
    end

    def new
      # Compose new message
    end
  end
end
