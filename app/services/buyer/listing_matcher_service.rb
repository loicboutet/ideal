module Buyer
  class ListingMatcherService
    attr_reader :buyer_profile
    
    def initialize(buyer_profile)
      @buyer_profile = buyer_profile
    end
    
    # Returns an array of hashes with listing and match_score
    def find_matches(limit: nil)
      available_listings = Listing.available
                                  .available_for_buyer(buyer_profile)
                                  .includes(:seller_profile)
      
      matches = available_listings.map do |listing|
        {
          listing: listing,
          match_score: calculate_match_score(listing)
        }
      end
      
      # Sort by match score descending and filter out low matches
      matches = matches.select { |m| m[:match_score] >= 30 }
                      .sort_by { |m| -m[:match_score] }
      
      limit ? matches.first(limit) : matches
    end
    
    # Calculate match score between buyer profile and listing (0-100)
    def calculate_match_score(listing)
      return 0 unless listing && buyer_profile
      
      scores = []
      weights = []
      
      # Sector matching (weight: 25%)
      if buyer_profile.target_sectors.present? && buyer_profile.target_sectors.any?
        sector_match = match_sector(listing)
        scores << sector_match
        weights << 25
      end
      
      # Location matching (weight: 20%)
      if buyer_profile.target_locations.present? && buyer_profile.target_locations.any?
        location_match = match_location(listing)
        scores << location_match
        weights << 20
      end
      
      # Revenue matching (weight: 20%)
      if buyer_profile.target_revenue_min.present? || buyer_profile.target_revenue_max.present?
        revenue_match = match_revenue(listing)
        scores << revenue_match
        weights << 20
      end
      
      # Employee count matching (weight: 15%)
      if buyer_profile.target_employees_min.present? || buyer_profile.target_employees_max.present?
        employees_match = match_employees(listing)
        scores << employees_match
        weights << 15
      end
      
      # Transfer type matching (weight: 10%)
      if buyer_profile.target_transfer_types.present? && buyer_profile.target_transfer_types.any?
        transfer_match = match_transfer_type(listing)
        scores << transfer_match
        weights << 10
      end
      
      # Customer type matching (weight: 10%)
      if buyer_profile.target_customer_types.present? && buyer_profile.target_customer_types.any?
        customer_match = match_customer_type(listing)
        scores << customer_match
        weights << 10
      end
      
      # If no criteria are set, return 0
      return 0 if scores.empty?
      
      # Calculate weighted average
      total_weight = weights.sum
      weighted_sum = scores.each_with_index.sum { |score, idx| score * weights[idx] }
      
      (weighted_sum.to_f / total_weight).round
    end
    
    private
    
    def match_sector(listing)
      return 0 unless listing.industry_sector.present?
      buyer_profile.target_sectors.include?(listing.industry_sector) ? 100 : 0
    end
    
    def match_location(listing)
      return 0 unless listing.location_department.present?
      buyer_profile.target_locations.include?(listing.location_department) ? 100 : 0
    end
    
    def match_revenue(listing)
      return 0 unless listing.annual_revenue.present?
      
      revenue = listing.annual_revenue
      min = buyer_profile.target_revenue_min
      max = buyer_profile.target_revenue_max
      
      # No constraints
      return 100 if min.nil? && max.nil?
      
      # Only minimum set
      return revenue >= min ? 100 : 0 if max.nil?
      
      # Only maximum set
      return revenue <= max ? 100 : 0 if min.nil?
      
      # Both set - check if in range
      return 100 if revenue >= min && revenue <= max
      
      # Calculate partial match if close to range
      if revenue < min
        diff = min - revenue
        tolerance = min * 0.2 # 20% tolerance
        return 0 if diff > tolerance
        return ((tolerance - diff) / tolerance * 100).round
      else # revenue > max
        diff = revenue - max
        tolerance = max * 0.2
        return 0 if diff > tolerance
        return ((tolerance - diff) / tolerance * 100).round
      end
    end
    
    def match_employees(listing)
      return 0 unless listing.employee_count.present?
      
      employees = listing.employee_count
      min = buyer_profile.target_employees_min
      max = buyer_profile.target_employees_max
      
      # No constraints
      return 100 if min.nil? && max.nil?
      
      # Only minimum set
      return employees >= min ? 100 : 0 if max.nil?
      
      # Only maximum set
      return employees <= max ? 100 : 0 if min.nil?
      
      # Both set - check if in range
      return 100 if employees >= min && employees <= max
      
      # Calculate partial match if close to range
      if employees < min
        diff = min - employees
        tolerance = [min * 0.2, 10].max.to_i # 20% or 10 employees tolerance
        return 0 if diff > tolerance
        return ((tolerance - diff) / tolerance.to_f * 100).round
      else # employees > max
        diff = employees - max
        tolerance = [max * 0.2, 10].max.to_i
        return 0 if diff > tolerance
        return ((tolerance - diff) / tolerance.to_f * 100).round
      end
    end
    
    def match_transfer_type(listing)
      return 0 unless listing.transfer_type.present?
      buyer_profile.target_transfer_types.include?(listing.transfer_type) ? 100 : 50
    end
    
    def match_customer_type(listing)
      return 0 unless listing.customer_type.present?
      
      # Perfect match
      return 100 if buyer_profile.target_customer_types.include?(listing.customer_type)
      
      # Partial match for mixed
      return 75 if listing.customer_type == 'mixed'
      
      0
    end
  end
end
