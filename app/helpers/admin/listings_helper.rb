# frozen_string_literal: true

module Admin
  module ListingsHelper
    def validation_status_badge(status)
      colors = {
        'pending' => 'bg-yellow-100 text-yellow-800',
        'approved' => 'bg-green-100 text-green-800',
        'rejected' => 'bg-red-100 text-red-800'
      }
      
      labels = {
        'pending' => 'En attente',
        'approved' => 'Validée',
        'rejected' => 'Rejetée'
      }
      
      color_class = colors[status.to_s] || 'bg-gray-100 text-gray-800'
      label = labels[status.to_s] || status.to_s.capitalize
      
      content_tag(:span, label, class: "px-3 py-1 text-sm font-medium rounded-full #{color_class}")
    end

    def listing_status_badge(status)
      colors = {
        'draft' => 'bg-gray-100 text-gray-800',
        'published' => 'bg-green-100 text-green-800',
        'reserved' => 'bg-blue-100 text-blue-800',
        'in_negotiation' => 'bg-purple-100 text-purple-800',
        'sold' => 'bg-green-100 text-green-800',
        'withdrawn' => 'bg-red-100 text-red-800'
      }
      
      labels = {
        'draft' => 'Brouillon',
        'published' => 'Publiée',
        'reserved' => 'Réservée',
        'in_negotiation' => 'En négociation',
        'sold' => 'Vendue',
        'withdrawn' => 'Retirée'
      }
      
      color_class = colors[status.to_s] || 'bg-gray-100 text-gray-800'
      label = labels[status.to_s] || status.to_s.capitalize
      
      content_tag(:span, label, class: "px-3 py-1 text-sm font-medium rounded-full #{color_class}")
    end

    def deal_type_badge(deal_type)
      colors = {
        'direct' => 'bg-blue-100 text-blue-800',
        'ideal_mandate' => 'bg-admin-100 text-admin-800',
        'partner_mandate' => 'bg-orange-100 text-orange-800'
      }
      
      labels = {
        'direct' => 'Deal Direct',
        'ideal_mandate' => 'Mandat Idéal',
        'partner_mandate' => 'Mandat Partenaire'
      }
      
      color_class = colors[deal_type.to_s] || 'bg-gray-100 text-gray-800'
      label = labels[deal_type.to_s] || deal_type.to_s.humanize
      
      content_tag(:span, label, class: "px-3 py-1 text-sm font-medium rounded-full #{color_class}")
    end

    def sector_badge(sector)
      sectors = {
        'industry' => 'Industrie',
        'construction' => 'BTP',
        'commerce' => 'Commerce',
        'transport_logistics' => 'Transport & Logistique',
        'hospitality' => 'Hôtellerie / Restaurant',
        'services' => 'Services',
        'agrifood' => 'Agro-alimentaire',
        'healthcare' => 'Santé',
        'digital' => 'Digital',
        'real_estate' => 'Immobilier',
        'other' => 'Autre'
      }
      
      label = sectors[sector.to_s] || sector.to_s.humanize
      content_tag(:span, label, class: "inline-flex items-center gap-1 text-sm text-gray-700")
    end

    def completeness_gauge(score)
      color_class = if score >= 80
                     'text-green-600'
                   elsif score >= 60
                     'text-yellow-600'
                   else
                     'text-red-600'
                   end
      
      content_tag(:div, class: "flex items-center gap-2") do
        concat content_tag(:div, class: "flex-1 bg-gray-200 rounded-full h-2") do
          content_tag(:div, '', class: "bg-current h-2 rounded-full #{color_class}", style: "width: #{score}%")
        end
        concat content_tag(:span, "#{score}%", class: "text-sm font-medium #{color_class}")
      end
    end

    def listing_price_display(listing)
      if listing.asking_price.present?
        number_to_currency(listing.asking_price, unit: '€', separator: ',', delimiter: ' ', format: '%n %u')
      elsif listing.price_min.present? && listing.price_max.present?
        min = number_to_currency(listing.price_min, unit: '€', separator: ',', delimiter: ' ', format: '%n %u')
        max = number_to_currency(listing.price_max, unit: '€', separator: ',', delimiter: ' ', format: '%n %u')
        "#{min} - #{max}"
      elsif listing.price_min.present?
        "À partir de #{number_to_currency(listing.price_min, unit: '€', separator: ',', delimiter: ' ', format: '%n %u')}"
      else
        'Prix non spécifié'
      end
    end

    def listing_stats_summary(listing)
      stats = {
        views: listing.views_count || 0,
        favorites: listing.favorites.count,
        reservations: listing.deals.where(reserved: true).count,
        completeness: listing.calculate_completeness
      }
      stats
    end

    def days_pending_badge(listing)
      return unless listing.pending_validation? && listing.submitted_at
      
      days = ((Time.current - listing.submitted_at) / 1.day).to_i
      
      color_class = if days >= 3
                     'bg-red-100 text-red-800'
                   elsif days >= 1
                     'bg-yellow-100 text-yellow-800'
                   else
                     'bg-green-100 text-green-800'
                   end
      
      icon = if days >= 3
               '<svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                </svg>'.html_safe
             else
               ''
             end
      
      label = if days == 0
               'Aujourd\'hui'
             elsif days == 1
               'Il y a 1 jour'
             else
               "Il y a #{days} jours"
             end
      
      content_tag(:span, class: "inline-flex items-center gap-1 px-2 py-0.5 text-xs font-medium rounded-full #{color_class}") do
        concat icon
        concat label
      end
    end

    def user_initials_avatar(user, size: 'md')
      initials = if user.first_name.present? && user.last_name.present?
                  "#{user.first_name[0]}#{user.last_name[0]}".upcase
                elsif user.first_name.present?
                  user.first_name[0..1].upcase
                elsif user.email.present?
                  user.email[0..1].upcase
                else
                  'U'
                end
      
      size_classes = {
        'sm' => 'w-8 h-8 text-sm',
        'md' => 'w-12 h-12 text-base',
        'lg' => 'w-16 h-16 text-lg'
      }
      
      content_tag(:div, initials, class: "#{size_classes[size]} bg-admin-600 rounded-full flex items-center justify-center text-white font-bold flex-shrink-0")
    end
  end
end
