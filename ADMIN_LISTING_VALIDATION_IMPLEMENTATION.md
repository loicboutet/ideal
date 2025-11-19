# Admin Listing Validation - Implementation Documentation

**Feature:** Manual validation of seller listings  
**Brick:** 1 - Account Management  
**Date:** November 18, 2025  
**Status:** ✅ Complete

---

## Overview

This feature implements the manual validation workflow for seller listings as specified in Brick 1 of the platform requirements. Admins can review, approve, or reject listings submitted by sellers, with optional deal attribution to specific buyers for sourcing purposes.

## Requirements from Specifications

From `doc/specifications.md`:
- Admins can manually validate seller listings
- Admins can attribute deals during validation (for sourcing)
- Rejection comments are visible to sellers
- Email notifications sent on validation status changes
- Listings are published automatically upon approval

## Implementation

### 1. Controller: `app/controllers/admin/listings_controller.rb`

**Key Features:**
- Layout: `'admin'` for consistent admin interface
- Authentication: `before_action :authenticate_user!`
- Authorization: `before_action :ensure_admin!`
- RESTful actions: index, pending, show, new, create, edit, update, destroy
- Custom actions: `validate`, `reject`

**Actions:**

#### `index`
- Lists all listings with filters
- Supports filtering by: validation_status, status, sector
- Supports search by: title, description, location
- Displays statistics: total, pending, approved, rejected

#### `pending`
- Priority queue for validation
- Orders by created_at ASC (oldest first)
- Shows only pending listings
- Highlights urgent listings (3+ days old)

#### `show`
- Displays listing details
- Shows seller information
- Displays stats (views, favorites, reservations, abandons, completeness)
- Provides validation actions for pending listings

#### `validate`
- Approves listing
- Sets `validation_status = :approved`
- Records `validated_at` timestamp
- Optionally attributes deal to specific buyer via `attributed_buyer_id`
- Publishes listing automatically
- Triggers email notification (via model callback)

#### `reject`
- Rejects listing
- Sets `validation_status = :rejected`
- Records `validated_at` timestamp
- Stores `validation_comment` (visible to seller)
- Triggers email notification (via model callback)

### 2. Routes: `config/routes.rb`

```ruby
namespace :admin do
  resources :listings do
    member do
      patch :validate, :reject
    end
    collection do
      get :pending
    end
  end
end
```

**Generated Routes:**
- `GET  /admin/listings` - index
- `GET  /admin/listings/pending` - pending queue
- `GET  /admin/listings/:id` - show
- `GET  /admin/listings/new` - new
- `POST /admin/listings` - create
- `GET  /admin/listings/:id/edit` - edit
- `PATCH /admin/listings/:id` - update
- `DELETE /admin/listings/:id` - destroy
- `PATCH /admin/listings/:id/validate` - validate
- `PATCH /admin/listings/:id/reject` - reject

### 3. Helper: `app/helpers/admin/listings_helper.rb`

**Helper Methods:**

| Method | Purpose |
|--------|---------|
| `validation_status_badge(status)` | Color-coded badges for validation status |
| `listing_status_badge(status)` | Color-coded badges for listing status |
| `deal_type_badge(deal_type)` | Badges for deal types (direct, mandate, etc.) |
| `sector_badge(sector)` | Display industry sector labels |
| `completeness_gauge(score)` | Visual gauge showing completion % |
| `listing_price_display(listing)` | Format price or price range |
| `listing_stats_summary(listing)` | Calculate listing statistics |
| `days_pending_badge(listing)` | Show days pending with urgency indicator |
| `user_initials_avatar(user)` | Generate avatar with user initials |

**Color Schemes:**
- Validation Status: Yellow (pending), Green (approved), Red (rejected)
- Deal Types: Blue (direct), Purple (ideal mandate), Orange (partner)
- Sectors: Gray text with icons
- Urgency: Red border for 3+ days pending

### 4. Views

#### `app/views/admin/listings/index.html.erb`
- Overview of all listings
- Statistics cards (total, pending, approved, rejected)
- Quick link to pending queue when items exist
- Filters: validation_status, status, sector, search
- Table view with key information
- Links to detail pages

#### `app/views/admin/listings/pending.html.erb`
**Priority Features:**
- Ordered oldest → newest (FIFO queue)
- Empty state when no pending listings
- Urgent badges for listings 3+ days old
- Red border for urgent items
- Quick actions: Examine, Validate, Reject
- Seller avatar and information
- Days pending indicator
- Direct validation/rejection from queue

#### `app/views/admin/listings/show.html.erb`
**Content:**
- Back link to pending queue
- Listing header with status badges
- Seller information card
- Statistics (views, favorites, reservations, abandons, completeness)
- Listing details (descriptions, metrics, location)
- Rejection comment display (if rejected)
- Validation action panel (if pending):
  - Quick validate button
  - Reject with comment form
  - Optional buyer attribution (collapsible)

### 5. Model Integration

**Existing `Listing` Model Features:**
- `validation_status` enum: pending, approved, rejected
- `attributed_buyer_id`: FK for exclusive deal attribution
- `validation_comment`: Stores rejection reason
- `validated_at`: Timestamp of validation
- `submitted_at`: Timestamp of submission

**Callbacks:**
```ruby
after_update :send_validation_notification, if: :saved_change_to_validation_status?
```

**Email Notifications:**
- Approval: `ListingNotificationMailer.listing_approved(listing)`
- Rejection: `ListingNotificationMailer.listing_rejected(listing)`

### 6. User Experience Flow

#### Seller Perspective:
1. Seller creates listing → status: `draft`
2. Seller submits for validation → status: `pending`, `submitted_at` recorded
3. **Admin validates:**
   - **Approved:** Seller receives email, listing published
   - **Rejected:** Seller receives email with comment (visible), can edit and resubmit
4. Validated listings show `validated_at` timestamp

#### Admin Perspective:
1. Navigate to `/admin/listings/pending`
2. See queue ordered by submission date
3. Urgent items (3+ days) highlighted
4. Click "Examiner" to view details
5. Review listing information
6. **Decision:**
   - **Validate:** Quick approve OR approve with buyer attribution
   - **Reject:** Provide comment explaining reason
7. Action logged, email sent automatically
8. Listing removed from pending queue

---

## Technical Details

### Database Fields Used

| Field | Type | Purpose |
|-------|------|---------|
| `validation_status` | enum | pending/approved/rejected |
| `validated_at` | datetime | When admin validated |
| `validation_comment` | text | Rejection reason (visible to seller) |
| `attributed_buyer_id` | integer | FK to BuyerProfile for sourcing |
| `submitted_at` | datetime | When seller submitted |

### Color Configuration (Tailwind)

**Admin Colors** (from `config/tailwind.config.js`):
```javascript
'admin': {
  50: '#FAF5FF',
  100: '#F3E8FF',
  200: '#E9D5FF',
  300: '#D8B4FE',
  400: '#C084FC',
  500: '#A855F7',
  600: '#9333EA',  // Primary admin color
  700: '#7E22CE',
  800: '#6B21A8',
  900: '#581C87',
}
```

### Authorization

**Admin Check:**
```ruby
def ensure_admin!
  unless current_user&.admin?
    redirect_to root_path, alert: "Accès non autorisé."
  end
end
```

---

## Testing Checklist

- [ ] Admin can access `/admin/listings/pending`
- [ ] Pending queue shows oldest listings first
- [ ] Urgent listings (3+ days) highlighted with red border
- [ ] Admin can examine listing details
- [ ] Admin can validate listing (quick action)
- [ ] Admin can reject with comment
- [ ] Rejection comment visible to seller
- [ ] Email sent on approval
- [ ] Email sent on rejection
- [ ] Listing auto-published on approval
- [ ] Attribution to buyer works (optional)
- [ ] Non-admin users cannot access admin routes
- [ ] Filters work on index page
- [ ] Search functionality works
- [ ] Statistics display correctly

---

## Future Enhancements

1. **Batch Operations:** Select multiple listings for bulk approve/reject
2. **Validation Templates:** Pre-defined rejection reason templates
3. **Auto-validation Rules:** Automatic approval for high-completeness listings
4. **Validation History:** Track who validated what and when
5. **Priority Scoring:** Automatically prioritize based on completeness + urgency
6. **Notifications:** In-app notifications for admins when new submissions arrive

---

## Related Files

**Controllers:**
- `app/controllers/admin/listings_controller.rb` - Main controller

**Views:**
- `app/views/admin/listings/index.html.erb` - All listings
- `app/views/admin/listings/pending.html.erb` - Validation queue
- `app/views/admin/listings/show.html.erb` - Listing details

**Helpers:**
- `app/helpers/admin/listings_helper.rb` - View helpers

**Models:**
- `app/models/listing.rb` - Existing model with validation logic

**Mailers:**
- `app/mailers/listing_notification_mailer.rb` - Email notifications

**Routes:**
- `config/routes.rb` - Admin listings routes

**Migrations:**
- `db/migrate/20251118145652_add_validation_fields_to_listings.rb` - Validation fields

---

## Notes

1. **Rejection Comments:** Per user request, rejection comments are visible to sellers so they know what to fix
2. **Queue Ordering:** Listings ordered chronologically (oldest first) to ensure fair processing
3. **Buyer Attribution:** Optional feature for sourcing - no automatic notifications per user request
4. **Email Notifications:** Handled automatically by model callbacks when `validation_status` changes
5. **Layout:** Uses `layout 'admin'` for consistent admin interface matching user management

---

## Conclusion

This implementation provides a complete manual validation workflow for listings, matching the specifications in Brick 1. The interface is intuitive, the workflow is efficient, and the code follows Rails best practices and the existing codebase patterns.

**Status:** ✅ Ready for testing and deployment
