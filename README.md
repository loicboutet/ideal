# Idéal Reprise - Business Acquisition Marketplace

A platform connecting business sellers (cédants), buyers (repreneurs), and service partners in the context of business succession ("papy boom").

## 🎯 Current Phase: Mockup Development - ALL 3 BRICKS

**Objective:** Create comprehensive mockups for all user journeys across all 3 bricks to validate UX/UI before full development.

## 📋 Project Status

- ✅ Project setup complete
- ✅ Documentation complete (specs, models, routes)
- ✅ Terminology updated (Acheteur → Repreneur)
- 🚧 **CURRENT TASK:** Mockup updates for all 3 bricks features
- ⏳ Full development (pending mockup validation)

## 📚 Documentation

All project documentation is located in the `/doc` directory:

### Core Documents

- **[`specifications.md`](doc/specifications.md)** - Complete functional specifications for all 3 bricks
  - User roles and permissions (Admin, Seller, Buyer/Repreneur, Partner)
  - Feature requirements for each brick
  - **NEW:** Messaging system (Brick 1)
  - **NEW:** Buyer public profiles & directory (Brick 1)
  - **NEW:** 10-stage CRM pipeline (Brick 1)
  - **NEW:** 3 deal types (Direct, Idéal Mandate, Partner Mandate)
  - **NEW:** 11 document categories (Brick 1)
  - **NEW:** Admin operations center (Brick 1)
  - Explicitly excluded features
  - Technical requirements

- **[`models.md`](doc/models.md)** - Database schema and relationships
  - 23 core models defined (3 new for messaging, 6 for new features)
  - **NEW:** Message, Conversation, ConversationParticipant
  - **NEW:** BuyerProfile with public/private data
  - **NEW:** Platform Settings, Questionnaires
  - **NEW:** Deal History, Partner Contacts, Listing Views
  - Attributes, validations, and relationships
  - Enums and constraints
  - **Note:** Models are for documentation only - no migrations created for mockups

- **[`routes.md`](doc/routes.md)** - Complete route structure (~110+ routes)
  - Organized by user type (admin, seller, buyer, partner)
  - RESTful architecture
  - View expectations for each route
  - All routes prefixed with `/mockups`

- **[`style_guide.md`](doc/style_guide.md)** - Design and UI guidelines
  - Visual reference: [Bonjour Cactus](https://www.bonjourcactus.com/)
  - Brand assets location: `app/assets/images/IDAL.jpg`
  - Design mockups: `style_guide/` directory
  - Tailwind CSS + Lucide Icons + Stimulus (minimal)

## 🎨 Mockup Development Guidelines

### Task Objective

**Create visual mockups for routes covering all 3 bricks functionality**

All mockups must:
- ✅ Load properly without errors
- ✅ Respect all documentation (specifications, models, routes, style guide)
- ✅ Use French language for all interface text ("Repreneur" not "Acheteur")
- ✅ Be responsive (mobile, tablet, desktop)
- ✅ Use Tailwind CSS for styling
- ✅ Use Lucide Icons for iconography
- ✅ Use Stimulus only when necessary for interactivity
- ✅ Use Turbo Streams for real-time features (messaging)

### Key Features Implemented

#### Brick 1 - Marketplace & Basic CRM

**User Profiles:**
- Admin: Operations center with alerts, analytics, messaging
- Seller (Cédant): Listings with public/confidential data, buyer directory access, push listings
- Buyer (Repreneur): Public/private profile, 10-stage CRM pipeline, enrichment validated by seller
- Partner: Directory profile with coverage area, intervention stages

**Core Features:**
- 🆕 **Messaging System:** Internal async messages with Turbo Streams real-time updates
- 🆕 **Buyer Directory:** Public profiles searchable by sellers
- 🆕 **3 Deal Types:** Direct, Idéal Mandate, Partner Mandate
- 🆕 **10-Stage CRM Pipeline:** With stage-specific timers
  - Favoris, À contacter (7j), Échange d'infos (33j), Analyse, Alignement projets
  - Négociation (20j), LOI (validation cédant), Audits, Financement, Deal signé
- 🆕 **11 Document Categories:** Structured document management
- 🆕 **Enrichment Workflow:** Buyer adds docs → Seller validates → Credits awarded
- 🆕 **Operations Center:** Admin dashboard with alerts and KPIs
- 🆕 **Platform Settings:** Configurable timers, pricing, texts
- Listing management with completeness scoring
- NDA (Accord de confidentialité) system
- Payment/subscription system (Stripe)
- Credit system (multi-role)
- Bulk import from Excel

#### Brick 2 - Advanced Features (mockups preview)
- Investor profile
- Scorecard system for sellers
- Real-time push notifications
- Weekly recap emails
- Advanced analytics

#### Brick 3 - Crowdfunding Integration (mockups preview)
- White-label iframe integration
- Investment tracking
- Campaign management

### Technical Requirements

**Controllers:**
- All mockup controllers inherit from `MockupsController`
- Namespaced by user type: `Mockups::AdminController`, `Mockups::SellerController`, etc.
- No authentication required for mockups
- No database operations (models/migrations)

**Routes:**
- All routes start with `/mockups`
- Follow RESTful conventions
- Match routes defined in `doc/routes.md`

**Views:**
- Use appropriate layouts (`mockup_admin.html.erb`, `mockup_user.html.erb`, etc.)
- Include realistic mock data
- Show proper states (loading, empty, error, success)
- Consistent navigation per user role
- French language throughout

**Layouts:**
- `mockup_admin.html.erb` - Admin interface layout
- `mockup_user.html.erb` - Seller/Buyer/Partner layout (deprecated, use specific ones)
- `mockup_seller.html.erb` - Seller layout
- `mockup_buyer.html.erb` - Buyer layout
- `mockup_partner.html.erb` - Partner layout
- `mockup.html.erb` - Public pages layout

### What NOT to Create

❌ **Do NOT create:**
- Database migrations
- Active Record models
- Real authentication logic
- API endpoints
- Background jobs
- Actual payment processing
- File uploads (use placeholders)

## 🚀 Deployment

### Automatic Deployment

- **Target:** https://ideal.5000.dev
- **Trigger:** Push to `main` branch
- **Platform:** Kamal deployment to 5000.dev infrastructure
- **Workflow:** `.github/workflows/deploy.yml`

Any push to the main branch automatically deploys to the staging subdomain where work can be reviewed.

## 🛠 Technology Stack

### Backend
- **Framework:** Ruby on Rails 8
- **Ruby Version:** 3.3.0
- **Database:** SQLite with Solid libraries (for production)
- **Authentication:** Devise (for production)

### Frontend
- **CSS:** Tailwind CSS
- **Icons:** Lucide Icons
- **JavaScript:** Stimulus (minimal usage)
- **Turbo:** Enabled by default (Turbo Streams for real-time messaging)

### Development
- **Layout:** Rails 8 conventions
- **Fonts:** Inter font family
- **Deployment:** Kamal 2.4.0

## 📁 Project Structure

```
doc/
├── specifications.md    # Functional specifications (ALL 3 BRICKS)
├── models.md           # Database schema (23 models)
├── routes.md           # Route definitions (110+ routes)
└── style_guide.md      # Design guidelines

style_guide/            # Design reference images

app/
├── controllers/
│   ├── mockups_controller.rb           # Base mockup controller
│   └── mockups/                        # Namespaced mockup controllers
│       ├── admin_controller.rb
│       ├── seller_controller.rb
│       ├── buyer_controller.rb
│       ├── partner_controller.rb
│       └── ... (+ nested controllers)
├── views/
│   ├── layouts/
│   │   ├── mockup.html.erb             # Public layout
│   │   ├── mockup_admin.html.erb       # Admin layout
│   │   ├── mockup_seller.html.erb      # Seller layout
│   │   ├── mockup_buyer.html.erb       # Buyer layout
│   │   └── mockup_partner.html.erb     # Partner layout
│   └── mockups/                        # All mockup views
│       ├── admin/                      # Admin views
│       ├── seller/                     # Seller views
│       ├── buyer/                      # Buyer views
│       ├── partner/                    # Partner views
│       └── ... (shared views)
└── assets/
    └── images/
        └── IDAL.jpg                    # Logo
```

## 🎨 Design Reference

- **Inspiration:** [Bonjour Cactus](https://www.bonjourcactus.com/)
- **Logo:** `app/assets/images/IDAL.jpg`
- **Mockup Screenshots:** `style_guide/` directory
- **Color Palette:** Professional, clean, modern (consistent per role)
- **Typography:** Inter font family

## 🌍 Internationalization

- **User Interface:** French (fr)
- **Terminology:** "Repreneur" (not "Acheteur"), "Accord de confidentialité" (not just "NDA")
- **Documentation:** English (en)
- **Currency:** EUR (€)
- **Date Format:** DD/MM/YYYY

## 📝 Development Notes

### Running the Application

```bash
# Install dependencies
bundle install

# Setup database (not needed for mockups)
bin/rails db:setup

# Start development server (user does this, not Gilfoyle)
bin/dev

# Restart server (if needed)
touch tmp/restart.txt
```

### Testing

```bash
# Run tests (with limited output)
bin/rails test --verbose

# Run specific test
bin/rails test test/controllers/mockups_controller_test.rb
```

### Code Style

- Follow Ruby Style Guide
- Use Rails conventions
- Keep methods small and focused
- Write self-documenting code
- Add comments for complex logic
- French for UI, English for code

## 🔐 Security Notes

Production will include:
- GDPR compliance
- Secure authentication (Devise)
- Payment security (Stripe PCI compliance)
- Data encryption
- Electronic NDA signatures ("Accords de confidentialité")
- Audit trail
- IP tracking for signatures
- Message history for legal proof

*Mockups do not implement security features.*

## 📞 Support

For questions about the specifications or mockup requirements, refer to:
1. This README
2. Documentation in `/doc`
3. Existing mockup examples in `app/views/mockups`
4. `MODIFICATIONS_TRACKING.md` for current progress

## 🎯 Success Criteria

Mockups are complete when:
- ✅ All routes load without errors
- ✅ Navigation works consistently across user types
- ✅ Design follows style guide
- ✅ Responsive on mobile/tablet/desktop
- ✅ French language throughout ("Repreneur" not "Acheteur")
- ✅ Realistic mock data displayed
- ✅ No broken links between pages
- ✅ All 3 bricks features represented visually
- ✅ Messaging system interface complete
- ✅ 10-stage CRM pipeline visualized
- ✅ Document categories properly structured

## 📊 Data Standards

### Industry Sectors (11 standard)
1. Industrie
2. BTP (Construction)
3. Commerce & Distribution
4. Transport & logistique
5. Hôtellerie / Restauration
6. Services
7. Agroalimentaire & Agriculture
8. Santé
9. Digital
10. Immobilier
11. Autre

### CRM Stages (10 statuses)
1. Favoris
2. À contacter (7 jours)
3. Échange d'infos (33 jours total pour 3-5)
4. Analyse
5. Alignement projets
6. Négociation (20 jours)
7. LOI (validation cédant requise)
8. Audits
9. Financement
10. Deal signé

### Deal Types (3 types)
1. Deal Direct (seller-initiated)
2. Mandat Idéal Reprise (platform sourcing)
3. Mandat Partenaire (broker-initiated)

### Document Categories (11 types)
1. Bilans N-1, N-2, N-3
2. Organigramme
3. Liasse fiscale
4. Compte de résultat
5. Liste véhicules et matériel lourd
6. Bail
7. Titre de propriété
8. Rapport Scorecard
9. Autre (à spécifier)

## 🚧 Current Modifications

See `MODIFICATIONS_TRACKING.md` for detailed progress tracking of all 127 modifications across:
- Documentation (specs, models, routes)
- General (terminology, colors)
- Admin pages (25 modifications)
- Seller pages (30 modifications)
- Buyer pages (45 modifications)
- Partner pages (8 modifications)
- Common routes (12 modifications)

**Status:** ✅ Documentation complete | 🚧 Mockups in progress

## 📄 License

Proprietary - Idéal Reprise Platform
© 2025 5000.dev

---

**Ready to review?** All mockups represent functionality from all 3 bricks. The platform is designed with independent bricks but mockups show the complete vision.

**Deployment:** Every push to main deploys to https://ideal.5000.dev for client review.

**Next Steps:** 
1. Client validates mockups
2. Full Brick 1 development begins
3. Bricks 2 & 3 optional based on client decision
