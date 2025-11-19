# Admin Platform Settings Implementation

## Overview
Complete implementation of the Platform Settings feature for admin users, allowing configuration of pricing, pipeline timers, and customizable texts.

## Implementation Date
November 19, 2025

## Features Implemented

### 1. Database & Model
- **PlatformSetting Model**: Already existed with flexible key-value storage
- **Database Seeding**: Created rake task to seed default platform settings
- **19 Settings Created**:
  - Buyer subscription pricing (4 plans)
  - Credit packs pricing and quantities (3 packs)
  - Pipeline timer durations (3 timed stages)
  - Customizable text messages (6 texts)

### 2. Routes
- `GET /admin/settings` - View platform settings
- `PATCH /admin/settings` - Update platform settings

### 3. Controller
**File**: `app/controllers/admin/settings_controller.rb`
- Admin authorization check
- Settings retrieval via service layer
- Settings update with validation
- Activity logging for all changes
- Flash messages for success/error feedback

### 4. Service Layer
**File**: `app/services/admin/platform_settings_service.rb`
- Fetches settings grouped by category (pricing, timers, texts)
- Validates all settings before saving:
  - **Timers**: 7-60 days range
  - **Prices**: Must be > 0
  - **Credits**: Must be > 0
  - **Texts**: Not blank, max 1000 characters
- Atomic transaction updates
- Error collection and reporting

### 5. Views
**File**: `app/views/admin/settings/show.html.erb`
- Clean, organized interface matching admin style
- Three main sections:
  1. **Pricing & Offers**
     - Buyer subscription plans (Starter, Standard, Premium, Club)
     - Credit packs (Small, Medium, Large)
  2. **Pipeline Timers**
     - To Contact (7 days default)
     - Info Exchange + Analysis + Alignment (33 days default)
     - Negotiation (20 days default)
     - LOI (disabled - requires seller validation)
  3. **Customizable Texts**
     - Welcome message
     - Validation message
     - Offer descriptions (4 plans)

### 6. Deal Timer Integration
**Files**: 
- `app/models/concerns/deal_timer.rb` (new concern)
- `app/models/deal.rb` (updated)

**Features**:
- Dynamic timer calculation based on platform settings
- Automatic timer updates when deals change status
- Helper methods for timer status:
  - `timer_expired?`
  - `days_remaining`
  - `timer_percentage`
  - `time_extending?`
- Support for shared timers (info_exchange, analysis, project_alignment)
- Proper handling of non-timed stages (LOI, Audits, Financing, Deal Signed)

### 7. Navigation
- Added Settings link to admin sidebar
- Active state highlighting
- Settings icon

### 8. Activity Logging
- All setting changes logged to Activity model
- Tracks which admin made changes
- Records changed setting keys
- Includes IP address

## Settings Structure

### Pricing Settings
```ruby
{
  buyer_plan_starter_monthly: "89",      # € per month
  buyer_plan_standard_monthly: "199",    # € per month
  buyer_plan_premium_monthly: "249",     # € per month
  buyer_plan_club_annual: "1200",        # € per year
  credits_pack_small_price: "50",        # € for pack
  credits_pack_small_credits: "10",      # credits in pack
  credits_pack_medium_price: "100",      # € for pack
  credits_pack_medium_credits: "25",     # credits in pack
  credits_pack_large_price: "180",       # € for pack
  credits_pack_large_credits: "50"       # credits in pack
}
```

### Timer Settings
```ruby
{
  timer_to_contact: "7",                      # days
  timer_info_analysis_alignment: "33",        # days (shared timer)
  timer_negotiation: "20"                     # days
}
```

### Text Settings
```ruby
{
  text_welcome_message: "Bienvenue sur Idéal Reprise...",
  text_validation_message: "Votre annonce a été validée...",
  text_offer_starter: "Accès de base aux annonces",
  text_offer_standard: "Accès complet + réservations illimitées",
  text_offer_premium: "Tous les avantages + badge vérifié",
  text_offer_club: "Accès VIP + coaching personnalisé"
}
```

## Pipeline Timer Logic

### Timed Stages
1. **To Contact**: Configurable timer (default 7 days)
2. **Info Exchange**: Share 33-day timer
3. **Analysis**: Share 33-day timer  
4. **Project Alignment**: Share 33-day timer
5. **Negotiation**: Configurable timer (default 20 days)

### Non-Timed Stages
- **LOI**: Requires seller validation (pauses timer)
- **Audits**: No timer
- **Financing**: No timer
- **Deal Signed**: No timer

### Timer Behavior
- Timer starts when deal enters a timed stage
- `stage_entered_at` updated on status change
- `reserved_until` calculated based on platform settings
- Timers update dynamically when settings change (for new deals)
- Existing deals retain their original `reserved_until` dates

## Usage

### Accessing Settings
```ruby
# In controllers/services
service = Admin::PlatformSettingsService.new
settings = service.fetch_all

# Access specific setting
timer_days = PlatformSetting.get('timer_to_contact').to_i

# In Deal model (via DealTimer concern)
days = Deal.timer_duration_for_status(:to_contact)
# Returns value from platform settings
```

### Updating Settings
Admin users can update settings via:
1. Navigate to `/admin/settings`
2. Modify desired values
3. Click "Enregistrer les modifications"
4. Changes validated and saved
5. Activity logged

## Validation Rules

### Timers
- Minimum: 7 days (1 week)
- Maximum: 60 days (2 months)
- Must be integer values

### Pricing
- Must be positive numbers
- Can have decimal values (e.g., 89.99)

### Credits
- Must be positive integers
- Whole numbers only

### Texts
- Cannot be blank
- Maximum 1000 characters
- UTF-8 encoded

## Security

### Authorization
- Only admin users can access settings
- `before_action :require_admin` in controller
- Redirects non-admins with alert

### Audit Trail
- All changes logged to Activity model
- Includes:
  - User ID (who made the change)
  - Timestamp (when)
  - Changed settings (what)
  - IP address (from where)

### Input Validation
- Server-side validation for all inputs
- HTML5 validation on form fields
- XSS protection via Rails sanitization

## Files Created/Modified

### Created
1. `lib/tasks/seed_platform_settings.rake`
2. `app/controllers/admin/settings_controller.rb`
3. `app/services/admin/platform_settings_service.rb`
4. `app/views/admin/settings/show.html.erb`
5. `app/models/concerns/deal_timer.rb`
6. `ADMIN_PLATFORM_SETTINGS_IMPLEMENTATION.md`

### Modified
1. `config/routes.rb` - Added settings resource
2. `app/views/layouts/admin.html.erb` - Added navigation link
3. `app/models/deal.rb` - Integrated DealTimer concern

## Testing Recommendations

### Manual Testing
1. **Access Settings Page**
   - Login as admin
   - Navigate to Settings
   - Verify all current values displayed correctly

2. **Update Pricing**
   - Change a subscription price
   - Save and verify success message
   - Check database for updated value

3. **Update Timers**
   - Try values below 7 days (should fail)
   - Try values above 60 days (should fail)
   - Set valid value (should succeed)

4. **Update Texts**
   - Try empty text (should fail)
   - Try very long text >1000 chars (should fail)
   - Set valid text (should succeed)

5. **Deal Timer Integration**
   - Create/update deal to timed stage
   - Verify `reserved_until` calculated correctly
   - Change timer setting
   - Create new deal
   - Verify new deal uses updated timer

### Automated Testing (Future)
```ruby
# spec/services/admin/platform_settings_service_spec.rb
describe Admin::PlatformSettingsService do
  describe '#update_settings' do
    it 'validates timer ranges'
    it 'validates positive prices'
    it 'validates text length'
    it 'updates settings atomically'
  end
end

# spec/models/concerns/deal_timer_spec.rb
describe DealTimer do
  describe '.timer_duration_for_status' do
    it 'returns correct timer for each status'
    it 'uses platform settings'
  end
end
```

## Integration Points

### Used By
- **Deal Management**: Timer calculations for reservations
- **Pricing Pages**: Display current subscription prices
- **Checkout Flow**: Use pricing from settings
- **Email Templates**: Use text settings for messages
- **Notification System**: Use text settings for alerts

### Dependencies
- **PlatformSetting Model**: Data storage
- **Activity Model**: Audit logging
- **Deal Model**: Timer integration
- **Admin Layout**: Navigation

## Future Enhancements

### Potential Additions
1. **Setting History**: Track changes over time
2. **Setting Categories**: Organize into more categories
3. **Bulk Import/Export**: JSON/YAML import/export
4. **Setting Permissions**: Granular per-setting permissions
5. **Setting Validation Rules**: Custom validation rules per setting
6. **Setting Dependencies**: Enforce relationships between settings
7. **Preview Mode**: Preview changes before saving
8. **Rollback**: Revert to previous settings
9. **Multi-Currency**: Support for different currencies
10. **Localization**: Multi-language text settings

## Notes

- Timer settings affect new deals only; existing deals retain original timers
- LOI stage intentionally has no timer (requires seller validation)
- Info Exchange, Analysis, and Project Alignment share a single 33-day timer
- All monetary values are in Euros (€)
- Activity logging is automatic and cannot be disabled
- Settings are cached in memory (PlatformSetting.get)

## Troubleshooting

### Settings Not Saving
- Check validation errors in flash messages
- Verify admin authorization
- Check server logs for errors

### Timers Not Working
- Verify settings seeded: `rails db:seed:platform_settings`
- Check DealTimer concern is included in Deal model
- Verify `before_save` callback is enabled

### Navigation Link Not Showing
- Clear browser cache
- Restart Rails server
- Check admin layout file updated

## Conclusion

The Platform Settings feature is fully implemented and ready for use. Admin users can now configure critical platform parameters through an intuitive interface, with all changes validated, logged, and immediately effective for new deals and transactions.
