# UniSelection — Test Plan & Quality Assurance Strategy

**Version:** 1.0  
**Scope Reference:** Section 14 & Section 16 of `UniSelection_Phase_1_Master_Scope_v1.2.md`

This document details the multi-tiered quality assurance strategy for UniSelection Phase 1.

---

## 1. Test Levels & Coverage Targets

| Test Level | Scope | Framework / Tool | Target Coverage |
|---|---|---|---|
| **Unit Tests** | Domain models, Eligibility calculation, Formats | `flutter_test`, `test` | 90%+ of domain & calculation logic |
| **Widget Tests** | UI Cards, Filters, Empty/Error/Loading states | `flutter_test` | All core screens & reusable components |
| **Integration Tests**| End-to-end user journeys (Search -> Shortlist -> Compare) | Flutter Driver / Integration Test | Critical P0 flows |
| **Database RLS Tests**| Anonymous read, cross-user write denial, admin lock | `pgTAP` / Supabase SQL Tests | 100% of RLS policies |
| **Data Validation**| CSV template verification, FK integrity, URL format | Python (`validate_dataset.py`) | 100% of import records |

---

## 2. Critical Journey Test Matrix

### Journey 1: National vs International Separation
- **Steps:**
  1. Launch app -> Select "Pakistan (National)".
  2. Verify all listed institutions belong to Pakistan with `is_national: true`.
  3. Switch filter to "International".
  4. Verify non-Pakistani institutions appear with accreditation body and country labels.
- **Pass Criteria:** No mixed unlabelled results; clear banner indicating limited international coverage.

### Journey 2: Search, Filters, and Reset
- **Steps:**
  1. Open Search modal.
  2. Select Category: "Engineering & Technology", City: "Islamabad".
  3. Verify results match criteria (e.g. NUST, PIEAS, Air University).
  4. Enter non-matching query (e.g. "xyznonexistent").
  5. Verify helpful empty state with "Reset Filters" action.
- **Pass Criteria:** Accurate subset returned; zero crashes on empty results.

### Journey 3: Eligibility Guidance Engine
- **Steps:**
  1. Navigate to NUST -> BS Computer Science -> Check Eligibility.
  2. Enter Academic Percentage: `55.0%`.
  3. Run evaluation. Verify status displays `Below Published Minimum (60% required)`.
  4. Enter Academic Percentage: `78.5%`.
  5. Run evaluation. Verify status displays `Eligible for Consideration`.
  6. Inspect mandatory caveat and official admissions URL.
- **Pass Criteria:** Accurate threshold detection; mandatory caveat displayed; no guarantee of admission made.

### Journey 4: Shortlist and Comparison
- **Steps:**
  1. From institution card or detail page, tap Bookmark/Shortlist icon.
  2. Navigate to "Shortlist" tab. Verify institution appears.
  3. Add a second institution to shortlist.
  4. Tap "Compare Selected".
  5. Inspect side-by-side comparison matrix (City, Sector, Disciplines, Tuition Fee Basis, Official Link).
  6. Remove one institution; verify matrix updates gracefully.
- **Pass Criteria:** Shortlist persists across navigation; comparison handles missing fields cleanly.

---

## 3. Data Integrity & Security Gates

- **Gate A (URL Validation):** Every official website, admissions link, and source reference must be an absolute HTTPS URL.
- **Gate B (Attribution & Timestamps):** No admission cycle or fee record may be published without `last_verified_at` and `source_url`.
- **Gate C (RLS Verification):** Anonymous write attempts to `institutions`, `programmes`, or `fee_records` must trigger HTTP 403 Forbidden.
