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

---

# Phase 2 Architecture Decision Records (ADRs)

## ADR-P2-001: Local-Only Privacy Architecture for Application Plans & Checklists
- **Status:** Accepted
- **Context:** Students tracking admission milestones and tasks often enter personal deadlines and intentions. Uploading these plans to a cloud server introduces privacy risks, GDPR/data sovereignty concerns, and database synchronization overhead.
- **Decision:** Application plans, custom checklist tasks, and due dates are stored strictly on-device in `SharedPreferences` via `LocalStorageService`. No user application plans are transmitted or synchronized to Supabase or any remote backend.
- **Consequences:** Guarantees absolute student privacy; zero liability for personal data breaches; eliminates network latency and offline syncing complexity.

---

## ADR-P2-002: Local Notifications Architecture Without Remote Push Relays
- **Status:** Accepted
- **Context:** Students require deadline reminders for upcoming admissions and scholarships, but standing up an external Firebase Cloud Messaging (FCM) / Apple Push Notification service (APNS) infrastructure requires user authentication, device token registries, and server maintenance.
- **Decision:** Reminders are managed locally on the device using `NotificationService`. Reminders are scheduled directly against device time and local state.
- **Consequences:** Zero external push infrastructure required; operates seamlessly without user registration or cloud server connectivity.

---

## ADR-P2-003: Deterministic Explainable Scoring Formula for Recommendations
- **Status:** Accepted
- **Context:** Personalized university matching often suffers from black-box recommendation models that produce opaque or biased outputs that cannot be audited or explained to students.
- **Decision:** The recommendation engine (`RecommendationService`) uses a pure, deterministic mathematical formula with 100 points maximum across four transparent factors:
  1. Discipline Alignment (35 points)
  2. Degree Level Availability (25 points)
  3. Location Match (20 points)
  4. Academic Aggregate Compatibility (20 points)
  Every recommendation displays an interactive factor breakdown showing points awarded and explanatory notes. No generative AI or black-box machine learning is used.
- **Consequences:** 100% explainability, complete determinism (same inputs always produce identical rankings), and full student auditability.

---

## ADR-P2-004: Bounded Initial Set for International Country Guidance
- **Status:** Accepted
- **Context:** Offering unbounded international guidance leads to inaccurate or outdated immigration advice.
- **Decision:** International guidance is strictly bounded to the 13 approved destination countries benchmarked in the dataset: Pakistan, United Kingdom, United States, Canada, Germany, Australia, Singapore, Turkey, Malaysia, New Zealand, Switzerland, Saudi Arabia, France, and China. All visa links and guidance must point directly to official government immigration portals.
- **Consequences:** Protects students from predatory or unauthorized education agents; ensures every country link is authoritative.

---

## ADR-P2-005: Insert-Only Anonymous Row Level Security for Discrepancy Reports
- **Status:** Accepted
- **Context:** Students need to report data discrepancies anonymously without logging in, but public tables risk unauthorized scraping or leaking student submissions.
- **Decision:** The `discrepancy_reports` table has RLS enabled with an `INSERT` policy for `anon` and `authenticated` roles (`WITH CHECK (true)`), but **zero `SELECT` access** for non-admin roles. Only `service_role` can read or resolve reports.
- **Consequences:** Fully crowdsourced data accuracy without any risk of user submission harvesting or data leakage.

---

## ADR-P2-006: Human-in-the-Loop Governance for Upstream Regulatory Ingestion
- **Status:** Accepted
- **Context:** Automated scrapers or synchronizers could inadvertently ingest spurious or unverified regulatory changes that misinform students.
- **Decision:** Ingested changes to accreditation, statutory recognition, or degree titles are routed to `review_queue` as pending items. No critical regulatory status mutation can be published to the mobile directory without explicit administrator confirmation.
- **Consequences:** Prevents automated data corruption; guarantees statutory integrity.

