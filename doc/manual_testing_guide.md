# Guide de Test Manuel - Idéal Reprise

## Comment tester

1. Lancer l'application : `bin/dev`
2. Se connecter avec les comptes de test (mot de passe : `password123`)

### Comptes de test

| Rôle | Email | 
|------|-------|
| Admin | admin@ideal-reprise.fr |
| Cédant | seller@example.fr |
| Repreneur | buyer@example.fr |
| Partenaire | sophie@conseil-legal.fr |

---

## 🔴 ADMIN

### Dashboard Principal
| URL | Vérifier |
|-----|----------|
| `/admin` | Les métriques s'affichent (utilisateurs, annonces, revenus) |
| `/admin` | Le graphique de croissance apparaît |
| `/admin` | Les derniers utilisateurs et annonces s'affichent |

### Centre d'Opérations
| URL | Vérifier |
|-----|----------|
| `/admin/operations` | Compteur "Annonces 0 vues" correct |
| `/admin/operations` | Compteur "Validations en attente" correct |
| `/admin/operations` | Compteur "Timers expirés" correct |
| `/admin/operations` | Distribution des statuts CRM affichée |
| `/admin/dashboard/zero_views` | Liste des annonces sans vues |
| `/admin/dashboard/expired_timers` | Liste des deals avec timer expiré |

### Enrichissements
| URL | Vérifier |
|-----|----------|
| `/admin/enrichments` | Liste des enrichissements avec stats |
| `/admin/enrichments?status=pending` | Filtre "En attente" fonctionne |
| `/admin/enrichments?status=approved` | Filtre "Approuvés" fonctionne |
| `/admin/enrichments/:id` | Détails de l'enrichissement |
| `/admin/enrichments/:id/approve_form` | Formulaire d'approbation |
| `PATCH /admin/enrichments/:id/approve` | Approuver ajoute des crédits au repreneur |
| `PATCH /admin/enrichments/:id/reject` | Rejeter avec motif |

---

## 🟢 CÉDANT (Seller)

### Dashboard
| URL | Vérifier |
|-----|----------|
| `/seller` | Stats affichées (vues, intérêts, messages) |
| `/seller` | Nombre d'intérêts cette semaine correct |
| `/seller` | Compteur messages non lus correct |
| `/seller` | Liste des annonces avec analytics |

### Intérêts (Repreneurs intéressés)
| URL | Vérifier |
|-----|----------|
| `/seller/interests` | Liste des repreneurs qui ont mis en favori |
| `/seller/interests` | Stats : total, cette semaine, négociations actives |
| `/seller/interests/:id` | Profil du repreneur avec ses favoris sur mes annonces |
| `/seller/interests/:id` | Deals en cours avec ce repreneur |

### Push d'annonces
| URL | Vérifier |
|-----|----------|
| `/seller/push_listings` | Mon solde de crédits affiché |
| `/seller/push_listings` | Liste des repreneurs intéressés |
| `/seller/push_listings` | Mes annonces actives pour sélection |
| `POST /seller/push_listings` | Push réussi déduit les crédits |
| `POST /seller/push_listings` | Erreur si crédits insuffisants |
| `POST /seller/push_listings` | Erreur si aucun repreneur sélectionné |

---

## 🔵 REPRENEUR (Buyer)

### Dashboard
| URL | Vérifier |
|-----|----------|
| `/buyer` | Stats affichées (deals, réservations, favoris, crédits) |
| `/buyer` | Compteur messages non lus correct |
| `/buyer` | Nouveaux favoris (7 derniers jours) correct |
| `/buyer` | Timer le plus court affiché |
| `/buyer` | Deals expirant bientôt (< 24h) signalés |

### Pipeline CRM
| URL | Vérifier |
|-----|----------|
| `/buyer` | 10 étapes du pipeline affichées |
| `/buyer` | Compteurs par étape corrects |
| `/buyer` | Étapes dans l'ordre : Favoris → À contacter → Échange d'infos → Analyse → Alignement → Négociation → LOI → Audits → Financement → Signé |

### Abonnement
| URL | Vérifier |
|-----|----------|
| `/buyer` | Nom de l'abonnement affiché (Free/Starter/Standard/Premium) |
| `/buyer` | Date de fin d'abonnement affichée |
| `/buyer` | Max réservations affiché (3 ou "illimité" pour Premium) |

---

## 🟣 PARTENAIRE (Partner)

### Dashboard
| URL | Vérifier |
|-----|----------|
| `/partner` | Dashboard partenaire s'affiche |
| `/partner/profile` | Mon profil annuaire |

---

## ⚠️ Tests d'Autorisation

### Accès non autorisé (doit rediriger)
| Test | URL | Attendu |
|------|-----|---------|
| Cédant → Admin | `/admin` | Redirige vers `/` |
| Repreneur → Admin | `/admin` | Redirige vers `/` |
| Repreneur → Cédant | `/seller` | Redirige vers `/` |
| Cédant → Repreneur | `/buyer` | Redirige vers `/` |
| Non connecté → Admin | `/admin` | Redirige vers login |
| Non connecté → Cédant | `/seller` | Redirige vers login |
| Non connecté → Repreneur | `/buyer` | Redirige vers login |

---

## 📝 Checklist Rapide

### Admin
- [ ] Dashboard avec métriques
- [ ] Operations : compteurs d'alertes
- [ ] Enrichissements : liste, filtres, approbation, rejet

### Cédant
- [ ] Dashboard avec analytics
- [ ] Intérêts : liste des repreneurs intéressés
- [ ] Push : envoi d'annonces aux repreneurs

### Repreneur
- [ ] Dashboard avec stats et pipeline
- [ ] Messages non lus comptés
- [ ] Favoris récents comptés
- [ ] Timer le plus court affiché
- [ ] Info abonnement correcte

### Sécurité
- [ ] Chaque rôle ne peut accéder qu'à ses pages
- [ ] Utilisateurs non connectés redirigés vers login
