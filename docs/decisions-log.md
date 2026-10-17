# UniSelection — Architecture Decision Records (ADRs) & Decisions Log

**Version:** 1.0  
**Scope Reference:** Section 18 of `UniSelection_Phase_1_Master_Scope_v1.2.md`

This document records the foundational architecture and product decisions for Phase 1 of UniSelection.

---

## ADR-001: Mobile Stack Selection (Flutter/Dart)
- **Status:** Accepted
- **Context:** An Android-first mobile product is needed with a clear path to cross-platform (iOS/Web) expansion without rebuilding the user interface.
- **Decision:** Use Flutter with Dart. Target Android (API 24+) primarily, while maintaining clean responsive layouts compatible with Web and iOS.
- **Consequences:** Single codebase for UI, robust widget ecosystem, rapid preview and testability across Android emulators and web browsers.

---

## ADR-002: Backend Platform (Supabase with PostgreSQL)
- **Status:** Accepted
- **Context:** The product requires a relational database with strict foreign keys, source attribution, Row Level Security, and automated REST API generation without maintaining custom boilerplate server daemons in Phase 1.
- **Decision:** Use Supabase with PostgreSQL 15+. Utilize PostgREST for client queries and enforce Row Level Security (RLS) on all tables.
- **Consequences:** Reduced backend maintenance overhead, enterprise-grade SQL integrity, built-in Auth if enabled, and zero client-side secret exposure.

---

## ADR-003: Guest-First Access Model
- **Status:** Accepted
- **Context:** Students should be able to explore universities, search programmes, and check eligibility without friction or mandatory account creation.
- **Decision:** Public discovery, directory search, details, and eligibility checking do not require authentication. Guest users can save shortlists locally in secure local storage. Account registration is optional for cross-device cloud sync.
- **Consequences:** Higher user acquisition, lower abandonment rate, zero personal data liability for guest browsing.

---

## ADR-004: Dual-Mode Data Architecture (Live Supabase + Resilient Local Seed)
- **Status:** Accepted
- **Context:** Developers and initial pilot testers must be able to run and test the application immediately even when offline or before Supabase credentials are provisioned.
- **Decision:** Build a unified `UniSelectionRepository` that loads verified starter data locally if Supabase is offline or unconfigured, and fetches live published records when connected.
- **Consequences:** Seamless developer onboarding, zero broken screens during initial reviews, robust fallback in low-connectivity environments.

---

## ADR-005: Geographic Scope & Segregation
- **Status:** Accepted
- **Context:** Scope covers a verified starter catalogue of Pakistani institutions plus a curated set of international institutions.
- **Decision:** Introduce a clear "National" (Pakistan) vs "International" selector in the app navigation and home screens. Pakistani institutions are validated against HEC recognized categories. International institutions are curated with accreditation notes and explicit caveats that global coverage is not claimed.
- **Consequences:** Prevents confusion, respects regulatory distinctions, and avoids misleading students regarding comprehensive international coverage.

---

## ADR-006: Eligibility Guidance Engine Constraints
- **Status:** Accepted
- **Context:** Students need realistic guidance on minimum academic requirements without creating false impressions of guaranteed admission.
- **Decision:** Eligibility is strictly rule-based against published criteria (e.g. minimum FSc/A-Level percentage, required subject prerequisites, entry test thresholds). Every evaluation returns a clear status (`Eligible for Consideration`, `Below Published Minimum`, or `Requires Verification`), accompanied by mandatory caveats and the direct official source URL.
- **Consequences:** Zero legal liability regarding admission outcomes; high student trust through transparency.

---

## ADR-007: Transparent Data Freshness & Fee Basis
- **Status:** Accepted
- **Context:** University fees and admission deadlines fluctuate across academic sessions.
- **Decision:** Every fee record must declare its academic year (e.g. `2025–2026`), billing period (`Per Semester`, `Annual`, `Per Credit Hour`), breakdown between tuition and one-time admission charges, and a `verified_at` timestamp. Outdated records are flagged as `Under Review`.
- **Consequences:** Prevents outdated or misleading financial comparisons.

---

## Summary of Open & Resolved Decisions (Phase 1 Baseline)

| Decision Item | Baseline Resolution | Status |
|---|---|---|
| Target Countries | Pakistan (HEC catalog) + UK, USA, Canada, Germany, Australia, Turkey, Malaysia | Resolved |
| Guest vs Account | Guest-first browsing; local shortlist storage | Resolved |
| Language Support | English launch baseline; structured strings for future Urdu localization | Resolved |
| Admin Interface | In-app data review & verification status inspector + CLI/Python validation | Resolved |
| Push Notifications | Deferred to Phase 2; in-app deadline notices only for Phase 1 | Resolved |
| Minimum Android | Android 7.0 (API Level 24) | Resolved |
