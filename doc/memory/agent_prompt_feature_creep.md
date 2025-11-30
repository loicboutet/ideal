# Agent Prompt: Feature Creep Auditor

## Context

The Idéal Reprise project has a **signed contract** for Brick 1 at €5000. During mockup development, the specifications (`doc/specifications.md`) expanded significantly beyond the original contract scope. This agent needs to compare the original contract against what was actually mocked up and implemented.

---

## 🤖 AGENT 5: Feature Creep Auditor

### Role
Compare the original contract (Brick 1) against mockups and specifications to identify all feature creep.

### Prompt

```
You are a Contract Compliance Auditor for the Idéal Reprise project. Your task is to compare the ORIGINAL CONTRACT (Brick 1) against the MOCKUPS and SPECIFICATIONS to identify feature creep - features that were added beyond what was contractually agreed.

## The Original Contract (Brick 1 - €5000)

This is the EXACT contract text that was signed:

### 🏗️ BRIQUE 1 - Marketplace & CRM de base (5000€)

#### 👤 Admin (Idéal Reprise)
- Je peux créer et gérer les comptes utilisateurs
- Je peux valider manuellement les annonces des cédants
- Je peux valider les fiches des partenaires
- Je peux importer en masse des leads existants (800+ contacts via Excel)
- Je peux affecter des deals en exclusivité à certains repreneurs
- Je peux consulter le dashboard avec métriques clés (trafic, inscrits, deals par statut, CA)

#### 👔 Cédant
- Je peux m'inscrire gratuitement
- Je peux créer une annonce (CA, effectifs, bénéfices, localisation, prix/fourchette)
- Je peux voir mes annonces en attente de validation
- Je peux signer un NDA avant de contacter des repreneurs (si option payante)
- Je peux accéder gratuitement aux 3-4 premiers contacts repreneurs
- Je peux payer pour contacter directement plus de repreneurs

#### 💼 Repreneur
- Je peux m'inscrire et voir toutes les annonces (mode freemium avec pop-up paiement)
- Je peux signer un NDA obligatoire avant d'accéder aux détails
- Je peux payer selon formule (89€, 199€ ou 249€/mois, ou 1200€/an club)
- Je peux réserver une annonce (système de timer : max 2 mois pour club, 10 jours pour autres)
- Je peux enrichir les annonces (ajouter bilans, infos) pour gagner des crédits
- Je peux gérer mon CRM avec statuts drag & drop : À contacter, En relation, En cours d'études, Négociations, Signé/Finalisé (5 STATUTS)
- Je peux mettre des annonces en favoris (même si réservées par d'autres)
- Je peux libérer une annonce qui retourne automatiquement au panier commun
- Je peux supprimer des deals de mon historique

#### 🤝 Partenaire (avocats, comptables, prestataires)
- Je peux m'inscrire avec validation manuelle de ma fiche
- Je peux créer ma fiche annuaire (présentation, lien Google Agenda)
- Je peux modifier mes informations
- Je peux payer mon abonnement annuaire

#### ⚙️ Fonctionnalités système Brique 1
- Authentification et gestion multi-profils (Admin, Cédant, Repreneur, Partenaire)
- Système de paiement intégré (Stripe)
- Gestion des abonnements et système de crédits
- CRUD annonces avec workflow de validation
- CRM avec interface drag & drop pour repreneurs
- Système de réservation avec timer automatique (2 mois club / 10 jours autres)
- Import Excel des leads existants avec affectation
- Système de scorecard/étoiles pour complétude des annonces
- NDA électronique à la signature (avant accès détails ou contact)
- Notifications email : nouveau deal, validation annonce, deal disponible en favori, annonce validée
- Interface web responsive (web app)

### ❌ Éléments explicitement EXCLUS de Brique 1:
- Application mobile native (uniquement web app responsive)
- Intégration de levée de fonds avec transaction
- **Messagerie interne entre utilisateurs** ← IMPORTANT: EXPLICITEMENT EXCLUE
- Système de visioconférence intégré
- Transaction financière pour investissement
- Gestion comptable avancée
- Intégration CRM externe
- Développement de la plateforme de crowdfunding
- Gestion de la conformité réglementaire

---

## Your Audit Task

### 1. Read the Mockups
Examine all mockup files in `app/views/mockups/` to identify what features were actually built visually.

### 2. Read the Specifications
Examine `doc/specifications.md` to see what was specified.

### 3. Compare Against Contract

For each feature in mockups/specs, determine:
- ✅ **IN CONTRACT** - Feature was explicitly contracted
- ⚠️ **EXPANDED** - Feature was contracted but expanded beyond scope
- ❌ **FEATURE CREEP** - Feature was NOT in contract (added)
- 🚫 **EXCLUDED BUT ADDED** - Feature was explicitly excluded but added anyway

### 4. Specific Things to Check

| Feature | Contract Says | Check In Mockups |
|---------|---------------|------------------|
| CRM Stages | 5 stages (À contacter, En relation, En cours d'études, Négociations, Signé/Finalisé) | How many stages in pipeline mockup? |
| Timer System | Simple: 2 months club, 10 days others | Is there complex per-stage timers? |
| Messaging | **EXPLICITLY EXCLUDED** | Is there a messaging system? |
| Buyer Profiles | Not mentioned | Is there buyer directory/profiles? |
| Document Categories | Not specified | Are there 11 document categories? |
| Deal Types | Not mentioned | Are there 3 deal types? |
| Operations Center | Basic dashboard with metrics | Is there complex 4-alert KPI system? |
| Enrichment Validation | Not specified who validates | Is there seller validation workflow? |
| Platform Settings | Not mentioned | Is there admin settings page? |
| Surveys/Questionnaires | Not mentioned | Are there survey features? |

### 5. Commands to Use

```bash
# Check CRM stages in pipeline mockup
grep -i "stage\|status\|favoris\|contact\|négociation" app/views/mockups/buyer/pipeline/index.html.erb

# Check if messaging exists in mockups
ls app/views/mockups/messages/
grep -r "message\|conversation" app/views/mockups/

# Check buyer profiles/directory
ls app/views/mockups/seller/buyers/
ls app/views/mockups/buyer/profile/

# Check document categories
grep -r "document\|bilan\|liasse" app/views/mockups/

# Check deal types
grep -r "Direct\|Mandat\|Partner" app/views/mockups/

# Check admin operations
cat app/views/mockups/admin/operations.html.erb

# Check admin settings
cat app/views/mockups/admin/settings.html.erb

# Check surveys
ls app/views/mockups/admin/surveys/ 2>/dev/null || echo "No surveys"
```

### 6. Output Format

Create `doc/FEATURE_CREEP_REPORT.md`:

```markdown
# Feature Creep Report - Idéal Reprise

## Executive Summary
- Features in contract: X
- Features delivered matching contract: X
- Features expanded beyond contract: X
- Features added (not in contract): X
- **Excluded features that were added: X** ← CRITICAL

## 🚫 CRITICAL: Excluded Features That Were Added

### 1. Internal Messaging System
- **Contract status:** EXPLICITLY EXCLUDED ("Messagerie interne entre utilisateurs")
- **Mockup status:** FULLY IMPLEMENTED
- **Evidence:** 
  - `app/views/mockups/messages/` exists
  - Messaging in all user layouts
  - Conversation system
- **Impact:** Major scope addition

## ❌ Features Added (Not in Contract)

### 2. [Feature Name]
- **Contract status:** Not mentioned
- **Mockup status:** Implemented
- **Evidence:** [files/grep output]
- **Impact:** [Low/Medium/High]

## ⚠️ Features Expanded Beyond Contract

### 3. CRM Pipeline
- **Contract:** 5 stages (À contacter, En relation, En cours d'études, Négociations, Signé/Finalisé)
- **Mockup:** 10+ stages with complex timers
- **Evidence:** [grep output]
- **Impact:** High - doubles CRM complexity

### 4. Timer System
- **Contract:** Simple (2 months club / 10 days others)
- **Mockup:** Complex per-stage timers (7j, 33j, 20j, validation pauses)
- **Evidence:** [grep output]
- **Impact:** High

## ✅ Features Matching Contract
- User authentication ✓
- Listing CRUD ✓
- [etc.]

## Summary Table

| Feature | Contract | Mockup | Status |
|---------|----------|--------|--------|
| Messaging | EXCLUDED | Yes | 🚫 VIOLATION |
| CRM Stages | 5 | 10 | ⚠️ EXPANDED |
| Buyer Directory | No | Yes | ❌ CREEP |
| ... | | | |

## Recommendations

1. **Discuss with client:** The messaging system was explicitly excluded but implemented
2. **Scope options:**
   - Option A: Remove messaging, reduce CRM to 5 stages = match contract
   - Option B: Client accepts expanded scope with additional cost
   - Option C: Deliver as-is, document as goodwill
```

## Important Notes

- The messaging system being EXPLICITLY EXCLUDED but implemented is the most critical finding
- The CRM expansion from 5 to 10 stages is significant scope creep
- Many "nice to have" features were added that weren't contracted
- This explains why development took longer than expected

DO NOT fix anything. Only produce the audit report.
```

---

## Key Contract Points to Remember

1. **CRM was 5 stages, not 10:**
   - À contacter
   - En relation
   - En cours d'études
   - Négociations
   - Signé/Finalisé

2. **Timer was simple:**
   - 2 months for club members
   - 10 days for others
   - NOT per-stage complex timers

3. **Messaging was EXCLUDED:**
   > "Messagerie interne entre utilisateurs" is listed under "Éléments explicitement exclus"

4. **These were NOT in contract:**
   - Buyer profiles/directory
   - 11 document categories
   - 3 deal types
   - Operations center with 4 KPIs
   - Platform settings admin
   - Surveys/questionnaires
   - Enrichment validation workflow
   - Push listings to buyers
