# Style Guide - Idéal Reprise

## Design Reference

The design should be inspired by **[Bonjour Cactus](https://www.bonjourcactus.com/)** style:
- Clean and modern aesthetic
- Professional yet approachable
- Clear typography
- Good use of whitespace
- Intuitive navigation

## Brand Assets

### Logo
- Located in: `app/assets/images/ideal.png`
- Use consistently across all pages
- Maintain proper spacing around logo

### Additional Design References
- Design mockups available in: `style_guide/` directory
- Reference these images for visual direction and UI patterns

## Color Palette

Based on Bonjour Cactus inspiration, use:
- **Primary colors:** Professional blues/teals
- **Accent colors:** Warm highlights for CTAs
- **Neutral colors:** Grays for text and backgrounds
- **Success/Error states:** Green for success, Red for errors/warnings

*Note: Exact color codes to be extracted from reference site and mockups*

## Typography

### Font Stack
- Use Inter font family (already included in Rails 8)
- Fallback to system fonts for performance

### Hierarchy
- **Headings:** Clear size progression (h1-h6)
- **Body text:** Readable size (16px base)
- **Small text:** 14px for secondary info
- **Font weights:** Regular (400), Medium (500), Bold (700)

## Layout

### Grid System
- Use Tailwind CSS utility classes
- Responsive breakpoints:
  - Mobile: < 640px
  - Tablet: 640px - 1024px
  - Desktop: > 1024px

### Spacing
- Consistent padding and margins using Tailwind scale
- More whitespace for clarity
- Proper section separation

### Container Widths
- Max-width for content readability
- Full-width for headers/footers
- Centered layouts for forms

## Components

### Buttons
- **Primary:** Main actions (submit, confirm)
- **Secondary:** Secondary actions (cancel, back)
- **Tertiary:** Subtle actions (links, text buttons)
- Clear hover and active states
- Proper padding and sizing

### Forms
- Clear labels above inputs
- Helpful placeholder text
- Validation messages below fields
- Error states in red
- Success states in green
- Required field indicators

### Cards
- Subtle shadows for depth
- Rounded corners
- Proper padding
- Clear hierarchy of information
- Hover effects where interactive

### Navigation
- Clear active states
- Mobile-friendly hamburger menu
- Breadcrumbs for deep navigation
- Sticky header option

### Tables
- Clean, readable rows
- Alternating row colors for readability
- Sortable columns where appropriate
- Responsive design (stack on mobile)

## Icons

### Icon Library
- Use **Lucide Icons** (https://lucide.dev/)
- Consistent icon size across similar contexts
- Icons paired with text for clarity
- Proper spacing between icon and text

### Common Icons Usage
- **User:** Profile, account
- **Building:** Company, business
- **FileText:** Documents, listings
- **Star:** Favorites, ratings
- **Check:** Completed, validated
- **Clock:** Pending, timers
- **TrendingUp:** Analytics, growth

## Interactions

### Animations
- Subtle transitions (200-300ms)
- Smooth state changes
- Loading indicators for async actions
- No excessive or distracting animations

### Feedback
- Toast notifications for success/error
- Inline validation
- Loading states for buttons
- Disabled states clearly indicated

## Responsive Design

### Mobile First
- Design for mobile screens first
- Progressive enhancement for larger screens
- Touch-friendly tap targets (min 44x44px)
- Simplified navigation on mobile

### Breakpoints Strategy
- Stack elements vertically on mobile
- Side-by-side layouts on tablet+
- Full dashboard layouts on desktop
- Collapsible sidebars

## Accessibility

### Standards
- WCAG 2.1 Level AA compliance
- Proper color contrast ratios
- Keyboard navigation support
- Screen reader friendly markup

### Best Practices
- Semantic HTML5
- Alt text for images
- ARIA labels where needed
- Focus indicators visible
- No reliance on color alone

## Content Style

### Language
- **Interface:** French
- Clear and concise copy
- Professional tone
- Action-oriented button text

### Formatting
- Consistent date formats
- Currency in EUR (€)
- Number formatting (spaces for thousands)
- Clear labels and descriptions

## Implementation Notes

### Technology Stack
- **CSS Framework:** Tailwind CSS
- **JavaScript:** Stimulus (when needed)
- **Icons:** Lucide Icons
- **Fonts:** Inter (via Tailwind)

### File Organization
- Reusable partials for common components
- Consistent naming conventions
- Comments for complex layouts
- DRY principles

### Performance
- Optimize images
- Minimize CSS/JS
- Lazy load where appropriate
- Fast page transitions with Turbo

---

## Quick Reference Checklist

When creating a new view, ensure:
- [ ] Responsive on all breakpoints
- [ ] Uses brand colors consistently
- [ ] Includes proper spacing
- [ ] Icons from Lucide
- [ ] French language
- [ ] Accessible markup
- [ ] Loading states
- [ ] Error handling
- [ ] Mobile-friendly touch targets
- [ ] Clear call-to-actions

---

**Remember:** Consistency is key. Reference existing mockups and the Bonjour Cactus site for visual guidance.
