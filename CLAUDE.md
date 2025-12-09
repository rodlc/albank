# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**AlBank** helps low-income users (retirees, social welfare recipients, students) analyze their bank statements to detect fraud, abusive direct debits, and anomalies in recurring charges to regain financial control.

**Context**: launch in the context of a 2-week MVP sprint at Le Wagon bootcamp finale. Team of 3, 1 experienced ex-PM, 2 more junior.

## Commands

```bash
bin/rails server                           # Dev server
bin/rails db:create db:migrate db:seed     # Setup database
bin/rails test                             # All tests
bin/rails test test/models/user_test.rb    # Single file
bin/rails test test/models/user_test.rb:10 # Single test (by line)
rubocop -a                                 # Lint + auto-fix
bin/rails console                          # Rails console
```

## Domain Model

```
User -> Statement -> Expense -> Opportunity
                        |           |
                     Category <- Standard
```

| Model | Purpose |
|-------|---------|
| **User** | Authenticated user (Devise) |
| **Statement** | Monthly bank statement with date |
| **Expense** | Line item with subtotal, linked to a Category |
| **Category** | Classification (e.g., "Utilities") with keywords for matching |
| **Standard** | Benchmark for a Category (average/min/max amounts) |
| **Opportunity** | Savings potential: links Expense to Standard, status: `pending` → `contacted` → `completed` |

**Key method**: `Opportunity#savings` = expense.subtotal - standard.average_amount

## Tech Stack

- Rails 7.1, Hotwire (Turbo + Stimulus), PostgreSQL
- Bootstrap 5, Font Awesome, Simple Form
- Devise authentication

## Routes

Nested: `statements/:statement_id/expenses/:expense_id/opportunities/:id`

## UX & Copy Guidelines

**Ton général :**
- Franco-français, concis, centré sur l'utilisateur
- Pas de jargon technique (éviter "patterns", "scraping", etc.)
- Rassurer sans alarmer

**Sources de données :**
- Ne JAMAIS afficher les sources (source, source_url) → recette secrète 🤫
- Utiliser des formulations génériques : "nos standards", "données du marché"

**Exemples de formulations :**
| ❌ Éviter | ✅ Préférer |
|----------|------------|
| "Pattern détecté" | "Prélèvement suspect identifié" |
| "Basé sur Signal-Arnaques" | "Détection calculée à partir de nos standards" |
| "Données scrapées il y a 3 mois" | "Estimation basée sur des données récentes du marché" |
| "Vérifiez vos relevés avant toute action" | "Vérifiez vos relevés pour le détail" |
