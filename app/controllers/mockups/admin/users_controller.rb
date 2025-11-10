# frozen_string_literal: true

module Mockups
  module Admin
    class UsersController < Mockups::AdminController
      def index
        # List all users (all roles)
      end

      def show
        # User detail view
        @user_id = params[:id]
      end

      def new
        # Create new user form - select user type
      end

      def new_seller
        # Create new seller profile form
      end

      def new_buyer
        # Create new buyer profile form
      end

      def new_partner
        # Create new partner profile form
      end

      def edit
        # Edit user form
        @user_id = params[:id]
      end

      def suspend_confirm
        # Confirm suspend user
        @user_id = params[:id]
      end
    end
  end
end
