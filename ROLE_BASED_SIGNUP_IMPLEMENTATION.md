# Role-Based Sign Up Implementation Guide

## Overview

This document describes the implementation of role-based sign-up flow for Idéal Reprise platform, supporting three distinct user roles: **Seller** (Vendeur), **Buyer** (Acheteur), and **Partner** (Partenaire).

## Implementation Approach

**Single-Page Dropdown Registration** - Users select their role from a dropdown menu on a single registration page, and role-specific fields appear/hide dynamically using JavaScript.

## ✅ Completed Features

1. **Single-Page Registration Form** (`/users/sign_up` or `/inscription`)
   - Role dropdown selector at the top
   - Common fields visible for all roles
   - Role-specific fields that appear/hide dynamically
   - No page redirects during role selection
   - Clean, modern UI with Tailwind CSS

2. **Dynamic Field Display with Stimulus**
   - `role_selector_controller.js` handles field visibility
   - Buyer-specific fields (buyer type dropdown)
   - Partner-specific fields (company name, partner type, validation notice)
   - Seller has no additional fields beyond common ones

3. **Role-Based Registration Logic**
   - **Seller**: Immediate "active" status → Redirects to seller dashboard
   - **Buyer**: Immediate "active" status → Redirects to buyer profile
   - **Partner**: Set to "pending" status → Redirects to pending approval page

4. **Pending Approval Page** (`/inscription/en-attente`)
   - Partner-only access after registration
   - Clear explanation of validation process
   - Timeline: 48-72 hours
   - Professional, reassuring design

5. **Automatic Profile Creation**
   - Role-specific data stored in profiles
   - Buyer type saved in BuyerProfile
   - Partner type and company name saved in PartnerProfile

## File Structure

### Controllers
```
app/controllers/users/registrations_controller.rb
```
- Overrides Devise registration controller
- `create` - Handles registration with role-based status
- `pending_approval` - Displays pending approval page for partners

### Views
```
app/views/devise/registrations/
├── new.html.erb                 # Single-page registration with dropdown
└── pending_approval.html.erb    # Partner pending approval page
```

### JavaScript
```
app/javascript/controllers/role_selector_controller.js
```
- Stimulus controller for dynamic field visibility
- Listens to role dropdown changes
- Shows/hides buyer and partner-specific fields

### Routes
```ruby
# Standard Devise routes with custom controller
devise_for :users, controllers: { registrations: 'users/registrations' }

# Additional routes
get '/inscription', to: 'devise/registrations#new'
get '/inscription/en-attente', to: 'users/registrations#pending_approval'
```

## User Registration Flow

### Common Steps (All Roles)
1. User visits `/inscription` or `/users/sign_up`
2. Sees single registration form
3. Selects role from dropdown: Vendeur / Acheteur / Partenaire
4. Fills common fields: prénom, nom, email, phone, password
5. Role-specific fields appear based on dropdown selection

### Seller Journey
1. Select "Vendeur" from dropdown
2. No additional fields appear
3. Submit form
4. Account created with `role: seller`, `status: active`
5. SellerProfile created automatically
6. Redirected to seller dashboard
7. Can immediately create listings

### Buyer Journey  
1. Select "Acheteur" from dropdown
2. Buyer-specific section appears with buyer type dropdown
3. Select buyer type (Particulier, Holding, Fund, Investor) - optional
4. Submit form
5. Account created with `role: buyer`, `status: active`
6. BuyerProfile created with buyer_type if provided
7. Redirected to buyer profile page
8. Prompted to complete profile

### Partner Journey
1. Select "Partenaire" from dropdown
2. Partner-specific section appears with:
   - Company name field
   - Partner type dropdown (Avocat, Expert-comptable, etc.)
   - Validation notice (48-72h)
3. Fill partner-specific fields
4. Submit form
5. Account created with `role: partner`, `status: pending`
6. PartnerProfile created with company_name and partner_type
7. Redirected to `/inscription/en-attente`
8. Sees pending approval page
9. Waits for admin validation
10. Receives email when approved/rejected

## Technical Implementation

### Dynamic Field Visibility (Stimulus)

```javascript
// app/javascript/controllers/role_selector_controller.js
export default class extends Controller {
  static targets = ["buyerFields", "partnerFields", "roleSelect"]

  toggleFields() {
    const selectedRole = this.roleSelectTarget.value
    
    // Hide all role-specific fields
    this.buyerFieldsTarget.classList.add('hidden')
    this.partnerFieldsTarget.classList.add('hidden')
    
    // Show relevant fields
    if (selectedRole === 'buyer') {
      this.buyerFieldsTarget.classList.remove('hidden')
    } else if (selectedRole === 'partner') {
      this.partnerFieldsTarget.classList.remove('hidden')
    }
  }
}
```

### Status Management

```ruby
# In Users::RegistrationsController
def create
  build_resource(sign_up_params)
  
  # Set status based on role
  resource.status = resource.role == 'partner' ? :pending : :active
  
  # ... rest of create logic
end
```

### Profile Creation

```ruby
# In User model
def create_profile
  case role
  when 'seller'
    create_seller_profile! unless seller_profile
  when 'buyer'
    profile_attrs = {}
    profile_attrs[:buyer_type] = @buyer_type if @buyer_type.present?
    create_buyer_profile!(profile_attrs) unless buyer_profile
  when 'partner'
    profile_attrs = {}
    profile_attrs[:partner_type] = @partner_type if @partner_type.present?
    profile_attrs[:company_name] = @company_name if @company_name.present?
    create_partner_profile!(profile_attrs) unless partner_profile
  end
end
```

### Strong Parameters

```ruby
def configure_sign_up_params
  devise_parameter_sanitizer.permit(:sign_up, keys: [
    :first_name, 
    :last_name, 
    :phone, 
    :role,
    :company_name,
    :buyer_type,
    :partner_type
  ])
end
```

## Design Features

### User Experience
- **Single Page**: All registration on one page, no multi-step flow
- **Dynamic Fields**: Role-specific fields appear instantly on role change
- **Visual Feedback**: Color-coded sections for buyer (blue) and partner (purple)
- **Clear Labels**: French labels with helpful descriptions
- **Validation Notice**: Partners see upfront that validation is required
- **Mobile Responsive**: Works on all screen sizes

### UI Components
- Role dropdown with clear descriptions
- Colored info boxes for role-specific sections
- Validation warning for partners
- Professional icons and styling
- Consistent with platform design

## Partner Validation Workflow

### Current State
- Partners register with status set to `pending`
- See pending approval page immediately after registration
- Cannot access partner features until approved

### Admin Actions (Existing)
The admin panel already has partner validation at:
- `/admin/partners` - List all partners
- `/admin/partners/pending` - View pending partners
- `/admin/partners/:id/approve` - Approve partner
- `/admin/partners/:id/reject` - Reject partner

When admin approves:
1. User status changes from `pending` to `active`
2. Partner receives email notification (to implement)
3. Partner can access partner dashboard

## Benefits of This Approach

✅ **Simplicity**: One page, one form, simple flow
✅ **Speed**: No page reloads, instant field updates
✅ **Flexibility**: Users can easily change role selection
✅ **Modern UX**: Dynamic, responsive interface
✅ **Less Code**: Single view file, minimal controller logic
✅ **Maintainability**: Easier to update common fields
✅ **Accessibility**: Better for screen readers (one form flow)

## Testing Checklist

- [ ] Seller can register and access dashboard immediately
- [ ] Buyer can register with optional buyer type selection
- [ ] Buyer type is saved correctly in BuyerProfile
- [ ] Partner registration shows validation notice
- [ ] Partner fields (company name, partner type) save correctly
- [ ] Partner status set to "pending" after registration
- [ ] Partner redirected to pending approval page
- [ ] Partner cannot access partner dashboard while pending
- [ ] Role dropdown triggers field visibility correctly
- [ ] Form validation works (required fields, password strength)
- [ ] Mobile responsive design works
- [ ] All three roles can sign in after registration
- [ ] Redirects work correctly per role

## Future Enhancements

### Recommended Next Steps
1. **Email Notifications**
   - Partner registration confirmation
   - Partner approval/rejection notifications
   - Welcome emails for sellers and buyers

2. **Buyer Profile Wizard**
   - Multi-step profile completion
   - Progress indicator
   - Save and continue later

3. **Admin Partner Validation**
   - Email notifications to admin on new partner registration
   - Streamlined approval workflow

4. **Email Verification**
   - Optional email confirmation before activation
   - Reduces spam registrations

## Security & Validation

1. **Input Validation**
   - All inputs sanitized
   - Strong parameters enforced
   - Role parameter validated

2. **Authorization**
   - Pending partners cannot access partner features
   - Role-based redirects after sign-up
   - Devise authentication

3. **Data Privacy**
   - GDPR compliant
   - Secure password storage (bcrypt)
   - User consent for data processing

## Maintenance

### Adding New Roles
1. Update User model enum
2. Add role option to dropdown
3. Create role-specific field section if needed
4. Update Stimulus controller targets
5. Add profile creation logic
6. Update redirect logic in controller

### Modifying Fields
1. Update form view for common fields
2. Update role-specific sections for role fields
3. Update strong parameters in controller
4. Update profile creation logic if needed

## Support

For questions or issues:
- Review this implementation guide
- Check Devise documentation
- Check Stimulus documentation
- Contact development team

## Changelog

### Version 2.0 (November 2025)
- **Changed from multi-page to single-page approach**
- Single registration form with role dropdown
- Dynamic field visibility with Stimulus
- Simplified routing
- Improved user experience
- Less code, easier maintenance

### Version 1.0 (November 2025)
- Initial multi-page implementation
- Separate URLs per role
- Role selection landing page

---

**Status**: ✅ Single-Page Implementation Complete  
**Approach**: Dropdown with dynamic fields
**Next Steps**: Testing, email notifications
