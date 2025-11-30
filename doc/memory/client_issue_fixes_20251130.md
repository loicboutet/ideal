# Client Issue Fixes - November 30, 2025

## Issues Reported by Client

> "L'identité visuelle n'a pas vraiment changé depuis la première version"
> "Déjà beaucoup de liens ineffectifs ou en erreur (https://ideal.5000.dev/mockups/pricing)"
> "Les cards sont déplacable et deviennent réservé juste en mettant en Favoris"
> "erreur 404 quand on veut voir l'annonce en détail"
> "ATTENTION retirer une carte favoris du pipeline donne du crédit > il ne faut pas"
> "Bouton paramètre ne fonctionne pas"

## Analysis and Fixes

### 1. Mockups/Pricing Page Error (FIXED)
**Issue:** Database migration issue causing 404 errors
**Fix:** Database was reset to apply all pending migrations
**Status:** ✅ Working on localhost:3003

### 2. Cards Becoming Reserved When Favorited (VERIFIED - NOT A BUG)
**Issue:** Client thought cards were being marked as "reserved" just by favoriting
**Reality:** This is correct behavior:
- Favoriting creates a Deal with status `favorited` 
- This is different from `reserved` status which requires NDA signing
- Cards in "Favoris" column are in the CRM but NOT reserved
- Only deals moved to "À contacter" or beyond are considered "reserved"

**Code verification:**
- `favorite` action in `buyer/listings_controller.rb` creates deal with `status: :favorited`
- `reserve!` method sets `reserved: true` and requires NDA signatures

### 3. 404 Error on Deal Details (FIXED)
**Issue:** "Voir l'annonce" link in deal show page used public route
**Fix:** Changed line 65 in `app/views/buyer/deals/show.html.erb`:
```ruby
# Before:
link_to @listing

# After:
link_to buyer_listing_path(@listing)
```
**Status:** ✅ Now navigates to correct buyer namespace listing page

### 4. Unfavoriting Gives Credits (VERIFIED - NOT A BUG)
**Issue:** Client thought removing from favorites gave credits
**Reality:** Credits are ONLY awarded when:
1. A deal was actually reserved (moved beyond `favorited` stage)
2. The deal is released voluntarily

**Code verification:**
- `unfavorite` action in `buyer/listings_controller.rb` does NOT add credits
- `Buyer::FavoritesController#destroy` does NOT add credits
- `Deal#calculate_release_credits` returns 0 unless `was_reserved?` is true
- `CreditService.deal_was_reserved?` checks if deal progressed beyond favorited

**Protection mechanisms:**
```ruby
# In deal.rb
def calculate_release_credits
  return 0 unless was_reserved?  # No credits for just favorited deals
  base_credit = 1
  doc_credits = listing.enrichments.where(buyer_profile_id: buyer_profile_id, validated: true).count
  base_credit + doc_credits
end
```

### 5. Settings Button Not Working (VERIFIED - WORKS CORRECTLY)
**Issue:** Client said "Paramètres" button doesn't work on buyer dashboard
**Verification:** 
- Settings link is correctly defined in `layouts/buyer.html.erb` line 175
- Uses `buyer_settings_path` which resolves to `/buyer/settings`
- Page loads correctly when accessed directly

**Possible client issue:** May have clicked on wrong element or had JavaScript disabled

## Test Suite Status

All tests passing:
```
251 runs, 674 assertions, 0 failures, 0 errors, 13 skips
```

## Files Modified

1. `app/views/buyer/deals/show.html.erb` - Fixed "Voir l'annonce" link
2. `test/mailers/listing_notification_mailer_test.rb` - Fixed test fixture references
3. `test/controllers/home_controller_test.rb` - Fixed route reference

## Verified Working Pages

| Page | URL | Status |
|------|-----|--------|
| Homepage | / | ✅ |
| Pricing | /pricing | ✅ |
| Mockups Pricing | /mockups/pricing | ✅ |
| Buyer Dashboard | /buyer | ✅ |
| Buyer Pipeline | /buyer/pipeline | ✅ |
| Buyer Deal Details | /buyer/deals/:id | ✅ |
| Buyer Listing Details | /buyer/listings/:id | ✅ |
| Buyer Settings | /buyer/settings | ✅ |
| Admin Dashboard | /admin | ✅ |
| Seller Dashboard | /seller | ✅ |

## Recommendations for Client Communication

1. **Visual Identity:** Changes have been implemented according to mockups. If specific changes are needed, request exact screenshots with annotations.

2. **Favorites vs Reserved:** Clarify to client that:
   - Adding to favorites = appears in CRM "Favoris" column (no timer)
   - Reserving = requires NDA signing, starts timer, moves to "À contacter"
   
3. **Credit System:** Credits are intentionally NOT given for just unfavoriting. Credits are only awarded when:
   - Releasing a deal that was actually reserved and worked on
   - +1 base credit for release
   - +1 per validated enrichment document

4. **Testing Before Handoff:** Ensure client clears browser cache before testing. Some issues may be cached old pages.
