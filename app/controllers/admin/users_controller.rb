# frozen_string_literal: true

module Admin
  class UsersController < ApplicationController
    layout 'admin'
    
    before_action :authenticate_user!
    before_action :ensure_admin!
    before_action :set_user, only: [:show, :edit, :update, :destroy, :activate, :suspend, :suspend_confirm]

    def index
      @users = User.includes(:seller_profile, :buyer_profile, :partner_profile)
                   .order(created_at: :desc)

      # Apply filters
      @users = @users.where(role: params[:role]) if params[:role].present? && params[:role] != 'all'
      @users = @users.where(status: params[:status]) if params[:status].present? && params[:status] != 'all'

      # Apply search
      if params[:search].present?
        search_term = "%#{params[:search]}%"
        @users = @users.where(
          "email LIKE ? OR first_name LIKE ? OR last_name LIKE ? OR company_name LIKE ?",
          search_term, search_term, search_term, search_term
        )
      end

      @users = @users.page(params[:page]).per(20) if defined?(Kaminari)
    end

    def show
      @profile = @user.profile
      
      # Get role-specific data
      case @user.role
      when 'seller'
        @listings = @user.seller_profile&.listings&.order(created_at: :desc)&.limit(5)
        @listings_count = @user.seller_profile&.listings&.count || 0
      when 'buyer'
        @deals = @user.buyer_profile&.deals&.order(created_at: :desc)&.limit(5)
        @deals_count = @user.buyer_profile&.deals&.count || 0
      when 'partner'
        @contacts_count = @user.partner_profile&.contacts_count || 0
        @views_count = @user.partner_profile&.views_count || 0
      end

      @messages_count = @user.sent_messages.count + @user.received_messages.count
    end

    def new
      @user = User.new
      @user.status = :active # Default to active
    end

    def create
      @user = User.new(user_params)
      @user.password = SecureRandom.hex(10) if @user.password.blank? # Generate temporary password
      
      if @user.save
        # Send password reset email to new user
        @user.send_reset_password_instructions if defined?(Devise)
        
        redirect_to admin_user_path(@user), notice: "Utilisateur créé avec succès."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @profile = @user.profile
    end

    def update
      if @user.update(user_params)
        # Update profile if params present
        update_profile if profile_params_present?
        
        redirect_to admin_user_path(@user), notice: "Utilisateur mis à jour avec succès."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @user.destroy
      redirect_to admin_users_path, notice: "Utilisateur supprimé avec succès."
    end

    def activate
      @user.update(status: :active)
      redirect_to admin_user_path(@user), notice: "Utilisateur activé avec succès."
    end

    def suspend
      @user.update(status: :suspended)
      redirect_to admin_user_path(@user), notice: "Utilisateur suspendu avec succès."
    end

    def suspend_confirm
      # Renders confirmation view
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def ensure_admin!
      unless current_user&.admin?
        redirect_to root_path, alert: "Accès non autorisé."
      end
    end

    def user_params
      params.require(:user).permit(
        :email, :first_name, :last_name, :phone, :company_name,
        :role, :status, :password, :password_confirmation
      )
    end

    def profile_params_present?
      params[:user][:seller_profile_attributes].present? ||
      params[:user][:buyer_profile_attributes].present? ||
      params[:user][:partner_profile_attributes].present?
    end

    def update_profile
      case @user.role
      when 'seller'
        update_seller_profile
      when 'buyer'
        update_buyer_profile
      when 'partner'
        update_partner_profile
      end
    end

    def update_seller_profile
      return unless params[:user][:seller_profile_attributes]
      
      profile_params = params[:user][:seller_profile_attributes].permit(
        :is_broker, :premium_access, :credits, :free_contacts_limit, :receive_signed_nda
      )
      @user.seller_profile.update(profile_params)
    end

    def update_buyer_profile
      return unless params[:user][:buyer_profile_attributes]
      
      profile_params = params[:user][:buyer_profile_attributes].permit(
        :subscription_plan, :verified_buyer, :buyer_type, :credits,
        :formation, :experience, :skills, :investment_thesis,
        :investment_capacity, :funding_sources
      )
      @user.buyer_profile.update(profile_params)
    end

    def update_partner_profile
      return unless params[:user][:partner_profile_attributes]
      
      profile_params = params[:user][:partner_profile_attributes].permit(
        :partner_type, :validation_status, :coverage_area,
        :description, :services_offered, :website, :calendar_link
      )
      @user.partner_profile.update(profile_params)
    end
  end
end
