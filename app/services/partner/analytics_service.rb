# frozen_string_literal: true

module Partner
  class AnalyticsService
    attr_reader :partner_profile, :start_date, :end_date

    def initialize(partner_profile, start_date: nil, end_date: nil)
      @partner_profile = partner_profile
      @end_date = end_date || Time.current
      @start_date = start_date || 30.days.ago
    end

    # Get view analytics
    def view_analytics
      {
        total: views_in_period.count,
        by_day: group_by_day(views_in_period),
        trend: calculate_trend(views_in_period)
      }
    end

    # Get contact analytics
    def contact_analytics
      contacts = contacts_in_period
      {
        total: contacts.count,
        by_day: group_by_day(contacts),
        by_type: contacts.group(:contact_type).count,
        trend: calculate_trend(contacts)
      }
    end

    # Get conversion rate
    def conversion_rate
      views = views_in_period.count
      contacts = contacts_in_period.where(contact_type: [:contact, :directory_contact]).count
      
      return 0 if views.zero?
      ((contacts.to_f / views) * 100).round(2)
    end

    # Get detailed contact list
    def contact_details
      partner_profile.partner_contacts
        .where(created_at: start_date..end_date)
        .includes(:user)
        .order(created_at: :desc)
        .map do |contact|
          {
            id: contact.id,
            user_name: contact.user.company_name || "#{contact.user.first_name} #{contact.user.last_name}",
            user_role: contact.user.role,
            contact_type: contact.contact_type,
            created_at: contact.created_at
          }
        end
    end

    # Get summary stats
    def summary_stats
      {
        total_views: partner_profile.views_count,
        total_contacts: partner_profile.contacts_count,
        period_views: views_in_period.count,
        period_contacts: contacts_in_period.count,
        conversion_rate: conversion_rate,
        avg_daily_views: average_daily_metric(views_in_period),
        avg_daily_contacts: average_daily_metric(contacts_in_period)
      }
    end

    # Export data to CSV
    def export_to_csv
      require 'csv'
      
      CSV.generate(headers: true) do |csv|
        csv << ['Date', 'Views', 'Contacts', 'Conversion Rate']
        
        daily_data.each do |date, metrics|
          csv << [
            date,
            metrics[:views],
            metrics[:contacts],
            metrics[:conversion_rate]
          ]
        end
      end
    end

    private

    def views_in_period
      @views_in_period ||= partner_profile.partner_contacts
        .where(contact_type: :view)
        .where(created_at: start_date..end_date)
    end

    def contacts_in_period
      @contacts_in_period ||= partner_profile.partner_contacts
        .where(created_at: start_date..end_date)
    end

    def group_by_day(relation)
      relation.group_by_day(:created_at, range: start_date..end_date).count
    end

    def calculate_trend(relation)
      current_period = relation.where(created_at: start_date..end_date).count
      previous_period = partner_profile.partner_contacts
        .where(contact_type: relation.first&.contact_type || :view)
        .where(created_at: (start_date - period_length)..(end_date - period_length))
        .count
      
      return 0 if previous_period.zero?
      ((current_period - previous_period).to_f / previous_period * 100).round(2)
    end

    def average_daily_metric(relation)
      count = relation.count
      days = (end_date.to_date - start_date.to_date).to_i + 1
      (count.to_f / days).round(2)
    end

    def period_length
      end_date - start_date
    end

    def daily_data
      data = {}
      
      (start_date.to_date..end_date.to_date).each do |date|
        date_start = date.beginning_of_day
        date_end = date.end_of_day
        
        views = views_in_period.where(created_at: date_start..date_end).count
        contacts = contacts_in_period.where(created_at: date_start..date_end).count
        conversion = views.zero? ? 0 : ((contacts.to_f / views) * 100).round(2)
        
        data[date.to_s] = {
          views: views,
          contacts: contacts,
          conversion_rate: "#{conversion}%"
        }
      end
      
      data
    end
  end
end
