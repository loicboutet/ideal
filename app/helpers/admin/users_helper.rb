# frozen_string_literal: true

module Admin
  module UsersHelper
    def role_color(role)
      case role.to_s
      when 'admin'
        'bg-admin-600'
      when 'seller'
        'bg-seller-600'
      when 'buyer'
        'bg-buyer-600'
      when 'partner'
        'bg-partner-600'
      else
        'bg-gray-400'
      end
    end

    def user_initials(user)
      if user.first_name.present? && user.last_name.present?
        "#{user.first_name[0]}#{user.last_name[0]}".upcase
      elsif user.first_name.present?
        user.first_name[0..1].upcase
      elsif user.email.present?
        user.email[0..1].upcase
      else
        'U'
      end
    end

    def role_badge(role)
      colors = {
        'admin' => 'bg-admin-100 text-admin-800',
        'seller' => 'bg-seller-100 text-seller-800',
        'buyer' => 'bg-buyer-100 text-buyer-800',
        'partner' => 'bg-partner-100 text-partner-800'
      }
      
      labels = {
        'admin' => 'Admin',
        'seller' => 'Vendeur',
        'buyer' => 'Repreneur',
        'partner' => 'Partenaire'
      }
      
      color_class = colors[role.to_s] || 'bg-gray-100 text-gray-800'
      label = labels[role.to_s] || role.to_s.capitalize
      
      content_tag(:span, label, class: "px-2 py-1 text-xs font-medium rounded-full #{color_class}")
    end

    def status_badge(status)
      colors = {
        'active' => 'bg-green-100 text-green-800',
        'suspended' => 'bg-red-100 text-red-800',
        'pending' => 'bg-yellow-100 text-yellow-800'
      }
      
      labels = {
        'active' => 'Actif',
        'suspended' => 'Suspendu',
        'pending' => 'En attente'
      }
      
      color_class = colors[status.to_s] || 'bg-gray-100 text-gray-800'
      label = labels[status.to_s] || status.to_s.capitalize
      
      content_tag(:span, label, class: "px-2 py-1 text-xs font-medium rounded-full #{color_class}")
    end

    def role_label(role)
      labels = {
        'admin' => 'Admin',
        'seller' => 'Vendeur (Cédant)',
        'buyer' => 'Repreneur',
        'partner' => 'Partenaire'
      }
      labels[role.to_s] || role.to_s.capitalize
    end

    def status_label(status)
      labels = {
        'active' => 'Actif',
        'suspended' => 'Suspendu',
        'pending' => 'En attente'
      }
      labels[status.to_s] || status.to_s.capitalize
    end
  end
end
