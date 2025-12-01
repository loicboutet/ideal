# UI Theme System Documentation

**Date:** 2025-11-30
**Status:** Implemented

## Summary

Implemented a profile-specific UI theme system based on client specifications. Each user role (Buyer/Repreneur, Seller/Cédant, Partner/Partenaire, Admin) now has its own color scheme applied to the sidebar and top bar.

## Design Specifications

### General Effects (All Profiles)
- **Card hover effect:** Slight zoom/bump (`transform: scale(1.02)`)
- **Sidebar shadow:** 60% transparency
- **Top bar shadow:** 20% transparency
- **White cards shadow:** 60% transparency
- **White cards border:** `#d0d0d0` with 2px width

### Button Gradients
| Button Type | Gradient Start | Gradient End | Use Case |
|-------------|---------------|--------------|----------|
| Primary | `#5d99c7` | `#7ccbd7` | "Voir Annonce", "Connexion" |
| Premium | `#ffde59` | `#ff914d` | Premium/upgrade buttons |
| Partner | `#c5ffe3` | `#19a460` | Partner-specific actions |

### Profile Color Schemes

#### Buyer (Repreneur) - Orange/Gold Theme
| Element | Value |
|---------|-------|
| Top bar gradient | `rgba(255, 158, 87, 0.1)` → `#ffffff` |
| Top bar border | `#ffde59` → `#ff914d` |
| Sidebar border | `#ff9e57` → `#ffffff` (10px, center to edge) |
| Menu hover | `rgba(255, 222, 89, 0.7)` → `rgba(255, 145, 77, 0.8)` |

#### Seller (Cédant) - Blue Theme
| Element | Value |
|---------|-------|
| Top bar gradient | `rgba(93, 177, 230, 0.1)` → `#ffffff` |
| Top bar border | `#5d99c7` → `#7ccbd7` |
| Sidebar border | `#5db1e6` → `#ffffff` (10px, center to edge) |
| Menu hover | `rgba(95, 137, 199, 0.7)` → `rgba(124, 203, 215, 0.8)` |

#### Partner (Partenaire) - Green Theme
| Element | Value |
|---------|-------|
| Top bar gradient | `rgba(152, 213, 180, 0.1)` → `#ffffff` |
| Top bar border | `#29ad6d` → `#5ccd96` |
| Sidebar border | `#29ad6d` → `#ffffff` (10px, center to edge) |
| Menu hover | `rgba(41, 173, 109, 0.7)` → `rgba(41, 173, 109, 0.8)` |

#### Admin - Dark/Gray Theme
| Element | Value |
|---------|-------|
| Top bar gradient | `rgba(31, 41, 55, 0.1)` → `#ffffff` |
| Top bar border | `#1f2937` → `#4b5563` |
| Sidebar border | `#374151` → `#ffffff` (10px, center to edge) |
| Menu hover | `rgba(55, 65, 81, 0.7)` → `rgba(75, 85, 99, 0.8)` |

## Implementation

### CSS Variables

All theme colors are defined as CSS custom properties in `:root` in `application.tailwind.css`:

```css
/* Buyer theme example */
--buyer-topbar-start: rgba(255, 158, 87, 0.1);
--buyer-topbar-end: #ffffff;
--buyer-border-start: #ffde59;
--buyer-border-end: #ff914d;
--buyer-sidebar-start: #ff9e57;
--buyer-sidebar-end: #ffffff;
--buyer-hover-start: rgba(255, 222, 89, 0.7);
--buyer-hover-end: rgba(255, 145, 77, 0.8);
```

### Layout Classes

Each profile uses a layout class on the `<html>` element:

```erb
<!-- buyer.html.erb -->
<html lang="fr" class="layout-buyer">

<!-- seller.html.erb -->
<html lang="fr" class="layout-seller">

<!-- partner.html.erb -->
<html lang="fr" class="layout-partner">

<!-- admin.html.erb -->
<html lang="fr" class="layout-admin">
```

### HTML Structure

Layouts use these semantic classes for styling:

```html
<!-- Sidebar -->
<aside class="sidebar-main ...">
  <a class="menu-link ...">Menu Item</a>
</aside>

<!-- Top bar -->
<header class="header-top-bar ...">
```

### CSS Selectors

The theming is applied via descendant selectors:

```css
.layout-buyer .header-top-bar {
  background: linear-gradient(180deg, var(--buyer-topbar-start), var(--buyer-topbar-end));
  /* ... */
}

.layout-buyer .sidebar-main {
  border-right: 10px solid;
  border-image: linear-gradient(180deg, var(--buyer-sidebar-start) 0%, var(--buyer-sidebar-end) 100%) 1;
  /* ... */
}

.layout-buyer .menu-link:hover {
  background: linear-gradient(90deg, var(--buyer-hover-start), var(--buyer-hover-end));
}
```

## Files Modified

### Stylesheets
- `app/assets/stylesheets/application.tailwind.css` - Added theme CSS variables and profile-specific styles

### Layouts
- `app/views/layouts/buyer.html.erb` - Added `layout-buyer` class, `sidebar-main`, `menu-link`, `header-top-bar`
- `app/views/layouts/seller.html.erb` - Added `layout-seller` class, updated structure
- `app/views/layouts/partner.html.erb` - Added `layout-partner` class, updated structure
- `app/views/layouts/admin.html.erb` - Added `layout-admin` class, updated structure

## Button Classes

New gradient button classes available:

```erb
<%= link_to "Voir l'annonce", ..., class: "btn-gradient-primary" %>
<%= link_to "Premium", ..., class: "btn-gradient-premium" %>
<%= link_to "Partenaire", ..., class: "btn-gradient-partner" %>
```

## Card Classes

For white cards with proper styling:

```erb
<div class="card-ideal">
  <!-- Card content with 2px border, shadow, hover zoom -->
</div>

<div class="deal-card">
  <!-- Deal card with same styling -->
</div>
```

## Usage Notes

1. **Adding a new theme:** Create new CSS variables with the `--newprofile-*` prefix, then add corresponding `.layout-newprofile` rules.

2. **Customizing buttons:** The gradient buttons use CSS variables for easy customization.

3. **Hover effects:** All cards and menu items have subtle hover effects for better UX.

4. **Shadow values:** The 60%/20% transparency shadows are defined as CSS variables and can be adjusted globally.
