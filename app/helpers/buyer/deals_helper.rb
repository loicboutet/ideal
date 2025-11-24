module Buyer::DealsHelper
  # Stage configuration
  STAGE_CONFIG = {
    'favorited' => {
      label: 'Favoris',
      color: 'gray',
      icon: '❤️',
      timer: false
    },
    'to_contact' => {
      label: 'À contacter',
      color: 'blue',
      icon: '📞',
      timer: '7j'
    },
    'info_exchange' => {
      label: "Échange d'infos",
      color: 'blue',
      icon: '💬',
      timer: '33j',
      time_extending: true
    },
    'analysis' => {
      label: 'Analyse',
      color: 'blue',
      icon: '📊',
      timer: '33j',
      time_extending: true
    },
    'project_alignment' => {
      label: 'Alignement projets',
      color: 'blue',
      icon: '🎯',
      timer: '33j',
      time_extending: true
    },
    'negotiation' => {
      label: 'Négociation',
      color: 'green',
      icon: '🤝',
      timer: '20j'
    },
    'loi' => {
      label: 'LOI',
      color: 'green',
      icon: '📝',
      timer: 'Validation'
    },
    'audits' => {
      label: 'Audits',
      color: 'green',
      icon: '🔍',
      timer: false
    },
    'financing' => {
      label: 'Financement',
      color: 'green',
      icon: '💰',
      timer: false
    },
    'signed' => {
      label: 'Deal signé',
      color: 'purple',
      icon: '✅',
      timer: false
    },
    'released' => {
      label: 'Deals libérés',
      color: 'red',
      icon: '🔓',
      timer: false
    }
  }.freeze

  def stage_label(status)
    STAGE_CONFIG.dig(status.to_s, :label) || status.to_s.humanize
  end

  def stage_color(status)
    STAGE_CONFIG.dig(status.to_s, :color) || 'gray'
  end

  def stage_icon(status)
    STAGE_CONFIG.dig(status.to_s, :icon) || '📋'
  end

  def stage_timer_label(status)
    STAGE_CONFIG.dig(status.to_s, :timer) || false
  end

  def stage_has_shared_timer?(status)
    STAGE_CONFIG.dig(status.to_s, :time_extending) || false
  end

  # Timer-related helpers
  def timer_color_class(deal)
    return 'gray' unless deal.timer_percentage

    percentage = deal.timer_percentage
    
    if percentage >= 80
      'red' # Less than 20% time remaining
    elsif percentage >= 50
      'yellow' # 20-50% remaining
    else
      'green' # More than 50% remaining
    end
  end

  def timer_badge_class(deal)
    color = timer_color_class(deal)
    
    case color
    when 'red'
      'bg-red-500'
    when 'yellow'
      'bg-yellow-500'
    when 'green'
      'bg-green-500'
    else
      'bg-gray-500'
    end
  end

  def format_timer_display(deal)
    return nil unless deal.reserved_until

    if deal.timer_expired?
      '⚠️ Expiré'
    elsif deal.status == 'loi'
      '⏸ En attente validation'
    else
      days = deal.days_remaining
      "#{days}j"
    end
  end

  def deal_type_badge_class(listing)
    case listing.deal_type
    when 'direct'
      'bg-buyer-100 text-buyer-700'
    when 'ideal_mandate'
      'bg-purple-100 text-purple-700'
    when 'partner_mandate'
      'bg-orange-100 text-orange-700'
    else
      'bg-gray-100 text-gray-700'
    end
  end

  def deal_type_label(listing)
    case listing.deal_type
    when 'direct'
      'Direct'
    when 'ideal_mandate'
      'Mandat Idéal'
    when 'partner_mandate'
      'Partenaire'
    else
      listing.deal_type&.humanize
    end
  end

  def stage_count_badge_class(status, count)
    color = stage_color(status)
    
    case color
    when 'blue'
      'bg-blue-100 text-blue-600'
    when 'green'
      'bg-green-100 text-green-600'
    when 'purple'
      'bg-purple-100 text-purple-600'
    when 'red'
      'bg-red-100 text-red-600'
    else
      'bg-gray-100 text-gray-600'
    end
  end

  def stage_border_class(status)
    color = stage_color(status)
    "border-#{color}-200"
  end

  # Deal history event formatting
  def format_deal_event(event)
    case event.event_type
    when 'status_change'
      from = stage_label(event.from_status)
      to = stage_label(event.to_status)
      "Déplacé de #{from} vers #{to}"
    when 'timer_extended'
      "Timer prolongé"
    when 'released'
      "Deal libéré"
    when 'note_added'
      "Note ajoutée"
    else
      event.event_type.humanize
    end
  end

  def format_time_ago(time)
    return unless time
    
    distance_of_time_in_words_to_now(time) + ' ago'
  end
end
