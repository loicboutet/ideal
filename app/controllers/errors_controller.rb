# frozen_string_literal: true

# ErrorsController
# Handles custom error pages with proper styling and helpful user guidance
class ErrorsController < ApplicationController
  # Skip authentication for error pages
  skip_before_action :authenticate_user!, raise: false
  
  # Use error layout
  layout 'error'
  
  # GET /404
  def not_found
    respond_to do |format|
      format.html { render :not_found, status: 404 }
      format.json { render json: { error: 'Not Found', status: 404 }, status: 404 }
      format.any { render plain: 'Not Found', status: 404 }
    end
  end
  
  # GET /403
  def forbidden
    respond_to do |format|
      format.html { render :forbidden, status: 403 }
      format.json { render json: { error: 'Forbidden', status: 403 }, status: 403 }
      format.any { render plain: 'Forbidden', status: 403 }
    end
  end
  
  # GET /500
  def server_error
    respond_to do |format|
      format.html { render :server_error, status: 500 }
      format.json { render json: { error: 'Internal Server Error', status: 500 }, status: 500 }
      format.any { render plain: 'Internal Server Error', status: 500 }
    end
  end
  
  private
  
  # Override layout from ApplicationController
  def layout_by_resource
    'error'
  end
end
