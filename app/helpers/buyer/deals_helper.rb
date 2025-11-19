module Buyer
  module DealsHelper
    # Returns CSS class for timer based on time remaining
    def timer_color_class(deal)
      return 'gray' unless deal.timer_percentage
      
      percentage = deal.timer_percentage
      if percentage >= 80
        'red'      # Less than 20% time remaining - critical
      elsif percentage >= 50
        'yellow'   # 20-50% time remaining - warning
      else
        'green'    # More than 50% time remaining - good
      end
    end
    
    # Returns formatted timer percentage for display
    def timer_percentage_display(deal)
      return 'N/A' unless deal.timer_percentage
      "#{deal.timer_percentage}%"
    end
    
    # Returns friendly text for days remaining
    def days_remaining_text(deal)
      return 'Aucune limite' unless deal.days_remaining
      
      days = deal.days_remaining
      
      if days <= 0
        '<span class="text-red-600 font-bold">⏰ Expiré</span>'.html_safe
      elsif days == 1
        '<span class="text-orange-600 font-semibold">⚠️ 1 jour restant</span>'.html_safe
      elsif days <= 3
        "<span class=\"text-orange-600 font-semibold\">⚠️ #{days} jours restants</span>".html_safe
      elsif days <= 7
        "<span class=\"text-yellow-600\">#{days} jours restants</span>".html_safe
      else
        "<span class=\"text-gray-700\">#{days} jours restants</span>".html_safe
      end
    end
    
    # Returns stage display name in French
    def deal_stage_name(status)
      case status.to_sym
      when :favorited then 'Favoris'
      when :to_contact then 'À contacter'
      when :info_exchange then 'Échange d\'infos'
      when :analysis then 'Analyse'
      when :project_alignment then 'Alignement projet'
      when :negotiation then 'Négociation'
      when :loi then 'LOI'
      when :audits then 'Audits'
      when :financing then 'Financement'
      when :signed then 'Signé'
      when :released then 'Libéré'
      when :abandoned then 'Abandonné'
      else status.to_s.humanize
      end
    end
    
    # Returns badge color for deal status
    def deal_status_badge_class(status)
      case status.to_sym
      when :favorited then 'bg-pink-100 text-pink-800'
      when :to_contact then 'bg-blue-100 text-blue-800'
      when :info_exchange, :analysis, :project_alignment then 'bg-purple-100 text-purple-800'
      when :negotiation then 'bg-orange-100 text-orange-800'
      when :loi then 'bg-yellow-100 text-yellow-800'
      when :audits, :financing then 'bg-indigo-100 text-indigo-800'
      when :signed then 'bg-green-100 text-green-800'
      when :released then 'bg-gray-100 text-gray-800'
      when :abandoned then 'bg-red-100 text-red-800'
      else 'bg-gray-100 text-gray-800'
      end
    end
  end
end
