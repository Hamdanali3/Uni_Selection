# UniSelection — Phase 1 API, Data Architecture & Backend Report

**Version:** 1.0  
**Scope Reference:** Sections 7, 8, 9 of `UniSelection_Phase_1_Master_Scope_v1.2.md`  
**Audit Branch:** `audit-and-fixes`  
**Execution Date:** October 2026

---

## 1. Dual-Mode Architecture Overview

UniSelection implements a resilient offline-first, dual-mode data architecture to guarantee usability regardless of network availability during the Phase 1 MVP window.

```
┌─────────────────────────────────────────────────────────────────┐
│                    Flutter Mobile Client                        │
│                                                                 │
│   UniselectionRepository (single entry point)                   │
│       │                                                         │
│       ├── AppConfig.isSupabaseConfigured == true?               │
│       │       ↓ YES                                             │
│       │   RemoteApiService.fetchPublishedData()                 │
│       │   (HTTP GET → Supabase PostgREST REST API)              │
│       │       ↓ On timeout / 4xx / 5xx                          │
│       │   Fallback → Offline Seed Dataset                       │
│       │                                                         │
│       └── AppConfig.isSupabaseConfigured == false?              │
│               ↓ YES (default in build without env vars)         │
│           Offline Starter Seed Dataset                          │
│           (mobile/assets/data/starter_dataset.json)             │
└─────────────────────────────────────────────────────────────────┘

         ┌─────────────────────────────────────────────┐
         │           Supabase Cloud (Live Mode)        │
         │                                             │
         │   PostgreSQL 15 Database                    │
         │   PostgREST REST API                        │
         │   Row Level Security (RLS)                  │
         │   Supabase Auth (JWT)                       │
         └─────────────────────────────────────────────┘
```

### Active Phase 1 Mode

In the current Phase 1 MVP build, the Supabase URL is set to a placeholder (`placeholder-uniselection.supabase.co`), so `AppConfig.isSupabaseConfigured` evaluates to `false`. The repository transparently loads and serves the **offline starter seed dataset** from `mobile/assets/data/starter_dataset.json`.

Deployment for live API mode requires only injecting real environment variables at build time — no code changes needed:
```bash
flutter build apk --dart-define=SUPABASE_URL=https://<ref>.supabase.co \
                  --dart-define=SUPABASE_ANON_KEY=<anon_key>
```

---

## 2. Database Schema

### 2.1 Core Entity Tables

| Table | Primary Key | Description |
|---|---|---|
| `countries` | `id VARCHAR(3)` | ISO 3166 alpha-3 country codes (PAK, GBR, USA, etc.) |
| `cities` | `id UUID` | City records linked to countries |
| `institutions` | `id VARCHAR(50)` | Universities — national and international |
| `campuses` | `id UUID` | Sub-campuses per institution |
| `categories` | `id UUID` | Discipline groupings (Engineering, Medicine, etc.) |
| `institution_categories` | composite | Many-to-many institution ↔ category join |
| `disciplines` | `id UUID` | Fine-grained academic disciplines |
| `programmes` | `id UUID` | Degree programmes |
| `admissions` | `id UUID` | Admission cycles per institution |
| `fee_records` | `id UUID` | Tuition fee schedules per institution |
| `eligibility_rules` | `id UUID` | Academic minimum thresholds per programme |
| `sources` | `id UUID` | Official source attribution registry |
| `verification_records` | `id UUID` | Audit trail for data verification |
| `saved_items` | `id UUID` | User shortlist items (remote sync) |
| `admin_audit_log` | `id UUID` | Admin action log |
| `import_jobs` | `id UUID` | CSV import job tracking |

### 2.2 Key Relationships

```
countries ──< cities ──< institutions ──< campuses
                                    └──< institution_categories >── categories
                                    └──< programmes ──< eligibility_rules
                                    └──< admissions
                                    └──< fee_records
                                    └──< verification_records
```

### 2.3 Critical Schema Constraints

```sql
-- National vs International distinction
institutions.hec_recognized BOOLEAN NOT NULL DEFAULT FALSE;
-- National (PAK): hec_recognized = TRUE, accreditation_body = 'HEC'
-- International:  hec_recognized = FALSE, accreditation_body = '<statutory body>'

-- Source attribution mandatory for admissions and fees
admissions.source_url TEXT NOT NULL;
admissions.last_verified_at DATE NOT NULL;
fee_records.source_url TEXT NOT NULL;
fee_records.last_verified_at DATE NOT NULL;

-- Status workflow
institutions.status VARCHAR(20) CHECK (status IN ('published', 'in_review', 'draft'));
```

---

## 3. Row Level Security (RLS) Policies

All 15 PostgreSQL tables have RLS enabled. The security model:

| Policy Type | Target Tables | Rule | Effect |
|---|---|---|---|
| **Anonymous Read** | All public tables | `status = 'published'` | Students see only verified records |
| **Authenticated Read** | `saved_items` | `user_id = auth.uid()` | Users see only their own shortlist |
| **Anonymous Write** | All tables | `FALSE` | Blocked (HTTP 403) |
| **Service-Role Write** | Admin tables | `auth.role() = 'service_role'` | Admin import pipeline only |
| **Admin Update** | `institutions.status` | `auth.role() IN ('admin', 'service_role')` | Editorial status changes |

### Key RLS Policies (excerpt from `002_rls_policies.sql`)

```sql
-- Public can only read published institutions
CREATE POLICY "Public read published institutions"
  ON institutions FOR SELECT
  USING (status = 'published');

-- Deny all anonymous writes
CREATE POLICY "Deny anonymous writes to institutions"
  ON institutions FOR INSERT
  USING (FALSE);

-- Users can manage their own saved items
CREATE POLICY "Users manage own saved items"
  ON saved_items
  USING (user_id = auth.uid());

-- Admin audit log: service-role insert only
CREATE POLICY "Service role can insert audit log"
  ON admin_audit_log FOR INSERT
  TO service_role
  WITH CHECK (TRUE);
```

### Security Compliance Verification

| Security Gate | Status |
|---|---|
| Service-role key excluded from mobile bundle | ✅ `AppConfig.supabaseAnonKey` only (anon key) |
| Zero personal sensitive data collected | ✅ No CNIC, passport, financial docs in any screen |
| RLS enabled on all 15 tables | ✅ Verified in `backend/migrations/002_rls_policies.sql` |
| Anonymous write rejection | ✅ `USING (FALSE)` on INSERT/UPDATE/DELETE policies |
| Admin audit trail | ✅ `admin_audit_log` table with timestamped entries |

---

## 4. PostgREST API Contracts (Live Mode)

### 4.1 Institution Discovery

```http
GET /rest/v1/institutions
  ?status=eq.published
  &select=*,cities(*),countries(*),institution_categories(categories(*))
  &country_id=eq.PAK          ← National scope filter
  &order=name.asc
  &limit=25
Headers:
  apikey: <SUPABASE_ANON_KEY>
  Authorization: Bearer <SUPABASE_ANON_KEY>
```

**Response shape (200 OK):**
```json
[
  {
    "id": "nust",
    "name": "National University of Sciences & Technology",
    "short_name": "NUST",
    "country_id": "PAK",
    "institution_type": "Public",
    "hec_recognized": true,
    "accreditation_body": "HEC",
    "official_website": "https://nust.edu.pk",
    "admissions_url": "https://ugadmissions.nust.edu.pk",
    "status": "published",
    "last_verified_at": "2026-09-20"
  }
]
```

**Error responses:**
- `401 Unauthorized` — Missing or invalid anon key
- `403 Forbidden` — RLS policy rejection (write attempt on read-only endpoint)
- `404 Not Found` — Table/view not found (schema misconfiguration)
- `408 / timeout` — Triggers fallback to offline seed

### 4.2 Programme Catalogue

```http
GET /rest/v1/programmes
  ?status=eq.published
  &institution_id=eq.{id}
  &select=*,disciplines(*)
  &order=name.asc
```

### 4.3 Eligibility Rules

```http
GET /rest/v1/eligibility_rules
  ?programme_id=eq.{id}
  &select=*
```

**Response shape:**
```json
[
  {
    "id": "rule-001",
    "programme_id": "prog-nust-bscs",
    "rule_type": "quantitative",
    "minimum_percentage": 60.0,
    "description": "Minimum 60% in FSc (Pre-Engineering) or equivalent",
    "source_url": "https://ugadmissions.nust.edu.pk/eligibility",
    "last_verified_at": "2026-09-20"
  }
]
```

### 4.4 Fee Records

```http
GET /rest/v1/fee_records
  ?institution_id=eq.{id}
  &select=*
  &order=academic_year.desc
```

**Response shape:**
```json
[
  {
    "id": "fee-nust-2026",
    "institution_id": "nust",
    "programme_id": "prog-nust-bscs",
    "tuition_fee": 185000.0,
    "currency": "PKR",
    "billing_basis": "per_semester",
    "academic_year": "2025-2026",
    "source_url": "https://nust.edu.pk/admission/fee-structure/",
    "last_verified_at": "2026-09-20"
  }
]
```

> [!NOTE] The Dart model (`FeeRecord.fromJson`) handles both `tuition_fee` (JSON/SQL) and `tuition_amount` (alternative field name) defensively to support both naming conventions — see BUG-003 in `phase-1-bug-fix-log.md`.

### 4.5 Admission Cycles

```http
GET /rest/v1/admissions
  ?institution_id=eq.{id}
  &select=*
  &order=academic_year.desc
```

> [!NOTE] The Dart model (`Admission.fromJson`) handles both `cycle_name` and `session_name` defensively — see BUG-002 in `phase-1-bug-fix-log.md`.

---

## 5. Offline Seed Dataset Structure

**Location:** `mobile/assets/data/starter_dataset.json` (synchronized with `backend/seed/starter_dataset.json`)  
**SHA-256 Match:** ✅ Verified by `validate_dataset.py`

### Top-level structure
```json
{
  "countries":          [ ... 8 countries ... ],
  "cities":             [ ... 20 cities ... ],
  "categories":         [ ... 8 categories ... ],
  "disciplines":        [ ... 14 disciplines ... ],
  "institutions":       [ ... 39 institutions ... ],
  "campuses":           [ ... 47 campuses ... ],
  "programmes":         [ ... 14 programmes ... ],
  "eligibility_rules":  [ ... 14 rules ... ],
  "admissions":         [ ... 5 cycles ... ],
  "fee_records":        [ ... 14 records ... ]
}
```

### Dataset Composition

| Collection | Count | Description |
|---|---|---|
| Countries | 8 | PAK + 7 international |
| Cities | 20 | Major Pakistani + international cities |
| Categories | 8 | Engineering, Computing, Medicine, Business, Law, Architecture, Sciences, Arts |
| Disciplines | 14 | Fine-grained academic disciplines |
| **Institutions** | **39** | **25 Pakistani (HEC) + 14 International** |
| Campuses | 47 | Multi-campus coverage for major universities |
| Programmes | 14 | Sample programmes across disciplines |
| Eligibility Rules | 14 | Quantitative and qualitative rules |
| Admission Cycles | 5 | 2025–2026 cycles for key institutions |
| Fee Records | 14 | PKR / GBP / USD / AUD / CHF fee records |

### Accreditation Data Correctness

| Scope | `hec_recognized` | `accreditation_body` |
|---|---|---|
| Pakistani (25 institutions) | `true` | `"HEC"` |
| International (14 institutions) | `false` | Statutory body per country (e.g. `"Office for Students (OfS)"`, `"NECHE"`, `"TEQSA"`) |

---

## 6. Eligibility Calculation Engine

The eligibility engine runs entirely in Dart on-device with no network dependency.

**Domain class:** `EligibilityCalculator` (pure Dart, no Flutter dependencies)  
**Model:** `EligibilityRule` with fields: `ruleType`, `minimumPercentage`, `description`, `sourceUrl`, `lastVerifiedAt`

### Algorithm (quantitative rules)

```
IF student_percentage >= rule.minimumPercentage:
    → status: "eligible"
    → message: "Meets Minimum Academic Requirement"

IF student_percentage < rule.minimumPercentage:
    → status: "belowMinimum"
    → deficit: (rule.minimumPercentage - student_percentage).toStringAsFixed(1)
    → message: "{deficit}% below the published minimum of {rule.minimumPercentage}%"

IF rule.minimumPercentage == null (qualitative rule):
    → status: "requiresManualVerification"
    → message: "Please verify requirements directly with the institution"
```

**Mandatory disclaimer** (always displayed, regardless of eligibility status):
> "This is informational guidance only. UniSelection does not make official admission decisions or guarantee admission outcomes. Verify requirements directly with the institution."

---

## 7. Data Validation Checks (`validate_dataset.py`)

### Checks Performed

| Check | Description | Result |
|---|---|---|
| JSON schema presence | All required top-level keys exist | ✅ Pass |
| Institution required fields | `id`, `name`, `country_id`, `status`, `hec_recognized`, `official_website`, `last_verified_at` | ✅ All 39 institutions |
| International accreditation | `hec_recognized == false` for non-PAK institutions | ✅ 14 checked |
| URL format validation | All `official_website` and `source_url` fields are valid HTTPS URLs | ✅ Pass |
| Date format validation | `last_verified_at` parses as YYYY-MM-DD | ✅ Pass |
| Foreign key integrity | Programme `institution_id` → valid institution | ✅ Pass |
| Duplicate detection | No duplicate `id` values across any collection | ✅ Pass |
| Currency correctness | PAK institutions use PKR; INT institutions use GBP/USD/EUR/AUD/CHF/TRY | ✅ Pass |
| SHA-256 sync check | `backend/seed/` and `mobile/assets/data/` datasets identical | ✅ Match |
| CSV template validation | Both institution and programme CSV templates have required headers | ✅ Pass |

**Overall result: 0 errors — ALL DATASET INTEGRITY CHECKS PASSED (100%)**
