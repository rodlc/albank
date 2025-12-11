# AlBank Design System

## Vue d'ensemble

Design system cohérent et accessible pour AlBank, optimisé mobile-first avec une identité franco-française inspirée des services publics modernes.

## Principes de conception

### 1. Mobile First
- Toutes les interfaces sont conçues d'abord pour mobile
- Breakpoints progressifs : 576px, 768px, 992px, 1200px
- Typography responsive avec `clamp()`
- Taille tactile minimum : 44px (WCAG)

### 2. Accessibilité (WCAG AA)
- Contrastes de couleurs validés (ratio 4.5:1 minimum)
- Focus states visibles sur tous les éléments interactifs
- Labels `aria-label` en français
- Navigation clavier complète

### 3. Franco-Français
- Ton rassurant, pas d'anglicisme
- Formats : `1 234,56 €` (espace insécable, virgule)
- Messages d'erreur explicites en français
- Inspiration service public (DSFR, Mon-Entreprise)

---

## Palette de couleurs

### Couleurs primaires
```scss
$primary: #000091;          // Bleu France (Marianne)
$primary-light: #6a6af4;    // Bleu France clair
$primary-lighter: #e3e3fd;  // Fond bleu très pâle
$primary-hover: #1212ff;    // Hover accessible
```

### Couleurs d'action
```scss
$action: #0055ff;           // Bleu électrique CTA
$action-hover: #0044cc;     // Hover CTA
```

### Couleurs secondaires
```scss
$coral: #ff5e6c;            // Accent chaleureux
$coral-text: #c9191e;       // Texte rouge accessible
$cyan: #53c1de;             // Accent frais
$cyan-dark: #2891b8;        // Cyan foncé accessible
```

### Couleurs sémantiques
```scss
$success: #18753c;          // Vert forêt (ratio 4.5:1)
$danger: #ce0500;           // Rouge erreur (ratio 4.5:1)
$warning: #b34000;          // Orange accessible
$info: #0063cb;             // Bleu info accessible
```

### Palette neutre
```scss
$text-primary: #161616;     // Noir primaire
$text-secondary: #6e6e6e;   // Gris moyen
$text-muted: #929292;       // Gris clair
$body-bg: #f6f6f6;          // Fond page
$card-bg: #ffffff;          // Blanc pur
$border-color: #dddddd;     // Bordure standard
```

---

## Typographie

### Famille de police
```scss
font-family: "Inter", -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
```

### Échelle typographique
```scss
h1: clamp(1.75rem, 5vw, 2.5rem);   // 28px → 40px
h2: clamp(1.5rem, 4vw, 2rem);      // 24px → 32px
h3: clamp(1.25rem, 2.5vw, 1.75rem);// 20px → 28px
h4: 1.125rem;                       // 18px
body: 1rem;                         // 16px
small: 0.875rem;                    // 14px
```

### Letter spacing
```scss
body: -0.01em;                      // Resserrement léger
headings: -0.02em;                  // Resserrement modéré
```

---

## Composants

### Boutons

#### Boutons gouvernementaux (primaires)
```html
<button class="btn btn-gov-primary">
  <span aria-hidden="true">📊</span> Mes relevés
</button>

<button class="btn btn-gov-outline">
  Se connecter
</button>
```

**Caractéristiques :**
- Min-height: 44px
- Padding: 0.75rem 1.5rem
- Border-radius: 8px
- Font-weight: 600
- Pleine largeur sur mobile

#### Boutons d'action (CTA)
```html
<button class="btn btn-action">
  <span aria-hidden="true">📋</span> Copier la lettre
</button>
```

**Caractéristiques :**
- Min-height: 48px
- Background: #0055ff
- Shadow: 0 2px 8px rgba(0, 85, 255, 0.15)
- Effet lift au hover

#### Boutons secondaires
```html
<button class="btn btn-soft">Annuler</button>
<button class="btn btn-ghost">Fermer</button>
<button class="btn btn-icon">🔍</button>
```

### Cards

#### Card standard
```html
<div class="card shadow-soft">
  <div class="card-body">
    <h5 class="card-title">Titre</h5>
    <p class="card-text">Contenu...</p>
  </div>
</div>
```

**Styles :**
- Border: 1px solid #e8e8e8
- Border-radius: 12px
- Padding: 1.5rem
- Shadow: 0 1px 3px rgba(0, 0, 0, 0.06)

#### Card avec état sémantique
```html
<div class="card border-0 shadow-soft bg-success-light">
  <div class="card-body text-center">
    <div class="text-success small">💡 Économies possibles</div>
    <div class="fs-2 fw-bold text-success">124 €</div>
  </div>
</div>
```

### Accordéon

```html
<div class="accordion expenses-accordion">
  <div class="accordion-item accordion-danger">
    <h2 class="accordion-header">
      <button class="accordion-button" type="button" data-bs-toggle="collapse">
        <span class="section-emoji">⚠️</span>
        <span class="section-label">Fraudes détectées</span>
        <span class="section-count">(2)</span>
        <span class="section-totals">149 €</span>
      </button>
    </h2>
    <div class="accordion-collapse collapse show">
      <div class="accordion-body">
        <!-- Expense rows -->
      </div>
    </div>
  </div>
</div>
```

**Variants :**
- `.accordion-danger` → bordure gauche rouge
- `.accordion-primary` → bordure gauche bleue
- `.accordion-success` → bordure gauche verte

### Stepper

```html
<div class="opportunity-stepper">
  <div class="stepper-track"></div>
  <div class="stepper-progress" style="width: 50%;"></div>
  <div class="stepper-steps">
    <div class="stepper-step active">
      <div class="stepper-circle bg-primary text-white">🕵️</div>
      <span class="stepper-label">Détectée</span>
    </div>
    <!-- More steps -->
  </div>
</div>
```

### Flash Messages

```html
<div class="alert alert-success alert-dismissible fade show shadow-soft">
  <div class="d-flex align-items-start gap-2">
    <span class="flex-shrink-0" aria-hidden="true">✅</span>
    <div class="flex-grow-1">Statut mis à jour avec succès.</div>
    <button type="button" class="btn-close" data-bs-dismiss="alert" 
            aria-label="Fermer le message"></button>
  </div>
</div>
```

---

## Utilitaires

### Spacing
```scss
.mb-3  // margin-bottom: 1rem (16px)
.mb-4  // margin-bottom: 1.5rem (24px)
.mb-5  // margin-bottom: 3rem (48px)
.gap-3 // gap: 1rem
```

### Shadows
```scss
.shadow-soft  // 0 1px 3px rgba(0, 0, 0, 0.06)
.shadow-card  // 0 4px 8px rgba(0, 0, 0, 0.08)
```

### Text utilities
```scss
.text-coral       // Couleur coral accessible
.text-cyan        // Couleur cyan accessible
.underline-cyan   // Soulignement cyan (Mon-Entreprise style)
.letter-spacing-tight // -0.02em
```

### Background utilities
```scss
.bg-danger-light   // #fff5f5
.bg-success-light  // #e8ffed
.bg-info-light     // #f0f6ff
.bg-coral-light    // #ffe5e7
.bg-cyan-light     // #e0f7ff
```

---

## Layouts responsifs

### Grille mobile-first
```html
<!-- Stack sur mobile, côte à côte sur desktop -->
<div class="row g-3">
  <div class="col-12 col-md-6">Card 1</div>
  <div class="col-12 col-md-6">Card 2</div>
</div>
```

### Groupe de boutons responsive
```html
<div class="btn-group-mobile">
  <button class="btn btn-action">Action principale</button>
  <button class="btn btn-gov-outline">Action secondaire</button>
</div>
```

### Container
```scss
.container        // max-width: 1140px (xl)
padding: 0 1rem; // Mobile
padding: 0;      // Desktop (container géré par Bootstrap)
```

---

## Bonnes pratiques

### Accessibilité
```html
<!-- ✅ Bon -->
<button class="btn btn-primary" aria-label="Supprimer l'élément">
  <span aria-hidden="true">🗑️</span> Supprimer
</button>

<!-- ❌ Mauvais -->
<button class="btn btn-primary">
  🗑️
</button>
```

### Icônes
- Toujours utiliser `aria-hidden="true"` sur les émojis décoratifs
- Accompagner d'un texte ou d'un `aria-label`
- Éviter les icônes seules sans contexte

### Formats monétaires
```erb
<!-- Format français : espace insécable + virgule -->
<%= number_to_currency(amount, unit: "€", precision: 2, separator: ",", delimiter: " ") %>
<!-- Résultat : 1 234,56 € -->
```

### Wording
```
✅ "Statut mis à jour avec succès"
✅ "Économies potentielles"
✅ "Mes relevés"

❌ "Opportunity status updated successfully"
❌ "Potential savings"
❌ "My statements"
```

---

## Ressources

- **Palette de couleurs** : `app/assets/stylesheets/config/_colors.scss`
- **Variables Bootstrap** : `app/assets/stylesheets/config/_bootstrap_variables.scss`
- **Typographie** : `app/assets/stylesheets/config/_fonts.scss`
- **Composants** : `app/assets/stylesheets/components/`

## Inspiration

- [Système de Design de l'État (DSFR)](https://www.systeme-de-design.gouv.fr/)
- [Mon-Entreprise](https://mon-entreprise.urssaf.fr/)
- [Service-Public.fr](https://www.service-public.fr/)

---

**Version** : 1.0.0  
**Dernière mise à jour** : Décembre 2024