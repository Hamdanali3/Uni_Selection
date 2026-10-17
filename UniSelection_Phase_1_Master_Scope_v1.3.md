# UniSelection App — Phase 1 Master Scope Document

**Version 1.3 | 17 October 2026 | Status: Authoritative Baseline with Module M23**

> This document is the authoritative Phase 1 product scope baseline for UniSelection, incorporating **Module M23: Global University Data Intelligence, Verified Ingestion, and Automated Synchronization**. It defines the functional boundaries, architecture, data governance, and acceptance criteria for Phase 1.

---

## 1. Executive Summary

UniSelection is a student-focused, Android-first mobile platform and data intelligence system designed to help Pakistani and international students discover accredited universities, explore academic programmes, evaluate eligibility criteria against transparent rules, review verified fee schedules and admission cycles, save shortlists, and compare institutions.

Phase 1 delivers a verified, production-grade Minimum Viable Product (MVP) backed by a lawful, source-attributed, repeatable data ingestion and automated synchronization pipeline. Rather than relying on a static, hand-curated list of universities, Phase 1 establishes an extensible data platform that:
1. **Discovers global degree-awarding institutions** through authorized open research registries (ROR, OpenAlex) and official national registers, filtering out non-academic entities.
2. **Reconciles the full national baseline** of Pakistan Higher Education Commission (HEC) recognized universities, Degree Awarding Institutions (DAIs), and recognized regional sub-campuses.
3. **Ingests deep, time-sensitive academic facts** (programmes, admission cycles, fee schedules, eligibility rules, and scholarships) directly from official university prospectuses and statutory regulatory portals.
4. **Detects meaningful upstream changes** via conditional HTTP requests, cryptographic content fingerprinting, and field-level diff detection.
5. **Applies risk-based publication**: low-risk updates are synchronized safely; high-impact or ambiguous regulatory changes (accreditation shifts, eligibility adjustments, deadline moves, fee increases) are routed to an administrative review queue with zero silent overwrites.
6. **Maintains complete provenance**: every displayed fact links back to its authoritative source, with verification timestamps and data freshness indicators.

---

## 2. Product Vision and Objectives

**Vision:** To democratize higher education discovery for students in Pakistan and globally by building a dependable, source-attributed university intelligence platform where information is transparent, fresh, verifiable, and free from misleading commercial bias.

**Phase 1 Objectives:**
- Deliver an Android-first Flutter mobile application with guest-first discovery and Material 3 design.
- Reconcile 100% of accessible Pakistani HEC-recognized institutions and campuses from official authoritative sources.
- Provide worldwide institutional discovery covering thousands of accredited universities across 50+ countries without falsely claiming deep data completeness for every foreign institution.
- Provide deep programme, fee, admission, eligibility, and scholarship data for top target national and international destinations.
- Enforce strict data provenance: every critical fact includes source attribution (`source_url`, `last_checked_at`, `last_verified_at`, `confidence_score`).
- Implement an automated, lawful synchronization engine capable of detecting upstream updates, running idempotent re-syncs, and routing high-risk mutations to human review.
- Establish an in-app Admin & Review Console allowing editorial staff to inspect sync runs, evaluate field diffs, and approve/reject change proposals.
- Ensure strict privacy and security: zero collection of sensitive PII (CNICs, passports, bank statements), complete Row Level Security (RLS) enforcement, and server-side secret isolation.

---

## 3. Scope Principles and Implementation Constraints

1. **Guest-First Architecture:** Students can browse, search, filter, evaluate eligibility, and compare universities without mandatory registration or login.
2. **Critical Coverage Distinction:**
   - **Layer A (Global Institution Registry):** Broad, worldwide institutional discovery using authorized open registries (ROR, OpenAlex) and official national directories. Explicitly excludes non-university research institutes, corporate entities, and hospitals.
   - **Layer B (Pakistani National Baseline):** Comprehensive, authoritative coverage of all HEC-recognized Pakistani universities, DAIs, and regional sub-campuses derived directly from statutory HEC registers.
   - **Layer C (Deep Entity Records):** High-evidence, time-sensitive academic data (programmes, admission cycles, tuition fees, eligibility rules, scholarships). Ingested selectively from official university websites and prospectuses with full provenance.
3. **Explicit Field-Level Gap Tracking:** Missing data remains explicitly marked as `"Not Published / Unknown"`. The system will never fabricate dates, fees, eligibility rules, or accreditation to fill empty fields.
4. **Lawful Access as a Prerequisite:** Ingestion connectors strictly obey `robots.txt`, terms of service, acceptable use policies, copyright guidelines, polite rate limits, and host-specific concurrency. No CAPTCHA bypassing, paywall circumvention, or unauthorized scraping.
5. **Idempotent Synchronization:** Re-running synchronization on unchanged data produces zero duplicate records and zero spurious change events.
6. **Dual Data Channel:** Mobile app connects to Supabase PostgreSQL REST API when configured, with seamless automated fallback to an integrated offline seed dataset.

---

## 4. Users and Roles

- **Student / Guest:** Unauthenticated user who browses institutions, filters programmes, checks eligibility guidance, saves local shortlists, and compares options.
- **Registered Student (Optional Phase 1):** Authenticated user with cloud-synced shortlists and local preferences.
- **Data Ingestion Engineer:** Technical operator responsible for configuring source connectors, managing crawl schedules, and monitoring synchronization health.
- **Data Verifier / Reviewer:** Authorized editorial team member who reviews the change queue, inspects side-by-side field diffs against source evidence, and approves/rejects proposed updates.
- **System Administrator:** Controls role assignments, database migrations, security policies, and inspects immutable audit logs.

---

## 5. Phase 1 Functional Modules

UniSelection Phase 1 is composed of 23 functional modules:

### Core Student-Facing Modules
- **M1. Onboarding and App Navigation:** Welcome walkthrough, national vs international scope selector, 5-tab shell navigation (`Discover`, `Universities`, `Eligibility`, `Shortlist`, `Settings`), persistent state, and responsive error/empty views.
- **M2. Student Profile (basic):** Local student study preferences (degree level, discipline interests, target cities) with explicit Data Minimization Notice (zero CNIC, passport, or financial document collection).
- **M3. University Directory:** National directory (HEC-recognized institutions with verified badges) and international directory (statutory accreditation body labels), public/private sector chips, and location tags.
- **M4. Campus Directory:** Multi-campus architecture linking regional sub-campuses to parent institutions with statutory HEC campus registry links.
- **M5. Institution Categories and Disciplines:** Normalized relational categorization (Engineering, Computing, Medicine, Business, Arts, Social Sciences, etc.) supporting multi-discipline associations.
- **M6. Programme Catalogue:** Academic offerings across degree levels (Undergraduate, Postgraduate, Doctorate) with credit hours, duration, and discipline mapping.
- **M7. Search and Filters:** Real-time multi-attribute search across names, acronyms, and cities; facet filters for sector, discipline, degree level, and scope; graceful empty states with "Reset Filters" action.
- **M8. Institution and Programme Details:** Detailed views with tabs for Overview, Campuses, Programmes, Admissions, Fees, and Scholarships; verified source URLs with external browser launch.
- **M9. Basic Eligibility Guidance:** Pure Dart rule-based calculation engine evaluating academic percentage against published minimums; provides explicit deficit calculation (e.g., "5.0% below minimum") and statutory disclaimer: "Informational guidance only, does not guarantee admission."
- **M10. Admission Information:** Verified application opening/closing dates, entry test schedules, intake sessions, and source attribution.
- **M11. Fee Information:** Published tuition fees, currency specifications (PKR for national; foreign currencies for international), billing basis (`per_semester`, `per_year`), academic year, and source URLs.
- **M12. Shortlist / Favorites:** Local bookmarking of saved institutions and programmes with persistent storage, direct navigation, and clear-all confirmation dialogs.
- **M13. Basic Comparison:** Side-by-side comparative matrix evaluating up to 3 institutions across 8 attributes (Name, City/Country, Sector, Accreditation, Campuses, Degrees, Tuition Basis, Official Portal).

### Platform, Backend & Governance Modules
- **M14. Admin and Data Review:** In-app editorial console showing real-time catalog integrity metrics (total institutions, verification percentage, review counts) and status mutation workflows (Publish, Mark In Review, Revert to Draft).
- **M15. Data Import and Validation:** Standardized CSV templates and automated Python validation CLI (`validate_dataset.py`) checking foreign keys, URL formats, date syntax, duplicates, and SHA-256 asset synchronization.
- **M16. Backend API and Data Access:** Dual-mode architecture supporting remote Supabase PostgREST queries with automatic offline seed fallback.
- **M17. Authentication and Authorization:** Guest-first discovery baseline with secure JWT authentication and role-based policies for editorial staff.
- **M18. Notifications Foundation:** Local deadline indicators and admission cycle countdown tags.
- **M19. Privacy, Security and Audit:** Row Level Security (RLS) on all PostgreSQL tables; service-role key excluded from mobile client; immutable admin audit logging.
- **M20. Analytics and Operational Diagnostics:** In-app diagnostics card displaying active data channel, dataset citation rate, and catalog health.
- **M21. Quality Assurance:** Automated static analysis (`flutter analyze`), unit tests, widget tests, dataset validation CLI, and real Android emulator testing.
- **M22. Documentation and Team Workflow:** Comprehensive documentation suite (architecture, data dictionary, source register, API contracts, test plan, release checklist).

### Expanded Intelligence Module
- **M23. Global University Data Intelligence and Automated Synchronization:**
  - **Source Registry & Connectors:** Documented registry of authorized data sources (HEC official portals, ROR API, OpenAlex API, statutory national registries, authorized aggregators).
  - **Multi-Source Ingestion Pipeline:**
    - *Layer A:* Automated discovery of accredited global universities with persistent IDs (ROR, OpenAlex), filtering out non-academic entities.
    - *Layer B:* Automated reconciliation of 267+ official Pakistani HEC universities/DAIs and campuses from authoritative HEC sources.
    - *Layer C:* Ingestion of detailed programmes, admission cycles, fee structures, and scholarships from official university websites with verified dates.
  - **Automated Change Detection:** Conditional HTTP requests (`ETag`, `Last-Modified`), SHA-256 content hashing, and field-level diff detection comparing incoming records against database state.
  - **Risk-Based Review Queue:** Low-risk changes (minor typo normalization, website update) auto-published if confidence exceeds 95%; high-risk changes (accreditation status, eligibility threshold, deadline shift, tuition increase >10%) routed to `review_queue` for editorial approval with side-by-side diff display.
  - **Provenance & Freshness Indicators:** Every displayed record displays `Last Checked`, `Last Verified`, `Confidence Rating`, and official source links, with user-facing "Report an Issue" feedback dialogs.
  - **Safe Failure & Error Containment:** Upstream source outages or parser layout changes fail gracefully without overwriting good data.

---

## 6. Explicit Phase 1 Exclusions

The following remain explicitly excluded from Phase 1 scope:
- Automated university application submission or document upload to universities.
- Visa, legal, or immigration counselling/guarantees.
- Payment processing, fee collection, or paid agent counselling marketplaces.
- Unapproved web scraping that bypasses CAPTCHAs, paywalls, or authentication safeguards.
- Full machine-learning predictive admission likelihood engines (rule-based guidance only).
- Fabrication or synthetic generation of missing tuition fees, deadlines, or accreditation statuses.

---

## 7. Data Sources and Authority Hierarchy

### Configurable Source Authority Order:
1. **Tier 1 (Statutory Regulators):** Higher Education Commission (HEC Pakistan), statutory professional accreditation councils (PEC, NCEAC, PMDC, PNC, Pharmacy Council, NBEAC, PCATP), UK Office for Students (OfS), US regional accreditors (NECHE, WASC), Australian TEQSA.
2. **Tier 2 (Official Institutional Portals):** Primary university homepages, verified sub-campus directories, official admission portals, and official published prospectuses.
3. **Tier 3 (Authoritative Global Registries):** Research Organization Registry (ROR), OpenAlex, UNESCO Institute for Statistics (UIS), International Association of Universities / WHED.
4. **Tier 4 (Educational Aggregators):** Platforms such as Eduvision, Eduhubpak, and PakUniFinder. *Used strictly for discovery and cross-checking candidate URLs; never treated as authoritative regulatory proof.*

---

## 8. Data Architecture & Database Schema Additions

Phase 1 incorporates normalized relational tables to support M23:
- `data_sources`: Source registry with URLs, tier, access method, licensing, and poll interval.
- `source_connectors`: Technical connector parameters, headers, rate limits, and timeouts.
- `source_field_mappings`: Field-level authority precedence rules.
- `sync_runs`: Audit log of synchronization executions, duration, records discovered/updated, and errors.
- `source_snapshots`: Content fingerprints (ETag, Last-Modified, SHA-256 hash) for change detection.
- `source_change_events`: Granular field diffs (entity, field, old_value, new_value, diff_reason, confidence).
- `review_queue`: High-risk proposals awaiting human review with approval/rejection audit trail.
- `institution_identifiers`: Persistent external IDs (ROR ID, OpenAlex ID, HEC DAI ID, CRICOS, UKPRN).
- `institution_aliases`: Alternative names, previous legal names, and regional transliterations.
- `scholarships`: Financial aid offerings with provider, funding type, amount, deadline, and eligibility.
- `data_quality_issues`: Automated discrepancy log tracking stale dates, missing sources, and broken links.

---

## 9. Acceptance Criteria for Phase 1 Release

| ID | Criterion | Verification Method |
|---|---|---|
| **AC-01** | 100% of accessible Pakistani HEC-recognized institutions (267+) and campuses reconciled | Python HEC ingestion CLI + dataset validation |
| **AC-02** | Global university discovery mechanism operational with persistent identifiers (ROR/OpenAlex) | Python global discovery CLI + JSON exports |
| **AC-03** | Idempotent synchronization: re-running sync on unchanged source produces 0 duplicate records and 0 change events | Python sync test suite (`pytest`) |
| **AC-04** | Change detection: simulated upstream update generates structured field diff and routes to review queue | Automated change detector test |
| **AC-05** | Safe failure: simulated 404/500/broken HTML fails cleanly without corrupting database | Resiliency test suite |
| **AC-06** | Mobile app displays Source Provenance, Freshness indicators, and official links on Institution Detail | Android Emulator verification (`emulator-5554`) |
| **AC-07** | Admin Review Console enables approving/rejecting change proposals with side-by-side diffs | Android Emulator verification (`emulator-5554`) |
| **AC-08** | Settings displays Data Freshness & Sync operational diagnostics | Android Emulator verification (`emulator-5554`) |
| **AC-09** | 100% passing automated tests (`flutter analyze` = 0, `flutter test` = 22+, Python tests = 100%) | CI test execution |
| **AC-10** | Zero sensitive PII collected; RLS enabled on all database tables | Security audit |
