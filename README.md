# UniSelection — Higher Education Admissions Guidance Platform

UniSelection is an actionable, student-focused, Android-first Flutter mobile application designed to help Pakistani and international students discover accredited universities, explore academic programmes, review verified fee schedules and admission cycles, calculate multi-criterion eligibility rules, plan applications, track admission milestones, navigate verified scholarships, and explore international destination guidance.

Built strictly according to **`UniSelection_Phase_2_Master_Scope_v1.0.md`** and the Phase 1 foundation documented in **[`AllAboutPhase1.md`](AllAboutPhase1.md)**.

---

## 🌟 Phase 2 Increment (v2.0) — Verified & Release Ready

**Branch:** `feat/phase-2-implementation` | **Release Version:** `v2.0` | **Status Date:** October 2026

| Metric | Phase 2 Result | Verification Command |
|---|---|---|
| `flutter analyze` | **0 issues found** (Clean) | `flutter analyze` |
| Flutter Test Suite (Unit & Widget) | **40 / 40 tests passed** (100%) | `flutter test` |
| Python Pytest Suite (Sync Engine) | **10 / 10 tests passed** (100%) | `pytest tests/test_sync_engine.py -v` |
| Python CLI Idempotency | **0 mutations / 0 diffs on re-sync** | `python -m data.sync.cli test-idempotency` |
| Dataset Integrity & Provenance | **100% PASS** (0 errors) | `python data/validation/validate_dataset.py` |
| Seed Dataset Synchrony (Hash Match) | **EXACT MATCH** (`c032fe8d725c...`) | Backend <-> Mobile parity verified |
| Institutional Coverage | **284 institutions (266 Pakistan HEC + 18 Global)** | Verified statutory directory |
| Verified Scholarships & Aid (P2-01) | **12 major schemes with official URLs** | Seeded and verified |
| Bounded International Guidance (P2-12) | **13 countries with government visa links** | Official immigration portals only |
| Phase 2 In-Scope Modules (P0 & P1) | **18 / 18 COMPLETE** | 8/8 Release Gates Passed |
| Release Status | **READY FOR PHASE 2 CLOSURE** | See [`docs/phase-2-release-readiness.md`](docs/phase-2-release-readiness.md) |

> Complete documentation: [`docs/phase-2-baseline-audit.md`](docs/phase-2-baseline-audit.md), [`docs/phase-2-traceability.md`](docs/phase-2-traceability.md), [`docs/phase-2-implementation-plan.md`](docs/phase-2-implementation-plan.md), [`docs/phase-2-test-results.md`](docs/phase-2-test-results.md), [`docs/phase-2-data-source-and-coverage-report.md`](docs/phase-2-data-source-and-coverage-report.md), [`docs/phase-2-security-and-privacy-review.md`](docs/phase-2-security-and-privacy-review.md), [`docs/phase-2-release-readiness.md`](docs/phase-2-release-readiness.md).

---

## 🚀 Key Phase 1 Deliverables

1. **Mobile Application (`mobile/`)**
   - **Flutter / Dart** application with a curated, modern Material 3 design system.
   - **Guest-First Discovery**: Full browsing, filtering, search, and details without forcing mandatory login.
   - **National & International Segregation**: Clear distinction between Pakistani universities (HEC recognized) and selected international universities with correct statutory accreditation bodies (OfS, NECHE, TEQSA, YÖK, etc.).
   - **Dynamic Categorization & Disciplines**: Data-driven categories (Engineering, Computing, Medicine, Business, etc.).
   - **Rich Detail Views**: University, Campuses, Programmes, Admission Cycles, and Fee breakdowns.
   - **Evidence & Source Verification**: Every admission deadline, fee figure, and programme lists its official source URL, verification status, and last checked date.
   - **Eligibility Guidance Engine**: Transparent, rule-based calculator showing required criteria, accurate deficit computations, mandatory caveats, and official admissions links.
   - **Shortlist & Comparison Matrix**: Persistent local shortlist with side-by-side comparative analysis across 8 attributes.
   - **Admin / Data Verifier Workflow**: In-app data review, real-time integrity metrics, status mutation workflow, and import validation preview.
   - **Dual Data Mode**: Connects to Supabase PostgreSQL via REST, with an integrated offline seed repository fallback so the app works seamlessly out-of-the-box without any backend configuration.

2. **Backend & Database (`backend/`)**
   - PostgreSQL schema migrations with normalized relational design:
     - `countries`, `cities`, `institutions`, `campuses`, `categories`, `institution_categories`, `disciplines`, `programmes`, `admissions`, `fee_records`, `eligibility_rules`, `sources`, `verification_records`, `saved_items`, `admin_audit_log`, `import_jobs`.
   - Comprehensive **Row Level Security (RLS)** policies ensuring public read access to verified data while securing private profile/saved data and strictly guarding admin actions.
   - Starter seed scripts covering 25 top Pakistani institutions (HEC recognized) and 14 renowned international institutions with correct statutory accreditation bodies.

3. **Data Operations & Validation (`data/`)**
   - Standardized CSV import templates for institutions and programmes.
   - Python data validation script (`data/validation/validate_dataset.py`) checking URL integrity, foreign keys, required metadata, date formats, duplicate detection, and SHA-256 sync between backend seed and mobile asset bundle.
   - Data curation guidelines and editorial hierarchy.

4. **Phase 1 Release & Audit Documentation (`docs/`)**
   - [`AllAboutPhase1.md`](AllAboutPhase1.md) — Master compendium of Phase 1 engineering, architecture, audit, and release evidence
   - [`docs/phase-1-final-gap-audit.md`](docs/phase-1-final-gap-audit.md) — Comprehensive module-by-module gap audit matrix (M1–M23)
   - [`docs/phase-1-remediation-log.md`](docs/phase-1-remediation-log.md) — Consolidated defect log (BUG-001 to BUG-015 and BUG-M23-001 to BUG-M23-007)
   - [`docs/phase-1-data-quality-audit.md`](docs/phase-1-data-quality-audit.md) — Census, foreign key integrity, and provenance audit
   - [`docs/phase-1-security-and-backend-verification.md`](docs/phase-1-security-and-backend-verification.md) — Table-by-table RLS matrix and security audit
   - [`docs/phase-1-test-results.md`](docs/phase-1-test-results.md) — Unified test execution results and emulator evidence
   - [`docs/phase-1-release-checklist.md`](docs/phase-1-release-checklist.md) — 12-item final gate checklist
   - [`docs/global-data-coverage-report.md`](docs/global-data-coverage-report.md) — Institutional coverage metrics across 284 institutions & 14 nations
   - [`docs/change-detection-and-review-workflow.md`](docs/change-detection-and-review-workflow.md) — Human-in-the-loop review workflow & classification matrix
   - [`docs/global-data-source-registry.md`](docs/global-data-source-registry.md) — Approved data sources, statutory bodies, and update cadence
   - [`docs/global-data-sync-design.md`](docs/global-data-sync-design.md) — Technical specification for data ingestion & sync engine
   - [`docs/global-university-data-architecture.md`](docs/global-university-data-architecture.md) — Target system architecture for global intelligence
   - [docs/data-quality-and-provenance.md](docs/data-quality-and-provenance.md) — Quality assurance standards, provenance scoring, and audit trails
   - [docs/data-licensing-and-crawl-policy.md](docs/data-licensing-and-crawl-policy.md) — Lawful crawling, rate limiting, and attribution compliance
   - [docs/architecture.md](docs/architecture.md) — System architecture, tech stack & data flows
   - [docs/decisions-log.md](docs/decisions-log.md) — Architecture Decision Records (ADRs)
   - [docs/data-dictionary.md](docs/data-dictionary.md) — Complete schema definitions, fields, constraints
   - [docs/test-plan.md](docs/test-plan.md) — Test strategy and verified Phase 1 execution results

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
│   │   └── 002_rls_policies.sql         # Row Level Security policies (15 tables)
│   └── seed/
│       ├── 001_starter_seed.sql         # SQL seed dataset (39 institutions)
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
│   ├── test-plan.md                     # Test strategy with Phase 1 verified execution results
│   ├── release-checklist.md             # Gate criteria for pilot and production deployment
│   ├── phase-1-audit-report.md          # Phase 1 module-by-module audit (M1–M22)
│   ├── phase-1-test-results.md          # Complete test execution output & screenshots
│   ├── phase-1-bug-fix-log.md           # 15 defects with root causes & regression evidence
│   ├── phase-1-api-and-data-report.md   # API, RLS, accreditation & dataset report
│   ├── phase-1-release-readiness.md     # Go/No-Go release readiness (58-item checklist)
│   └── screenshots/                     # Android emulator evidence (24 screenshots)
└── mobile/                              # Flutter application codebase
    ├── lib/
    │   ├── app/                         # App entry, routing, and theme definitions
    │   ├── core/                        # Models, seed data, repositories, services, and utils
    │   ├── features/                    # Feature modules (home, institutions, eligibility, shortlist, comparison, admin, settings)
    │   └── main.dart                    # Application bootstrap
    ├── test/
    │   ├── eligibility_test.dart        # 4 eligibility engine unit tests
    │   ├── repository_test.dart         # 12 repository & domain unit tests
    │   └── widget_test.dart             # 6 screen & widget tests
    └── pubspec.yaml                     # Dependencies and assets configuration
```

---

## 🛠️ Quick Start Guide

### 1. Prerequisites
- **Flutter SDK** (v3.13+ or later)
- **Dart SDK** (v3.0+ or later)
- **Python** (3.10+ for data validation scripts)
- **Android Studio** or **VS Code** with Flutter & Dart extensions
- **Android Emulator** (API 30+ recommended)

### 2. Mobile App Setup
```bash
# Navigate to mobile project
cd mobile

# Fetch Flutter dependencies
flutter pub get

# Run static analysis (expect 0 issues)
flutter analyze

# Run all tests (expect 22/22 pass)
flutter test

# Run on Android emulator
flutter run -d emulator-5554
# OR build debug APK
flutter build apk --debug
```

### 3. Data Validation
Run from the **repository root**:
```bash
python data/validation/validate_dataset.py
# Expected: ALL DATASET INTEGRITY CHECKS PASSED (100%)
```

### 4. Backend Database Setup (Supabase / PostgreSQL)
1. Create a Supabase project at [supabase.com](https://supabase.com).
2. Run SQL scripts in order in the Supabase SQL Editor:
   - `backend/migrations/001_initial_schema.sql`
   - `backend/migrations/002_rls_policies.sql`
   - `backend/seed/001_starter_seed.sql`
3. Build Flutter app with live credentials:
```bash
flutter build apk \
  --dart-define=SUPABASE_URL=https://<ref>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<your-anon-key>
```

> **Note:** Without live credentials, the app automatically falls back to the integrated offline starter dataset — fully functional out-of-the-box.

---

## 🛡️ Responsible Admissions Guidance Notice

UniSelection provides informational guidance derived from official public prospectuses and recognized university portals. It does not provide admission guarantees, official eligibility endorsements, visa counsel, or automated submission of applications. All data includes attribution to authoritative sources and explicit verification timestamps.

---

## 📊 Phase 1 Verified Test Output

```
flutter analyze                          → 0 issues found
flutter test                             → 22/22 All tests passed
python data/validation/validate_dataset.py → 0 errors
adb install (emulator-5554)              → Success
```

Screenshot evidence for all 8 interactive user journeys is available in [`docs/screenshots/`](docs/screenshots/).
