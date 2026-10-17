# UniSelection — Phase 2 Architecture & Implementation Plan

**Document Title:** Phase 2 Implementation Plan (`docs/phase-2-implementation-plan.md`)  
**Scope Baseline:** `UniSelection_Phase_2_Master_Scope_v1.0.md`  
**Execution Context:** `docs/phase-2-baseline-audit.md`, `docs/phase-2-traceability.md`  
**Status Date:** October 17, 2026  
**Author / Lead Architect:** Principal Software Architect, Senior Flutter Engineer  
**Branch:** `feat/phase-2-implementation`

---

## 1. Architectural Vision & Scope Summary

Phase 2 elevates UniSelection from a verified directory into a **comprehensive higher education intelligence, actionable application planning, and verified scholarship navigation system**.

The system operates under three guiding engineering principles:
1. **Source-Attributed Truth:** Every university fact, scholarship criteria, and country visa guidance is explicitly bound to an official statutory source and verification timestamp (`last_checked_at`).
2. **Deterministic Transparency:** Recommendations and eligibility assessments avoid black-box generative AI. Every rating displays its constituent factor breakdown so students understand why a university matches their goals.
3. **Data Minimization & Local Privacy:** Student application plans, custom tasks, and reminders remain strictly on the student's device (`SharedPreferences`). No personal identity documents (CNIC, passports, bank records, transcripts) are collected or uploaded.

---

## 2. Incremental Implementation Architecture

```
+-----------------------------------------------------------------------------------+
|                           FLUTTER MOBILE CLIENT (v2.0)                            |
+-----------------------------------------------------------------------------------+
|  [P2-01 Scholarships]  [P2-02 Advanced Eligibility]  [P2-03 Recommendations]      |
|  [P2-04 App Tracker]   [P2-05 Calendar & Deadlines]  [P2-12 Country Guidance]     |
|  [P2-07 3-Tab Shortlist] [P2-11 Data Quality Dash]   [P2-08 Discrepancy Modal]    |
+-----------------------------------------------------------------------------------+
|                               REPOSITORY LAYER                                    |
|  UniSelectionRepository (Listenable, State Management, Deterministic Scoring)    |
|  NotificationService (Local Deadline Alerts) | RecommendationService (Formulas)   |
+-----------------------------------------------------------------------------------+
|                          SERVICES & PERSISTENCE LAYER                             |
|  LocalStorageService (Local Plans, Custom Tasks, Bookmarks, Scope, Profile)       |
|  RemoteApiService (PostgREST API Client) | DatasetLoader (Resilient Offline Seed) |
+-----------------------------------------------------------------------------------+
                                         |
                       +-----------------+-----------------+
                       |                                   |
         [PostgreSQL / Supabase REST]            [Local Asset Offline Seed]
         Migration 004 RLS Policies              starter_dataset.json (Verified)
         public.scholarships                     284 Institutions
         public.discrepancy_reports              14 Programmes | 14 Fee Records
         public.country_guidance                 12 Scholarships | 13 Country Guides
```

---

## 3. Module Specifications & Increments

### Increment A: Database Schema & RLS Hardening (P2-16)
- **Migration:** `backend/migrations/004_phase2_schema.sql`
- **Tables Added:**
  - `public.scholarships`: Enhanced schema with `funding_type`, `coverage_type`, `degree_levels`, `min_percentage`, `eligibility_criteria`, `source_url`, `official_application_url`, `last_checked_at`.
  - `public.discrepancy_reports`: Secure table for user-reported inaccuracies. RLS policy permits anonymous students to INSERT only (`WITH CHECK (true)`), while preventing any student from querying or viewing reports filed by others.
  - `public.country_guidance`: Bounded guidance for the 13 destination countries with statutory visa links.

### Increment B: Scholarship Finder & Detail (P2-01)
- **Model:** `mobile/lib/core/models/scholarship.dart` with enums for `ScholarshipFundingType`, `ScholarshipCoverageType`, `ScholarshipDeadlineStatus`, `ScholarshipVerificationStatus`.
- **Screens:** `ScholarshipFinderScreen` with search by keyword, funding type, coverage type, degree level, and toggles for "Open Only". `ScholarshipDetailScreen` with structured criteria, reminder scheduling, and official external portal launching.

### Increment C: Advanced Multi-Criterion Eligibility Assessment (P2-02)
- **Model:** `mobile/lib/core/models/eligibility_rule.dart` extended with `evaluateAdvanced()` supporting academic score, subject prerequisites, entry test thresholds, and domicile quotas.
- **Outcome Enum:** `meetsListedCriteria`, `mayMeetCriteria`, `doesNotMeetCriteria`, `insufficientInformation`.
- **UI:** `EligibilityScreen` renders individual `CriterionEvaluation` breakdown cards showing `met`, `unmet`, or `unverified` status.

### Increment D: Transparent Deterministic Recommendations (P2-03)
- **Service:** `mobile/lib/core/services/recommendation_service.dart`.
- **Scoring Breakdown:**
  1. Discipline Alignment: 35 points max
  2. Degree Level Availability: 25 points max
  3. Location Match: 20 points max
  4. Academic Aggregate Compatibility: 20 points max
  Total: 100 points. Same inputs strictly yield identical rankings.
- **UI:** Modal breakdown in `HomeScreen` detailing point contributions.

### Increment E: Application Planner & Tracker (P2-04) & Admissions Calendar (P2-05)
- **Models:** `ApplicationPlan` and `ApplicationTask` (milestone checklist, due dates, categories, progress ratio).
- **Storage:** Local-only `SharedPreferences` via `LocalStorageService` CRUD methods. Zero backend transmission.
- **Calendar:** `AdmissionsCalendarScreen` unifies admission cycles, scholarship deadlines, and user task milestones in a chronological timeline with notification reminders.

### Increment F: Bounded International Country Guidance (P2-12)
- **Model:** `CountryGuidance` and `CountryGuidanceLink`.
- **Dataset:** 13 destination countries (GBR, USA, CAN, AUS, DEU, SGP, TUR, MYS, NZL, CHE, SAU, FRA, CHN) sourced from official government visa and education agencies (gov.uk, state.gov, canada.ca, homeaffairs.gov.au, daad.de, etc.).
- **UI:** `CountryGuidanceScreen` with country picker, academic year patterns, visa types, official statutory links, and mandatory legal disclaimers.

### Increment G: Data Quality & Governance Dashboard (P2-11)
- **Screen:** `DataQualityDashboardScreen` accessible via Settings.
- **Metrics:** Real-time reconciliation of total institutions, published ratio, stale records (> 180 days), entity coverage counts, and sync engine health.
