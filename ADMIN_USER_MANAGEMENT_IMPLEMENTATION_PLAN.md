# Admin User Management Implementation Plan
## Brick 1 - User Account Creation & Management

### Current State Analysis

#### ✅ What's Already Implemented:
- User model with role/status enums (admin, seller, buyer, partner + pending/active/suspended)
- Profile associations (seller_profile, buyer_profile, partner_profile) 
- Complete routing structure in routes.rb for admin user management
- Basic authentication and authorization framework with AdminController
- UI mockup design showing desired interface at `/mockups/admin/users`

#### ❌ Critical Missing Components:
1. **Admin::UsersController implementation** - Routes exist but no controller
2. **Admin user management view templates** - No views for user CRUD operations
3. **Bulk Excel import system** - For importing 800+ existing leads
4. **Enhanced seller creation** - Creating sellers WITH their initial listings capability
5. **Deal assignment during validation** - Admin attribution of deals for sourcing
6. **Profile validation workflows** - Manual validation for partners

---

## Phase 1: Core Admin Users Controller & Views
**Priority: HIGH | Estimated: 1 task**

### Files to Create/Modify:
- `app/controllers/admin/users_controller.rb`
- `app/views/admin/users/index.html.erb`
- `app/views/admin/users/show.html.erb`
- `app/views/admin/users/new.html.erb`
- `app/views/admin/users/edit.html.erb`
- `app/views/admin/users/_form.html.erb`
- `app/views/admin/users/_user_card.html.erb`

### Controller Actions Required:
```ruby
class Admin::UsersController < AdminController
  # Standard CRUD
  def index     # List all users with filtering
  def show      # User details
  def new       # Create new user
  def create    # Save new user
  def edit      # Edit user
  def update    # Update user
  def destroy   # Delete user (soft delete)
  
  # Status management
  def activate    # Activate user
  def suspend     # Suspend user
  def change_role # Change user role
  
  # Filtering
  def sellers   # Filter sellers only
  def buyers    # Filter buyers only  
  def partners  # Filter partners only
  
  # Bulk operations
  def bulk_import # Excel import interface
  def import      # Process import
end
```

### Key Features to Implement:
- **User List View**: Table matching mockup design with filtering
- **Search & Filter**: By role, status, registration date, email
- **User Details**: Complete user profile view
- **Status Management**: Activate/Suspend users with confirmation
- **Role Management**: Change user roles with validation
- **User Creation**: Forms for each role type

### UI Components (Based on Mockup):
- User avatar initials (colored by role)
- Role badges (Vendeur, Repreneur, Partenaire)
- Status indicators (Actif, Suspendu, En attente)
- Action buttons (View, Edit, Suspend)
- Filtering dropdowns (Tous les rôles, Tous les statuts, Plus récents)
- Search bar
- "Nouvel utilisateur" create button

---

## Phase 2: Enhanced Role-Specific User Creation
**Priority: HIGH | Estimated: 1 task**

### Files to Create/Modify:
- `app/views/admin/users/new_seller.html.erb`
- `app/views/admin/users/new_buyer.html.erb` 
- `app/views/admin/users/new_partner.html.erb`
- `app/views/admin/users/_seller_form.html.erb`
- `app/views/admin/users/_buyer_form.html.erb`
- `app/views/admin/users/_partner_form.html.erb`
- `app/services/admin/user_creator_service.rb`

### Role-Specific Features:

#### **Seller Creation**:
```ruby
# Seller fields to include:
- Basic user info (email, password, first_name, last_name, phone)
- Company info (company_name, industry_sector)
- Initial credits allocation
- Premium access flag
- Option to create initial listing simultaneously
```

#### **Buyer Creation**:
```ruby
# Buyer fields to include:
- Basic user info
- Buyer type (individual, holding, fund, investor)
- Investment capacity range
- Target sectors of interest
- Profile completeness setup
- Subscription plan assignment
```

#### **Partner Creation**:
```ruby
# Partner fields to include:
- Basic user info  
- Partner type (lawyer, accountant, consultant, banker, broker)
- Coverage area (city, department, region, nationwide, international)
- Services offered
- Queue for manual validation
- Directory subscription setup
```

### Services to Create:
- `UserCreatorService` - Handle complex user creation with profiles
- `SellerListingService` - Create seller + initial listing atomically
- `PartnerValidationService` - Queue partners for approval

---

## Phase 3: Bulk Excel Import System
**Priority: MEDIUM | Estimated: 1 task**

### Files to Create/Modify:
- `app/controllers/admin/imports_controller.rb`
- `app/views/admin/imports/index.html.erb`
- `app/views/admin/imports/new.html.erb`
- `app/views/admin/imports/show.html.erb`
- `app/services/admin/excel_import_service.rb`
- `app/jobs/bulk_user_import_job.rb`
- `app/models/lead_import.rb` (already exists)

### Import Process Flow:
1. **Upload Excel File**: Admin uploads .xlsx/.csv file
2. **Data Preview**: Show first 10 rows, column mapping interface
3. **Mapping Configuration**: Map Excel columns to user fields
4. **Validation**: Check for duplicates, invalid data
5. **Background Processing**: Process import via background job
6. **Results Report**: Success/failure counts, error details

### Import Features:
```ruby
# Excel columns expected:
- first_name, last_name, email, phone
- role (seller/buyer/partner)  
- company_name (for sellers/partners)
- industry_sector (for sellers)
- notes/comments

# Import validations:
- Email format and uniqueness
- Required fields per role
- Data format validation
- Duplicate detection across Excel and existing users
```

### Background Job Processing:
- Process in batches of 50 users
- Progress tracking with percentage complete
- Error collection and reporting
- Email notification on completion

---

## Phase 4: Deal Attribution & Assignment
**Priority: MEDIUM | Estimated: 1 task**

### Files to Create/Modify:
- `app/controllers/admin/deals_controller.rb`
- `app/views/admin/listings/_validation_form.html.erb`
- `app/views/admin/deals/assign_form.html.erb`
- `app/services/admin/deal_attribution_service.rb`
- Add deal attribution fields to listing validation flow

### Deal Assignment Features:

#### **During Listing Validation**:
```ruby
# When admin approves a listing, option to:
- Assign deal to specific buyer (exclusive access)
- Mark as "sourced by admin" for attribution
- Set assignment expiry date
- Add internal notes about assignment
```

#### **Exclusive Deal Assignment**:
```ruby
# Admin can assign deals to buyers:
- Search and select buyer from dropdown
- Set exclusive access period (7-30 days)
- Add assignment reason/notes
- Send notification to assigned buyer
- Track assignment history
```

#### **Sourcing Attribution**:
```ruby
# Track deals sourced by admin team:
- Mark listings as "admin sourced" during validation
- Attribute to specific admin user
- Track sourcing performance metrics
- Generate attribution reports for team
```

### Deal Management Interface:
- Deal list with assignment status
- Quick assign functionality
- Assignment history tracking
- Attribution reporting dashboard

---

## Implementation Dependencies

### **Phase Dependencies**:
- **Phase 1** is prerequisite for all other phases
- **Phase 2** builds directly on Phase 1 user creation
- **Phase 3 & 4** can be developed independently after Phase 1

### **Required Gems** (add to Gemfile if not present):
```ruby
gem 'roo'           # Excel file reading
gem 'roo-xls'       # .xls support  
gem 'sidekiq'       # Background jobs (if not using Solid Queue)
gem 'image_processing' # For avatar image handling
```

### **Database Considerations**:
- Existing migrations look complete for user management
- May need index on users(role, status, created_at) for fast filtering
- Consider adding admin attribution fields to listings table

---

## Success Criteria

### **Phase 1 Complete When**:
✅ Admin can view all users in filterable list  
✅ Admin can create users of any role  
✅ Admin can activate/suspend user accounts  
✅ Admin can change user roles  
✅ UI matches mockup design exactly  

### **Phase 2 Complete When**:
✅ Role-specific user creation forms work  
✅ Seller creation can include initial listing  
✅ Partner creation queues for validation  
✅ Profile setup works for each role  

### **Phase 3 Complete When**:  
✅ Admin can upload Excel files with 800+ leads  
✅ System validates and processes imports  
✅ Background processing prevents timeout  
✅ Detailed success/error reporting works  

### **Phase 4 Complete When**:
✅ Admin can assign deals during validation  
✅ Exclusive buyer assignment works  
✅ Deal attribution tracking functional  
✅ Assignment history and reporting available  

---

## Getting Started

### **Phase 1 Task Breakdown**:
1. Create `Admin::UsersController` with index, show, new, create actions
2. Build user index view matching mockup exactly  
3. Add filtering and search functionality
4. Implement user status management (activate/suspend)
5. Add user creation forms for basic user types
6. Test all CRUD operations thoroughly

### **Next Steps**:
After completing Phase 1, create additional tasks for:
- Phase 2: "Enhanced Role-Specific User Creation" 
- Phase 3: "Bulk Excel Import System"
- Phase 4: "Deal Attribution & Assignment"

Each phase can be implemented as a separate task, building on the foundation of Phase 1.
