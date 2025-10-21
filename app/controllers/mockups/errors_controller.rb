module Mockups
  class ErrorsController < MockupsController
    def not_found
      # Mockup: 404 page
      render '404', status: :not_found
    end

    def forbidden
      # Mockup: 403 page
      render '403', status: :forbidden
    end

    def server_error
      # Mockup: 500 page
      render '500', status: :internal_server_error
    end
  end
end
