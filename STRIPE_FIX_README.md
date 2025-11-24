# Stripe API Key Fix - Deployment Guide

## Problem Fixed
Subscription checkout was failing with error: "You did not provide an API key"

## Solution
- Added client's Stripe keys to Rails encrypted credentials (secure)
- Updated deployment config to use credentials instead of environment variables
- Credentials are decrypted automatically using RAILS_MASTER_KEY

## What Changed
- `config/credentials.yml.enc` - Contains Stripe keys (encrypted, safe in git)
- `config/deploy.yml` - Removed Stripe secret env vars
- `.kamal/secrets` - Removed Stripe env var references

## For Deployment

### Important Notes
1. The Rails master key is stored separately (not in git)
2. Contact the developer for the RAILS_MASTER_KEY value
3. This key must be set before deployment

### Deployment Steps

```bash
# 1. Pull latest code
git checkout main
git pull origin main

# 2. Set master key (get value from developer)
export RAILS_MASTER_KEY=<ask_developer_for_key>

# 3. Deploy
bin/kamal deploy

# 4. Verify
bin/kamal app logs | grep -i stripe
# Should see: "Stripe initialized with publishable key: pk_test_..."

# 5. Test
# Visit: https://ideal.5000.dev/buyer/subscription/new
# The checkout error should be fixed
```

## Security
✅ Safe in Git: `config/credentials.yml.enc` (encrypted)  
❌ Never commit: `config/master.key` (already in .gitignore)

## What Happens
1. Kamal reads RAILS_MASTER_KEY from environment
2. Rails decrypts credentials.yml.enc
3. Stripe initializer loads keys from decrypted credentials  
4. Checkout works properly....

## Note
Webhook secret not included yet (not blocking for basic checkout).
Can be added later for full subscription webhook handling.
