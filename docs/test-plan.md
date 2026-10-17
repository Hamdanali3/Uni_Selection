# UniSelection — Test Plan & Quality Assurance Strategy

**Version:** 2.1 (Updated with Phase 1 v1.3 M23 Data Intelligence verified execution results)  
**Scope Reference:** Section 14 & Section 16 of `UniSelection_Phase_1_Master_Scope_v1.3.md`  
**Last Execution:** October 2026 — Branch `audit-and-fixes`

This document details the multi-tiered quality assurance strategy for UniSelection Phase 1. See `docs/phase-1-test-results.md` for the complete verified execution output and screenshot evidence.

---

## 1. Test Levels & Coverage Targets

| Test Level | Scope | Framework / Tool | Target Coverage | Achieved (Phase 1) |
|---|---|---|---|---|
| **Static Analysis** | Entire Dart codebase | `flutter analyze` | 0 issues | ✅ 0 issues |
| **Unit Tests** | Domain models, Eligibility calculation, Formats | `flutter_test`, `test` | 90%+ of domain & calculation logic | ✅ 16/16 tests passed |
| **Widget Tests** | UI Cards, Filters, Empty/Error/Loading states | `flutter_test` | All core screens & reusable components | ✅ 6/6 tests passed |
| **Integration Tests** | End-to-end user journeys (Search → Shortlist → Compare) | Flutter Driver / Integration Test | Critical P0 flows | ✅ 8 journeys verified on `emulator-5554` |
| **Database RLS Tests** | Anonymous read, cross-user write denial, admin lock | Schema audit + RLS policy review | 100% of RLS policies | ✅ 15/15 tables reviewed |
| **Data Validation** | CSV template verification, FK integrity, URL format | Python (`validate_dataset.py`) | 100% of import records | ✅ 0 errors across 284 institutions |

---

## 2. Phase 1 Verified Test Execution Summary

```
flutter analyze        → 0 issues found
flutter test           → 22/22 tests passed (exit code 0)
validate_dataset.py    → 0 errors — ALL DATASET INTEGRITY CHECKS PASSED (100%)
APK install on device  → Success (emulator-5554, Pixel 10 Pro API 37)
```

### Eligibility Tests — `test/eligibility_test.dart` (4/4 ✅)
1. Student with score above minimum → `eligible`
2. Student with exact minimum score → `eligible` (boundary)
3. Student with score below minimum → `belowMinimum` with accurate deficit
4. Rule with null percentage → `requiresManualVerification`

### Repository Tests — `test/repository_test.dart` (12/12 ✅)
1. Initializes starter datasets properly (39 institutions, 14 programmes)
2. Accreditation body and statutory recognition integrity
3. Filters institutions by national scope (Pakistan only)
4. Filters institutions by international scope (non-PAK only)
5. Searches by acronym, name, and offered programme query
6. Programmes catalogue filter by scope and discipline
7. Shortlist toggle, retrieval, and clearAll works correctly
8. Profile persistence and retrieval (local SharedPreferences)
9. Onboarding status transitions
10. Admin mutation and verification summary recomputation
11. Eligibility rules retrieval and qualification matching
12. Fee records currency and session validation

### Widget Tests — `test/widget_test.dart` (6/6 ✅)
1. Onboarding Flow: shows `ScopeSelectorScreen` on first run and completes
2. Home Navigation: switches between all 5 tabs
3. `InstitutionsScreen`: scope tabs and search toggle
4. `EligibilityScreen`: evaluates quantitative score accurately
5. `AdminReviewScreen`: displays metrics and allows status filtering
6. `ShortlistScreen`: clear all button works with confirmation

---

## 3. Critical Journey Test Matrix

### Journey 1: National vs International Separation
- **Steps:**
  1. Launch app → Select "Pakistan (National)".
  2. Verify all listed institutions belong to Pakistan with `hec_recognized: true`.
  3. Switch filter to "International".
  4. Verify non-Pakistani institutions appear with statutory accreditation body labels.
- **Pass Criteria:** No mixed unlabelled results; international institutions show correct statutory body (OfS, NECHE, TEQSA, etc.).
- **Phase 1 Result:** ✅ PASS — Screenshots: `emulator_02_international_home.png`, `emulator_05_directory.png`

### Journey 2: Search, Filters, and Reset
- **Steps:**
  1. Open Universities tab.
  2. Enter search query "NUST" → verify result.
  3. Apply Public sector filter → verify private institutions removed.
  4. Enter non-matching query (e.g. "xyznonexistent").
  5. Verify helpful empty state with "Reset Filters" action.
- **Pass Criteria:** Accurate subset returned; zero crashes on empty results.
- **Phase 1 Result:** ✅ PASS — Verified on `emulator-5554` and `widget_test.dart`

### Journey 3: Eligibility Guidance Engine
- **Steps:**
  1. Navigate to Eligibility tab → Select degree and programme.
  2. Enter Academic Percentage: `55.0%`.
  3. Run evaluation. Verify status displays `5.0% below the published minimum of 60.0%`.
  4. Enter Academic Percentage: `78.5%`.
  5. Run evaluation. Verify status displays `Meets Minimum Academic Requirement`.
  6. Inspect mandatory caveat (always displayed regardless of eligibility status).
- **Pass Criteria:** Accurate threshold detection; mandatory caveat always displayed; no guarantee of admission made.
- **Phase 1 Result:** ✅ PASS — Screenshots: `emulator_14_eligibility_result_55.png`, `emulator_17_eligibility_result_78.png`

### Journey 4: Shortlist and Comparison
- **Steps:**
  1. From empty shortlist: tap "Browse Directory" → verify navigation to Universities.
  2. Bookmark NUST and LUMS from institution cards.
  3. Navigate to Shortlist tab. Verify both appear with delete icons.
  4. Tap "Compare All 2 Saved Universities".
  5. Inspect side-by-side comparison matrix (Full Name, City, Sector, Accreditation, Campuses, Programmes, Tuition Fee Basis, Official Portal).
  6. Verify both "HEC Recognized" badges appear for national institutions.
- **Pass Criteria:** Shortlist persists across navigation; comparison handles missing fields cleanly; "Open Website" links present.
- **Phase 1 Result:** ✅ PASS — Screenshots: `emulator_20_shortlist_with_items.png`, `emulator_21_comparison_matrix.png`

### Journey 5: Admin Status Mutation Workflow
- **Steps:**
  1. Open Settings → Data Verification & Editorial Console.
  2. Verify integrity metrics: 39 institutions, 100.0% verification rate.
  3. Tap ⋮ menu on NUST → "Mark In Review".
  4. Verify metrics update: 97.4% verification, In Review (1).
  5. Re-publish NUST → metrics revert to 100.0%, Published (39).
- **Pass Criteria:** Metrics recompute reactively; SnackBar confirms each mutation.
- **Phase 1 Result:** ✅ PASS — Screenshots: `emulator_26_status_mutated.png`, `emulator_27_republished.png`

---

### Journey 6: M23 Automated Data Sync, Provenance & Admin Review Queue
- **Steps:**
  1. Open Settings -> inspect M23 Data Intelligence Engine card (ACTIVE, 284 institutions, HEC+ROR sources).
  2. Navigate to University Directory -> inspect 266 HEC Recognized Pakistani institutions + 18 Global benchmarks.
  3. Open Institution Detail (e.g. Abdul Wali Khan University) -> inspect Verified Provenance & Freshness card (100% confidence, audit timestamp).
  4. Tap Flag icon / Report Issue -> submit student crowdsourced discrepancy report.
  5. Swipe TabBar -> inspect Scholarships tab empty state and portal link.
  6. Open Admin Review Console -> inspect Live Sync Run stats and Pending Change Proposals queue.
  7. Tap Approve on change proposal -> verify item removed from queue and counter decrements.
  8. Tap Reject on change proposal -> verify item rejected and counter decrements.
- **Pass Criteria:** 0 mutations on idempotent re-sync; live review queue supports approve/reject; discrepancy reports route to queue.
- **Phase 1 v1.3 Result:** ✅ PASS — Screenshots: m23_universities_list.png, m23_institution_detail.png, m23_discrepancy_dialog.png, m23_settings_diagnostics.png, m23_admin_review_items.png, m23_admin_item_approved_ok.png, m23_admin_item_rejected_ok.png

---

## 4. Data Integrity & Security Gates

- **Gate A (URL Validation):** ✅ Every official website, admissions link, and source reference is an absolute HTTPS URL — verified by `validate_dataset.py`.
- **Gate B (Attribution & Timestamps):** ✅ No admission cycle or fee record published without `last_verified_at` and `source_url` — verified by `validate_dataset.py`.
- **Gate C (RLS Verification):** ✅ RLS policies confirmed: anonymous INSERT/UPDATE/DELETE blocked with `USING (FALSE)` on all 15 catalogue tables — verified in `backend/migrations/002_rls_policies.sql`.
- **Gate D (Accreditation Accuracy):** ✅ All 14 international institutions have `hec_recognized = false` with correct statutory body — verified by `test/repository_test.dart` "Accreditation body integrity" test.
- **Gate E (Dataset Synchronization):** ✅ SHA-256 match between `backend/seed/` and `mobile/assets/data/` datasets confirmed by `validate_dataset.py`.

---

## 5. Known Limitations & Phase 2 Test Scope

| Limitation | Phase |
|---|---|
| Remote Supabase live API integration tests (requires live credentials) | Phase 2 |
| Push notification delivery testing (APNS/FCM) | Phase 2 |
| Full authentication flow tests (email + JWT) | Phase 2 |
| pgTAP database RLS integration tests (requires Supabase CLI) | Phase 2 |
| Performance/load testing against live API | Phase 2 |
| Accessibility audit (TalkBack, keyboard navigation) | Phase 2 |
