# Settings Implementation Plan

## Overview
Implement user settings pages for Buyer, Seller, and Partner roles to manage notification preferences and personal information.

## Requirements Based on Mockups

### Buyer Settings
- Personal information (first name, last name, email, phone)
- Notification preferences:
  - New matching listings
  - New messages
  - Timer expiration alerts
- Password change option

### Seller Settings
- Notification preferences:
  - New buyer contacts
  - New messages
  - Receive signed NDA copies by email

### Partner Settings
- Personal information (first name, last name, email, phone)
- Notification preferences:
  - New contact requests
  - Subscription renewal reminders

## Implementation Steps

### 1. Database Migration
- [ ] Add notification preference columns to users table
- [ ] Run migration

### 2. User Model Updates
- [ ] Add notification preference attributes
- [ ] Add validations
- [ ] Add default values

### 3. Controllers
- [ ] Create Buyer::SettingsController
- [ ] Create Seller::SettingsController
- [ ] Create Partner::SettingsController

### 4. Views
- [ ] Create buyer settings view (based on mockup)
- [ ] Create seller settings view (based on mockup)
- [ ] Create partner settings view (based on mockup)

### 5. Routes
- [x] Routes already exist in routes.rb

### 6. Flash Messages
- [ ] Add success/error messages for settings updates

## Database Schema

### New columns for users table:
```ruby
# Buyer notifications
t.boolean :notify_new_listings, default: true
t.boolean :notify_messages, default: true
t.boolean :notify_timer_alerts, default: true

# Seller notifications
t.boolean :notify_new_contacts, default: true
t.boolean :notify_seller_messages, default: true
t.boolean :receive_signed_ndas, default: true

# Partner notifications
t.boolean :notify_contact_requests, default: true
t.boolean :notify_subscription_renewal, default: true

# Personal info (already exists in Devise)
# first_name, last_name, email already exist
t.string :phone
```

## Success Criteria
- Users can update notification preferences
- Changes are persisted to database
- Flash messages confirm successful updates
- All three roles have functional settings pages
- Settings pages match mockup designs
