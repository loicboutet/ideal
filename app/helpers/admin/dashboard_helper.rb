# frozen_string_literal: true

module Admin::DashboardHelper
  # Evolution badge with color coding
  def evolution_badge(percentage)
    return content_tag(:span, '0%', class: 'text-sm text-gray-500') if percentage.zero?
    
    color_class = percentage.positive? ? 'text-green-600' : 'text-red-600'
    icon = percentage.positive? ? '↑' : '↓'
    
    content_tag(:span, class: "text-sm font-medium #{color_class}") do
      "#{icon} #{percentage.abs}%"
    end
  end
  
  # Trend indicator arrow
  def trend_indicator(current, previous)
    return content_tag(:span, '—', class: 'text-gray-400') if previous.zero?
    
    if current > previous
      content_tag(:span, '↑', class: 'text-green-500 text-xl font-bold')
    elsif current < previous
      content_tag(:span, '↓', class: 'text-red-500 text-xl font-bold')
    else
      content_tag(:span, '→', class: 'text-gray-400 text-xl')
    end
  end
  
  # Period label humanizer
  def period_label(period)
    {
      'day' => "Aujourd'hui",
      'week' => 'Cette semaine',
      'month' => 'Ce mois',
      'quarter' => 'Ce trimestre',
      'year' => 'Cette année'
    }[period] || 'Période personnalisée'
  end
  
  # Period selector button
  def period_button(label, period_value, current_period)
    active = current_period == period_value
    css_class = if active
                  'px-4 py-2 rounded-lg bg-admin-600 text-white font-medium'
                else
                  'px-4 py-2 rounded-lg bg-gray-100 text-gray-700 hover:bg-gray-200 transition'
                end
    
    link_to label, admin_root_path(period: period_value), class: css_class
  end
  
  # Alert KPI card
  def alert_kpi_card(title, count, icon_path, link_path, color: 'orange')
    color_classes = {
      'orange' => {
        bg: 'bg-orange-50',
        border: 'border-orange-200',
        icon: 'text-orange-600',
        text: 'text-orange-900',
        button: 'bg-orange-600 hover:bg-orange-700'
      },
      'purple' => {
        bg: 'bg-purple-50',
        border: 'border-purple-200',
        icon: 'text-purple-600',
        text: 'text-purple-900',
        button: 'bg-purple-600 hover:bg-purple-700'
      },
      'red' => {
        bg: 'bg-red-50',
        border: 'border-red-200',
        icon: 'text-red-600',
        text: 'text-red-900',
        button: 'bg-red-600 hover:bg-red-700'
      },
      'yellow' => {
        bg: 'bg-yellow-50',
        border: 'border-yellow-200',
        icon: 'text-yellow-600',
        text: 'text-yellow-900',
        button: 'bg-yellow-600 hover:bg-yellow-700'
      }
    }
    
    colors = color_classes[color] || color_classes['orange']
    
    content_tag(:div, class: "#{colors[:bg]} #{colors[:border]} border rounded-lg p-6 hover:shadow-lg transition cursor-pointer") do
      link_to link_path, class: 'block' do
        content_tag(:div, class: 'flex items-center justify-between') do
          concat(content_tag(:div, class: 'flex items-center gap-4') do
            concat(content_tag(:div, class: "p-3 #{colors[:bg]} rounded-lg") do
              content_tag(:svg, class: "w-8 h-8 #{colors[:icon]}", fill: 'none', stroke: 'currentColor', viewBox: '0 0 24 24') do
                content_tag(:path, '', 'stroke-linecap': 'round', 'stroke-linejoin': 'round', 'stroke-width': '2', d: icon_path)
              end
            end)
            concat(content_tag(:div) do
              concat(content_tag(:div, count, class: "text-3xl font-bold #{colors[:text]}"))
              concat(content_tag(:div, title, class: 'text-sm text-gray-600 mt-1'))
            end)
          end)
        end
      end
    end
  end
  
  # Growth metric card
  def growth_metric_card(title, metric_data, icon_path, icon_color)
    current = metric_data[:current]
    evolution = metric_data[:evolution]
    
    content_tag(:div, class: 'bg-white rounded-lg shadow-sm p-6 border border-gray-200') do
      concat(content_tag(:div, class: 'flex items-center justify-between mb-4') do
        concat(content_tag(:div, class: "p-3 bg-#{icon_color}-100 rounded-lg") do
          content_tag(:svg, class: "w-6 h-6 text-#{icon_color}-600", fill: 'none', stroke: 'currentColor', viewBox: '0 0 24 24') do
            content_tag(:path, '', 'stroke-linecap': 'round', 'stroke-linejoin': 'round', 'stroke-width': '2', d: icon_path)
          end
        end)
        concat(evolution_badge(evolution))
      end)
      concat(content_tag(:div, number_with_delimiter(current), class: 'text-3xl font-bold text-gray-900'))
      concat(content_tag(:p, title, class: 'text-sm text-gray-500 mt-2'))
    end
  end
  
  # Status badge for deals
  def deal_status_badge(status)
    colors = {
      'favorited' => 'bg-gray-100 text-gray-800',
      'to_contact' => 'bg-blue-100 text-blue-800',
      'info_exchange' => 'bg-indigo-100 text-indigo-800',
      'analysis' => 'bg-purple-100 text-purple-800',
      'project_alignment' => 'bg-pink-100 text-pink-800',
      'negotiation' => 'bg-orange-100 text-orange-800',
      'loi' => 'bg-yellow-100 text-yellow-800',
      'audits' => 'bg-green-100 text-green-800',
      'financing' => 'bg-teal-100 text-teal-800',
      'signed' => 'bg-emerald-100 text-emerald-800',
      'released' => 'bg-gray-100 text-gray-600',
      'abandoned' => 'bg-red-100 text-red-800'
    }
    
    color = colors[status.to_s] || 'bg-gray-100 text-gray-800'
    
    content_tag(:span, class: "px-3 py-1 rounded-full text-xs font-medium #{color}") do
      status.to_s.humanize
    end
  end
  
  # Format currency for display
  def format_revenue(amount)
    return '€0' if amount.zero?
    number_to_currency(amount, unit: '€', separator: ',', delimiter: ' ', precision: 0)
  end
  
  # Chart data formatter for Chart.js
  def chart_data_for_deals(deals_by_status)
    {
      labels: deals_by_status.keys,
      datasets: [{
        label: 'Nombre de transactions',
        data: deals_by_status.values,
        backgroundColor: 'rgba(168, 85, 247, 0.5)',
        borderColor: 'rgba(168, 85, 247, 1)',
        borderWidth: 2
      }]
    }.to_json
  end
  
  # Chart data for abandoned deals (stacked)
  def chart_data_for_abandoned_deals(abandoned_breakdown)
    {
      labels: ['Transactions abandonnées'],
      datasets: [
        {
          label: 'Volontaire',
          data: [abandoned_breakdown[:voluntary]],
          backgroundColor: 'rgba(59, 130, 246, 0.5)',
          borderColor: 'rgba(59, 130, 246, 1)',
          borderWidth: 1
        },
        {
          label: 'Timer expiré',
          data: [abandoned_breakdown[:timer_expired]],
          backgroundColor: 'rgba(239, 68, 68, 0.5)',
          borderColor: 'rgba(239, 68, 68, 1)',
          borderWidth: 1
        }
      ]
    }.to_json
  end
  
  # User role badge
  def user_role_badge(role)
    colors = {
      'admin' => 'bg-purple-100 text-purple-800',
      'seller' => 'bg-green-100 text-green-800',
      'buyer' => 'bg-blue-100 text-blue-800',
      'partner' => 'bg-orange-100 text-orange-800'
    }
    
    color = colors[role.to_s] || 'bg-gray-100 text-gray-800'
    
    content_tag(:span, class: "inline-flex px-2 py-1 rounded text-xs font-medium #{color}") do
      role.to_s.humanize
    end
  end
end
