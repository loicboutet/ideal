module DealTimer
  extend ActiveSupport::Concern

  # CRM Status enum values (from Deal model)
  # favorites: 0
  # to_contact: 1
  # info_exchange: 2
  # analysis: 3
  # project_alignment: 4
  # negotiation: 5
  # loi: 6
  # audits: 7
  # financing: 8
  # deal_signed: 9

  class_methods do
    # Get timer duration in days for a specific status
    def timer_duration_for_status(status)
      case status.to_sym
      when :to_contact
        PlatformSetting.get('timer_to_contact')&.to_i || 7
      when :info_exchange, :analysis, :project_alignment
        # These three stages share the same total timer
        PlatformSetting.get('timer_info_analysis_alignment')&.to_i || 33
      when :negotiation
        PlatformSetting.get('timer_negotiation')&.to_i || 20
      when :loi
        # LOI requires seller validation, no automatic timer
        nil
      when :audits, :financing, :deal_signed
        # These stages have no timers
        nil
      when :favorites
        # Favorites don't have a timer
        nil
      else
        nil
      end
    end

    # Check if a status has a timer
    def status_has_timer?(status)
      timer_duration_for_status(status).present?
    end
  end

  # Calculate the reserved_until date when entering a stage
  def calculate_reserved_until
    return nil unless self.class.status_has_timer?(status)
    
    days = self.class.timer_duration_for_status(status)
    return nil if days.nil?
    
    (stage_entered_at || Time.current) + days.days
  end

  # Update reserved_until when changing status
  def update_timer_on_status_change
    if status_changed? && self.class.status_has_timer?(status)
      self.stage_entered_at = Time.current
      self.reserved_until = calculate_reserved_until
      self.reserved = true
    elsif status_changed? && !self.class.status_has_timer?(status)
      # Statuses without timers (LOI, Audits, Financing, Deal Signed)
      self.stage_entered_at = Time.current
      self.reserved_until = nil
      # Keep reserved as true for LOI (requires seller validation)
      self.reserved = (status == 'loi')
    end
  end

  # Check if timer has expired
  def timer_expired?
    return false unless reserved_until.present?
    Time.current > reserved_until
  end

  # Get remaining days on timer
  def days_remaining
    return nil unless reserved_until.present?
    ((reserved_until - Time.current) / 1.day).ceil
  end

  # Get timer status as percentage (for progress bars)
  def timer_percentage
    return nil unless reserved_until.present? && stage_entered_at.present?
    
    total_duration = reserved_until - stage_entered_at
    elapsed_time = Time.current - stage_entered_at
    
    percentage = (elapsed_time / total_duration * 100).to_i
    [percentage, 100].min # Cap at 100%
  end

  # Check if deal is in a time-extending stage
  # Time-extending stages are those that are running out of time (< 20% remaining)
  def time_extending?
    return false unless timer_percentage.present?
    timer_percentage >= 80 # Less than 20% time remaining
  end
end
