# UniSelection — Higher Education Admissions Guidance Platform

UniSelection is a student-focused, Android-first Flutter mobile application designed to help Pakistani and international students discover accredited universities, explore academic programmes, review verified fee schedules and admission cycles, check eligibility rules with caveats, save shortlists, and compare institutions.

Built strictly according to the **Phase 1 Master Scope Document (v1.2)**.

---

## 🚀 Key Phase 1 Deliverables

1. **Mobile Application (`mobile/`)**
   - **Flutter / Dart** application with a curated, modern Material 3 design system.
   - **Guest-First Discovery**: Full browsing, filtering, search, and details without forcing mandatory login.
   - **National & International Segregation**: Clear distinction between Pakistani universities (HEC recognized) and selected international universities.
   - **Dynamic Categorization & Disciplines**: Data-driven categories (Engineering, Computing, Medicine, Business, etc.).
   - **Rich Detail Views**: University, Campuses, Programmes, Admission Cycles, and Fee breakdowns.
   - **Evidence & Source Verification**: Every admission deadline, fee figure, and programme lists its official source URL, verification status, and last checked date.
   - **Eligibility Guidance Engine**: Transparent, rule-based calculator showing required criteria, caveats, and official admissions links.
   - **Shortlist & Comparison Matrix**: Persistent local shortlist with side-by-side comparative analysis.
   - **Admin / Data Verifier Workflow**: In-app data review, verification status inspector, and import validation preview.
   - **Dual Data Mode**: Connects to Supabase PostgreSQL via REST, with an integrated offline seed repository fallback so the app works seamlessly out-of-the-box.

2. **Backend & Database (`backend/`)**
   - PostgreSQL schema migrations with normalized relational design:
     - `countries`, `cities`, `institutions`, `campuses`, `categories`, `institution_categories`, `disciplines`, `programmes`, `admissions`, `fee_records`, `eligibility_rules`, `sources`, `verification_records`, `saved_items`, `admin_audit_log`, `import_jobs`.
   - Comprehensive **Row Level Security (RLS)** policies ensuring public read access to verified data while securing private profile/saved data and strictly guarding admin actions.
   - Starter seed scripts covering 25+ top Pakistani institutions (HEC recognized) and 12+ renowned international institutions.

3. **Data Operations & Validation (`data/`)**
   - Standardized CSV import templates for institutions and programmes.
   - Python data validation script (`data/validation/validate_dataset.py`) checking URL integrity, foreign keys, required metadata, date formats, and duplicate detection.
   - Data curation guidelines and editorial hierarchy.

4. **Architecture & Governance Documentation (`docs/`)**
   - `docs/architecture.md`
   - `docs/decisions-log.md`
   - `docs/data-dictionary.md`
   - `docs/data-source-register.md`
   - `docs/api-contracts.md`
   - `docs/test-plan.md`
   - `docs/release-checklist.md`

---

## 📁 Repository Directory Structure

```text
Uni_Selection/
├── .env.example                         # Environment variables template
├── .gitignore                           # Git ignore rules for Flutter, Dart, secrets, and IDEs
├── README.md                            # Main project overview & guide
├── UniSelection_Phase_1_Master_Scope_v1.2.md # Master Scope Baseline
├── backend/
│   ├── migrations/
│   │   ├── 001_initial_schema.sql       # PostgreSQL normalized tables & constraints
│   │   └── 002_rls_policies.sql         # Row Level Security policies
│   └── seed/
│       ├── 001_starter_seed.sql         # SQL seed dataset
│       └── starter_dataset.json         # Raw structured JSON dataset for app & imports
├── data/
│   ├── documentation/
│   │   └── data_guidelines.md           # Source verification & curation principles
│   ├── templates/
│   │   ├── institutions_template.csv    # Template for batch institution data import
│   │   └── programmes_template.csv      # Template for batch programme data import
│   └── validation/
│       └── validate_dataset.py          # Python batch validation script
├── docs/
│   ├── architecture.md                  # System architecture, tech stack & data flows
│   ├── decisions-log.md                 # Architecture Decision Records (ADRs)
│   ├── data-dictionary.md               # Complete schema definitions, fields, constraints
│   ├── data-source-register.md          # Registry of approved data sources & HEC references
│   ├── api-contracts.md                 # Supabase & logical REST API documentation
│   ├── test-plan.md                     # Unit, integration, widget, and RLS test specifications
│   └── release-checklist.md             # Gate criteria for pilot and production deployment
└── mobile/                              # Flutter application codebase
    ├── lib/
    │   ├── app/                         # App entry, routing, and theme definitions
    │   ├── core/                        # Models, seed data, repositories, and utils
    │   ├── features/                    # Feature modules (home, institutions, search, etc.)
    │   └── main.dart                    # Application bootstrap
    ├── test/                            # Unit and widget tests
    └── pubspec.yaml                     # Dependencies and assets configuration
```

---

## 🛠️ Quick Start Guide

### 1. Prerequisites
- **Flutter SDK** (v3.13+ or later)
- **Dart SDK** (v3.0+ or later)
- **Python** (3.10+ for data validation scripts)
- **Android Studio** or **VS Code** with Flutter & Dart extensions

### 2. Mobile App Setup
```bash
# Navigate to mobile project
cd mobile

# Fetch Flutter dependencies
flutter pub get

# Run on Chrome (Web) or connected Android device
flutter run -d chrome
# OR
flutter run -d windows
```

### 3. Data Validation
To validate datasets and import templates:
```bash
python data/validation/validate_dataset.py
```

### 4. Backend Database Setup (Supabase / PostgreSQL)
1. Create a Supabase project at [supabase.com](https://supabase.com).
2. Run SQL scripts in order in the Supabase SQL Editor:
   - `backend/migrations/001_initial_schema.sql`
   - `backend/migrations/002_rls_policies.sql`
   - `backend/seed/001_starter_seed.sql`
3. Copy your project URL and anonymous key into `mobile/lib/core/constants/app_config.dart` or `.env`.

---

## 🛡️ Responsible Admissions Guidance Notice
UniSelection provides informational guidance derived from official public prospectuses and recognized university portals. It does not provide admission guarantees, official eligibility endorsements, visa counsel, or automated submission of applications. All data includes attribution to authoritative sources and explicit verification timestamps.
