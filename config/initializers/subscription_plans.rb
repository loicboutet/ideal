# Subscription Plans Configuration
# Defines all subscription tiers, pricing, and features for the Idéal Reprise platform

SUBSCRIPTION_PLANS = {
  buyer: {
    free: {
      name: 'Free',
      price_cents: 0,
      price_display: '€0',
      interval: 'month',
      stripe_price_id: nil, # No Stripe price for free tier
      features: [
        'Browse listings',
        'View basic information',
        'Limited access to features',
        'Save favorites',
        'Basic search'
      ],
      limits: {
        reservations_per_month: 0,
        active_deals: 0,
        advanced_search: false,
        partner_directory: false,
        enrichment_requests: 0
      }
    },
    starter: {
      name: 'Starter',
      price_cents: 8900, # €89.00
      price_display: '€89',
      interval: 'month',
      stripe_price_id: ENV['STRIPE_BUYER_STARTER_PRICE_ID'], # Set in credentials or ENV
      features: [
        'Everything in Free',
        'Reserve up to 3 listings',
        'Basic CRM pipeline',
        '10-day timer per deal',
        'Basic enrichment requests (2/month)',
        'Email support'
      ],
      limits: {
        reservations_per_month: 3,
        active_deals: 3,
        advanced_search: false,
        partner_directory: false,
        enrichment_requests: 2
      }
    },
    standard: {
      name: 'Standard',
      price_cents: 19900, # €199.00
      price_display: '€199',
      interval: 'month',
      stripe_price_id: ENV['STRIPE_BUYER_STANDARD_PRICE_ID'],
      features: [
        'Everything in Starter',
        'Reserve up to 10 listings',
        'Full CRM pipeline access',
        '15-day timer per deal',
        'Advanced search filters',
        'Enrichment requests (5/month)',
        'Partner directory access',
        'Priority support'
      ],
      limits: {
        reservations_per_month: 10,
        active_deals: 10,
        advanced_search: true,
        partner_directory: true,
        enrichment_requests: 5
      }
    },
    premium: {
      name: 'Premium',
      price_cents: 24900, # €249.00
      price_display: '€249',
      interval: 'month',
      stripe_price_id: ENV['STRIPE_BUYER_PREMIUM_PRICE_ID'],
      features: [
        'Everything in Standard',
        'Unlimited reservations',
        'Unlimited active deals',
        '30-day timer per deal',
        'Unlimited enrichment requests',
        'Exclusive deal assignments',
        'Custom matching alerts',
        'Dedicated account manager'
      ],
      limits: {
        reservations_per_month: 999,
        active_deals: 999,
        advanced_search: true,
        partner_directory: true,
        enrichment_requests: 999
      }
    },
    club: {
      name: 'Club',
      price_cents: 120000, # €1,200.00 per year
      price_display: '€1,200',
      interval: 'year',
      stripe_price_id: ENV['STRIPE_BUYER_CLUB_PRICE_ID'],
      features: [
        'Everything in Premium',
        '1-hour coaching session included',
        'Annual billing (2 months free)',
        'VIP treatment',
        'First access to new listings',
        'Networking events access',
        'Custom reports',
        '24/7 priority support'
      ],
      limits: {
        reservations_per_month: 999,
        active_deals: 999,
        advanced_search: true,
        partner_directory: true,
        enrichment_requests: 999
      }
    }
  },
  
  seller: {
    free: {
      name: 'Free',
      price_cents: 0,
      price_display: '€0',
      interval: 'month',
      stripe_price_id: nil,
      features: [
        'Create up to 3 listings',
        'Basic listing features',
        'View interested buyers',
        'Standard support'
      ],
      limits: {
        max_listings: 3,
        push_quota_per_month: 0,
        partner_directory_access: false,
        premium_analytics: false
      }
    },
    premium: {
      name: 'Premium (Broker)',
      price_cents: 29900, # €299.00 - Set actual price
      price_display: '€299',
      interval: 'month',
      stripe_price_id: ENV['STRIPE_SELLER_PREMIUM_PRICE_ID'],
      features: [
        'Unlimited listings',
        'Push to 5 buyers per month',
        'Partner directory access (first 6 months free)',
        'Premium analytics',
        'Featured placement',
        'Priority support',
        'Dedicated account manager'
      ],
      limits: {
        max_listings: 999,
        push_quota_per_month: 5,
        partner_directory_access: true,
        partner_directory_free_months: 6,
        premium_analytics: true
      }
    }
  },
  
  partner: {
    free: {
      name: 'Not Listed',
      price_cents: 0,
      price_display: '€0',
      interval: 'year',
      stripe_price_id: nil,
      features: [
        'Profile page (not visible in directory)',
        'Receive contact requests',
        'Basic analytics'
      ],
      limits: {
        directory_visible: false
      }
    },
    annual: {
      name: 'Directory Listing',
      price_cents: 49900, # €499.00 per year - Set actual price
      price_display: '€499',
      interval: 'year',
      stripe_price_id: ENV['STRIPE_PARTNER_ANNUAL_PRICE_ID'],
      features: [
        'Visible in partner directory',
        'Featured profile',
        'Receive unlimited contacts',
        'Advanced analytics',
        'Logo and branding',
        'Direct messaging',
        'Annual renewal'
      ],
      limits: {
        directory_visible: true
      }
    }
  }
}.freeze

# Helper module for subscription plan access
module SubscriptionPlans
  class << self
    def for_role(role)
      SUBSCRIPTION_PLANS[role.to_sym] || {}
    end
    
    def plan_details(role, plan_type)
      for_role(role)[plan_type.to_sym]
    end
    
    def all_buyer_plans
      SUBSCRIPTION_PLANS[:buyer]
    end
    
    def all_seller_plans
      SUBSCRIPTION_PLANS[:seller]
    end
    
    def all_partner_plans
      SUBSCRIPTION_PLANS[:partner]
    end
    
    def paid_plans_for_role(role)
      for_role(role).select { |_key, plan| plan[:price_cents] > 0 }
    end
    
    def plan_feature_limit(role, plan_type, feature)
      plan = plan_details(role, plan_type)
      return nil unless plan
      
      plan.dig(:limits, feature.to_sym)
    end
    
    def plan_has_feature?(role, plan_type, feature)
      limit = plan_feature_limit(role, plan_type, feature)
      return false if limit.nil?
      return limit if [true, false].include?(limit)
      
      limit > 0
    end
  end
end
