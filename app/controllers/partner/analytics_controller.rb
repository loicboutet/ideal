# frozen_string_literal: true

class Partner::AnalyticsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_partner!
  before_action :set_partner_profile
  before_action :set_date_range

  def index
    @analytics_service = Partner::AnalyticsService.new(@partner_profile, start_date: @start_date, end_date: @end_date)
    @summary_stats = @analytics_service.summary_stats
    @view_analytics = @analytics_service.view_analytics
    @contact_analytics = @analytics_service.contact_analytics
    @contact_details = @analytics_service.contact_details
    
    respond_to do |format|
      format.html
      format.csv do
        send_data @analytics_service.export_to_csv,
                  filename: "partner-analytics-#{Date.current}.csv",
                  type: 'text/csv; charset=utf-8'
      end
    end
  end

  private

  def authorize_partner!
    unless current_user&.partner? && current_user&.active?
      redirect_to root_path, alert: 'Accès refusé. Privilèges partenaire requis.'
    end
  end

  def set_partner_profile
    @partner_profile = current_user.partner_profile
    
    unless @partner_profile
      redirect_to root_path, alert: 'Profil partenaire non trouvé.'
    end
  end

  def set_date_range
    @period = params[:period] || '30'
    
    case @period
    when '7'
      @start_date = 7.days.ago
    when '30'
      @start_date = 30.days.ago
    when '90'
      @start_date = 90.days.ago
    when 'custom'
      @start_date = params[:start_date]&.to_date || 30.days.ago
      @end_date = params[:end_date]&.to_date || Time.current
      return
    else
      @start_date = 30.days.ago
    end
    
    @end_date = Time.current
  end
end
