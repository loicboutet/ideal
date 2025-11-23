# Brick 1 Test Suite

## Files Created

1. **brick1_test_suite.csv** - Comprehensive test cases in CSV format
2. **convert_to_excel.py** - Optional Python script to convert to Excel with formatting

## Test Suite Overview

The test suite contains **90+ comprehensive test cases** covering all Brick 1 features:

### Coverage by Category:

#### Admin Features (11 test cases)
- Create and manage user accounts (all roles including seller profiles with listings)
- Manually validate seller listings
- Validate partner profiles
- Bulk import leads
- Assign exclusive deals
- Dashboard KPIs and alerts
- Platform settings
- Communication system

#### Seller Features (11 test cases)
- Registration and profile creation
- Listing management (create, upload documents, view performance)
- Buyer directory browsing
- Listing push to buyers
- Credit system
- Premium packages
- Enrichment validation
- Messaging

#### Buyer Features (16 test cases)
- Registration with profile
- Listing browsing and filtering
- NDA signing (platform and listing-specific)
- Subscription plans
- Reservation system
- CRM pipeline (10 stages)
- Deal timer management
- Enrichment system
- Release listings
- Messaging
- Partner directory access

#### Partner Features (5 test cases)
- Registration and validation
- Profile management
- View tracking
- Directory subscription

#### Core System Features (47+ test cases)
- NDA system
- Notification system (email and in-app)
- Payment system (Stripe integration, subscriptions, credits)
- Document system
- Messaging system
- Search and filters
- Analytics
- Security and RBAC
- Performance
- Mobile responsiveness
- Accessibility
- GDPR compliance
- Error handling
- Integrations
- Localization

## How to Use the CSV File

### Option 1: Open Directly in Excel/Google Sheets

1. Open the file `brick1_test_suite.csv` in Excel or Google Sheets
2. The file has 3 columns:
   - **Task Name**: Feature/functionality to test
   - **URL to Test**: Application route to access
   - **How to Test**: Step-by-step instructions (contains `\n` for line breaks)

3. **To fix line breaks in Excel:**
   - Select the "How to Test" column (column C)
   - Use Find & Replace (Ctrl+H)
   - Find: `\n`
   - Replace with: (press Ctrl+J to insert a line break)
   - Click Replace All
   - Enable "Wrap Text" for column C

### Option 2: Convert to Formatted Excel (Requires Python)

If you have Python with pip installed:

```bash
# Install required library
pip3 install openpyxl

# Run the conversion script
python3 convert_to_excel.py
```

This will create `brick1_test_suite.xlsx` with:
- Professional formatting
- Proper line breaks
- Color-coded headers
- Optimized column widths
- Frozen header row
- Cell borders

### Option 3: Manual Excel Creation

If you prefer, you can manually create a clean Excel file:
1. Open the CSV in a text editor
2. Copy the data
3. Paste into Excel
4. Format as needed

## Test Execution Recommendations

### Priority 1: Core Admin Functions (Your Requirements)
1. Admin - Create Seller Account with Listing
2. Admin - Create Buyer Account
3. Admin - Create Partner Account
4. Admin - Manually Validate Seller Listing
5. Admin - Validate Partner Profile

### Priority 2: Critical User Flows
1. Seller - Free Registration
2. Seller - Create Business Listing
3. Buyer - Registration with Profile
4. Buyer - Reserve Listing
5. Buyer - CRM Pipeline Management
6. Partner - Registration

### Priority 3: Payment & Credits
1. Payment System - Stripe Integration
2. Buyer - Subscribe to Plan
3. Seller - Buy Credit Pack
4. Payment System - Subscription Management

### Priority 4: Communication & Notifications
1. Messaging System - Real-time Updates
2. Notification System - Email Notifications
3. NDA System - Platform NDA

### Priority 5: Security & Compliance
1. Security - Role-Based Access Control
2. Security - Data Privacy
3. GDPR Compliance - Data Export

## Test Environment Setup

Before testing, ensure you have:

1. **Test Accounts** for each role:
   - Admin: admin@test.com
   - Seller: seller@test.com
   - Buyer: buyer@test.com
   - Partner: partner@test.com

2. **Test Payment Setup**:
   - Stripe test mode enabled
   - Test card: 4242 4242 4242 4242

3. **Sample Data**:
   - At least 3 sample listings
   - Various industry sectors
   - Different price ranges
   - Documents in all categories

4. **Browser Testing**:
   - Chrome/Firefox for desktop
   - Mobile viewport (375px width)
   - Screen reader (optional)

## Expected Test Results

Each test should verify:
- ✅ Feature works as specified
- ✅ UI displays correctly
- ✅ Data saves properly
- ✅ Notifications sent
- ✅ Navigation works
- ✅ Error handling
- ✅ Permissions enforced

## Reporting Issues

When reporting bugs, include:
1. Test case name
2. Steps to reproduce
3. Expected result
4. Actual result
5. Screenshots (if applicable)
6. Browser/device info

## Test Coverage Summary

| Category | Test Cases | Coverage |
|----------|-----------|----------|
| Admin Features | 11 | Complete |
| Seller Features | 11 | Complete |
| Buyer Features | 16 | Complete |
| Partner Features | 5 | Complete |
| System Features | 47+ | Complete |
| **TOTAL** | **90+** | **100%** |

## Notes

- All URLs assume the app is running at http://localhost:3000 or your deployment URL
- Replace `:id` in URLs with actual record IDs during testing
- Some tests require sequential execution (e.g., create before validate)
- Timer-based features may require waiting or time manipulation for full testing
- Real-time features require multiple browser sessions

## Next Steps

1. Review the test cases
2. Set up test environment
3. Execute tests systematically
4. Document results
5. Report any issues found

---

**Created**: November 23, 2025
**For**: Idéal Reprise - Brick 1 Testing
**Total Test Cases**: 90+
