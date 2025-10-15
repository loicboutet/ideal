# Idéal Reprise - Business Acquisition Marketplace

A platform connecting business sellers (cédants), buyers (repreneurs), and service partners in the context of business succession ("papy boom").

## 🎯 Current Phase: Mockup Development

**Objective:** Create comprehensive mockups for all user journeys to validate UX/UI before full development.

## 📋 Project Status

- ✅ Project setup complete
- ✅ Documentation complete
- 🚧 **CURRENT TASK:** Mockup development for all routes
- ⏳ Brick 1 development (pending mockup validation)

## 📚 Documentation

All project documentation is located in the `/doc` directory:

### Core Documents

- **[`specifications.md`](doc/specifications.md)** - Complete functional specifications for all 3 bricks
  - User roles and permissions
  - Feature requirements
  - Explicitly excluded features
  - Technical requirements

- **[`models.md`](doc/models.md)** - Database schema and relationships
  - 15 core models defined
  - Attributes, validations, and relationships
  - Enums and constraints
  - **Note:** Models are for documentation only - no migrations created for mockups

- **[`routes.md`](doc/routes.md)** - Complete route structure (~110 routes)
  - Organized by user type (admin, seller, buyer, partner)
  - RESTful architecture
  - View expectations for each route
  - All routes prefixed with `/mockups`

- **[`style_guide.md`](doc/style_guide.md)** - Design and UI guidelines
  - Visual reference: [Bonjour Cactus](https://www.bonjourcactus.com/)
  - Brand assets location: `app/assets/images/IDAL.jpg`
  - Design mockups: `style_guide/` directory
  - Tailwind CSS + Lucide Icons + Stimulus

## 🎨 Mockup Development Guidelines

### Task Objective

**Create visual mockups for EVERY route defined in [`doc/routes.md`](doc/routes.md)**

All mockups must:
- ✅ Load properly without errors
- ✅ Respect all documentation (specifications, models, routes, style guide)
- ✅ Use French language for all interface text
- ✅ Be responsive (mobile, tablet, desktop)
- ✅ Use Tailwind CSS for styling
- ✅ Use Lucide Icons for iconography
- ✅ Use Stimulus only when necessary for interactivity

### Technical Requirements

**Controllers:**
- All mockup controllers must inherit from `MockupsController`
- Namespaced by user type: `Mockups::AdminController`, `Mockups::SellerController`, etc.
- No authentication required for mockups
- No database operations (models/migrations)

**Routes:**
- All routes must start with `/mockups`
- Follow RESTful conventions
- Match exactly the routes defined in `doc/routes.md`

**Views:**
- Use appropriate layouts (`mockup_admin.html.erb`, `mockup_user.html.erb`, etc.)
- Include realistic mock data
- Show proper states (loading, empty, error, success)
- Consistent navigation per user role

**Layouts:**
- `mockup_admin.html.erb` - Admin interface layout
- `mockup_user.html.erb` - Seller/Buyer/Partner layout
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

### Priority Routes

Start with these core routes (~30 routes):

**Public Pages:**
1. Landing page (`/mockups`)
2. Login (`/mockups/login`)
3. Registration pages (seller, buyer, partner)
4. Browse listings (`/mockups/listings`)
5. Pricing (`/mockups/pricing`)

**Admin:**
1. Dashboard (`/mockups/admin`)
2. Users list (`/mockups/admin/users`)
3. Pending listings (`/mockups/admin/listings/pending`)
4. Deals overview (`/mockups/admin/deals`)

**Seller:**
1. Dashboard (`/mockups/seller`)
2. My listings (`/mockups/seller/listings`)
3. Create listing (`/mockups/seller/listings/new`)
4. Listing detail (`/mockups/seller/listings/:id`)

**Buyer:**
1. Dashboard (`/mockups/buyer`)
2. Browse listings (`/mockups/buyer/listings`)
3. CRM Pipeline (`/mockups/buyer/pipeline`)
4. Listing detail (`/mockups/buyer/listings/:id`)
5. Subscription management (`/mockups/buyer/subscription`)

**Partner:**
1. Dashboard (`/mockups/partner`)
2. Profile edit (`/mockups/partner/profile/edit`)
3. Public directory profile (`/mockups/directory/:id`)

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
- **Database:** SQLite with Solid libraries
- **Authentication:** Devise (for production)

### Frontend
- **CSS:** Tailwind CSS
- **Icons:** Lucide Icons
- **JavaScript:** Stimulus (minimal usage)
- **Turbo:** Enabled by default

### Development
- **Layout:** Rails 8 conventions
- **Fonts:** Inter font family
- **Deployment:** Kamal 2.4.0

## 📁 Project Structure

```
doc/
├── specifications.md    # Functional specifications
├── models.md           # Database schema
├── routes.md           # Route definitions
└── style_guide.md      # Design guidelines

style_guide/            # Design reference images

app/
├── controllers/
│   ├── mockups_controller.rb           # Base mockup controller
│   └── mockups/                        # Namespaced mockup controllers
├── views/
│   ├── layouts/
│   │   ├── mockup.html.erb             # Public layout
│   │   ├── mockup_admin.html.erb       # Admin layout
│   │   └── mockup_user.html.erb        # User layout
│   └── mockups/                        # All mockup views
└── assets/
    └── images/
        └── IDAL.jpg                    # Logo
```

## 🎨 Design Reference

- **Inspiration:** [Bonjour Cactus](https://www.bonjourcactus.com/)
- **Logo:** `app/assets/images/IDAL.jpg`
- **Mockup Screenshots:** `style_guide/` directory
- **Color Palette:** Professional, clean, modern
- **Typography:** Inter font family

## 🌍 Internationalization

- **User Interface:** French (fr)
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

# Start development server (user does this, not you)
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

## 🔐 Security Notes

Production will include:
- GDPR compliance
- Secure authentication (Devise)
- Payment security (Stripe PCI compliance)
- Data encryption
- Electronic NDA signatures
- Audit trail

*Mockups do not implement security features.*

## 📞 Support

For questions about the specifications or mockup requirements, refer to:
1. This README
2. Documentation in `/doc`
3. Existing mockup examples in `app/views/mockups`

## 🎯 Success Criteria

Mockups are complete when:
- ✅ All routes in `routes.md` have corresponding views
- ✅ All views load without errors
- ✅ Navigation works consistently across user types
- ✅ Design follows style guide
- ✅ Responsive on mobile/tablet/desktop
- ✅ French language throughout
- ✅ Realistic mock data displayed
- ✅ No broken links between pages

## 📄 License

Proprietary - Idéal Reprise Platform
© 2025 5000.dev

---

**Ready to start?** Review the documentation in `/doc`, check the style guide references, and begin creating mockups following the route structure defined in `routes.md`.
