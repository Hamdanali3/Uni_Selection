# UniSelection App — Phase 1 Master Scope Document

**Version 1.2 | 13 October 2026 | Status: Proposed baseline for team review**

> This is a proposed Phase 1 scope baseline for team review. It is not a claim that the app, APIs, or datasets already exist.


## 1. Executive Summary

UniSelection is a student-focused mobile platform intended to help users discover universities and academic programmes, understand published admission requirements, compare options, and access official information sources. Phase 1 will deliver a practical Minimum Viable Product (MVP), not the complete long-term vision. The MVP will focus on a verified starter catalogue covering selected Pakistani universities plus a deliberately limited set of international institutions. The scope prioritizes trustworthy information, transparent sources, safe data handling, and a maintainable architecture.


## 2. Product Vision and Objectives

Vision: make university discovery more understandable and organized for students by bringing institution, campus, programme, eligibility, fee, and admission information into one mobile experience.

Phase 1 objectives:
- Deliver an Android-first Flutter mobile application with a clear path to broader platform support.
- Provide university discovery by category, location, programme/discipline, and selected filters.
- Show institution and programme details with source links and last-verified dates.
- Provide a basic eligibility guidance feature using explicit, institution-specific rules where verified data exists.
- Enable users to shortlist and compare institutions.
- Establish a secure backend, manageable database, data verification workflow, API documentation, tests, and team delivery process.
- Include selected international institutions without claiming global coverage.


## 3. Scope Principles and Assumptions

- Phase 1 is an MVP. Features must be complete enough to work end-to-end, rather than appearing as unfinished placeholders.
- Target data coverage is an initial planning target of approximately 20–30 Pakistani institutions and 10–20 international institutions. These are targets, not a claim that the data is already collected or verified.
- Data coverage depends on public availability, permitted use, and verification effort.
- Flutter/Dart is the mobile technology; Android Studio is used for Android tooling and debugging. VS Code may be used as the primary editor.
- Supabase/PostgreSQL is the proposed backend/database platform, subject to a short technical validation during setup.
- Third-party API access is never assumed. An integration is included only when an official, documented, authorized endpoint is actually available.
- The first release is Android-first. iOS may be technically supported by Flutter later, but device testing and release are outside the MVP unless separately agreed.
- The app provides informational guidance, not admission guarantees or official decisions.


## 4. Users and Roles

Student / Guest:
- Browse and search publicly available institution and programme information.
- View details, source links, eligibility notes, and last-verified dates.
- Save a shortlist and compare selected institutions. If cloud sync is not in the MVP, shortlist data may be stored locally.

Registered Student (if authentication is enabled in the first release):
- Maintain a basic profile and preferences.
- Save shortlist data to their account.
- Access only their own private profile and saved data.

Data Editor / Verifier:
- Add or update institution and programme records through a controlled workflow.
- Attach a source URL, source type, verification date, and review status.

Administrator:
- Manage roles, review submitted changes, publish verified data, and inspect audit history.
- Admin access must be restricted; no public client may receive service-role credentials.


## 5. Phase 1 Functional Modules

The following is a proposed module map. Several modules can share implementation components; the count is a planning aid, not a requirement to create a separate service for every item.

M1. Onboarding and App Navigation
- Introductory screens, primary navigation, loading, empty, offline/error and retry states.

M2. Student Profile (basic)
- Optional profile fields such as intended degree level, preferred disciplines, location preferences and academic results where needed for eligibility guidance.
- Explain why information is requested; do not collect unnecessary personal data.

M3. University Directory
- List institutions with canonical IDs, name, country, institution type, official website, and public contact details where verified.

M4. Campus Directory
- Associate campuses with parent institutions; store location and official campus source when available.

M5. Institution Categories and Disciplines
- Configurable categories such as medical/health sciences, engineering, computing/IT, arts/humanities, business, social sciences, general/multidisciplinary and other verified categories.
- Categories and disciplines must be data-driven, not hard-coded into the app.
- An institution can belong to multiple disciplines; do not assume every institution fits only one category.

M6. Programme Catalogue
- Degree level, programme name, discipline, campus availability where verified, duration if verified, and source metadata.

M7. Search and Filters
- Search by institution/programme name; filter by country, city/region, category, discipline, degree level and data availability.
- Show useful empty states and avoid implying results are exhaustive.

M8. Institution and Programme Details
- Structured detail pages, official links, source attribution, verification status and last-checked date.
- Unknown information should be shown as “Not verified / Not available” rather than guessed.

M9. Basic Eligibility Guidance
- Apply only explicit rules captured from reliable official sources.
- Show the rule, required inputs, result, source and caveat.
- If rules are incomplete or programme-specific requirements are unclear, show “Unable to determine—check the official admissions page.”
- Never guarantee admission.

M10. Admission Information
- Publish verified admission dates/status only when a dated official source exists.
- Clearly distinguish a current verified date from an old or unknown date.
- Phase 1 does not promise live admission status for every institution.

M11. Fee Information
- Store fee amount, currency, academic session/year, fee type and source.
- Distinguish tuition from other charges and annual from semester fees.
- Do not compare fees unless their basis is clear.

M12. Shortlist / Favorites
- Save and remove institutions/programmes.
- Decide during implementation whether guest saves are local-only or account-synced; document the selected behavior.

M13. Basic Comparison
- Compare a small number of selected institutions using fields that are available and comparable, such as location, programme, published fee basis and official link.
- Mark missing or non-comparable values clearly.

M14. Admin and Data Review
- Controlled create/update workflow for institutions, campuses, programmes, sources and verification status.
- Draft, in-review, verified, published, needs-update and archived states are recommended.
- Record who changed what and when.

M15. Data Import and Validation
- CSV/Excel import pipeline for approved data templates.
- Validate required columns, URLs, duplicates, IDs, country codes and data types.
- Preview import errors before publication; never silently overwrite verified records.

M16. Backend API and Data Access
- Documented endpoints or Supabase data access patterns for public catalogue, search/filter, details, shortlist/profile (if authenticated), and admin workflows.
- Validate all privileged actions server-side or through correctly protected database policies.

M17. Authentication and Authorization (minimum viable)
- If accounts are enabled, use a supported Supabase Auth method, secure session handling and role-aware access.
- Public browsing should not require an account unless a product decision explicitly changes this.

M18. Notifications Foundation
- Phase 1 may include local/in-app notices or Firebase Cloud Messaging for a narrowly defined use case if setup and testing fit the schedule.
- Push notifications are not required for core discovery to function. Do not promise real-time admission alerts without a verified update process.

M19. Privacy, Security and Audit
- Row Level Security (RLS), least privilege, input validation, secret management, audit records for admin changes, and data minimization.

M20. Analytics and Operational Diagnostics (minimal)
- Collect only necessary, privacy-respecting technical diagnostics. Avoid collecting sensitive profile information in analytics.
- Provide a way to detect failed imports and API errors.

M21. Quality Assurance
- Unit tests for eligibility rules and validation, integration tests for data access, widget/UI tests for critical journeys, and manual acceptance testing.

M22. Documentation and Team Workflow
- README, setup guide, environment variable template, database migrations/schema, API documentation, data dictionary, test instructions, decision log and release checklist.


## 6. Explicit Phase 1 Exclusions

Unless the team approves a scope change, the following are excluded from Phase 1:
- Complete worldwide university coverage.
- A guarantee that every university provides a public API.
- Unapproved scraping, bypassing access controls, or republishing restricted data.
- Automated application submission to universities.
- Visa/legal/immigration advice or guarantees.
- Payment processing, paid counselling marketplace, or agent booking.
- Full AI chatbot, generative AI recommendations, predictive admissions probability, or automated fraud detection.
- Full scholarship matching engine (basic verified scholarship links may be included only if time and data quality allow).
- Guaranteed real-time admission deadlines for all institutions.
- A production-grade web portal or iOS release unless separately prioritized.
- Claims that a student is officially eligible or will be admitted; the tool offers guidance based on published rules only.


## 7. Data Sources and University API Strategy

The product must use a source-first data process. Preferred sources:
1. Official regulator/government institution lists, including HEC Pakistan recognized institutions and recognized campuses pages.
2. Official university and campus websites.
3. Official admission prospectuses, fee schedules and programme pages.
4. Authorized, documented APIs or data feeds where actually offered.
5. Approved institution-supplied spreadsheets or manually verified records.

Reference starting points:
- HEC recognized universities: https://www.hec.gov.pk/english/universities/Pages/recognised.aspx
- HEC recognized campuses: https://www.hec.gov.pk/english/universities/Pages/DAIs/HEC-recognized-Campuses.aspx

API policy:
- Maintain an integration register listing provider, purpose, documentation URL, authentication method, permitted use, rate limits, refresh cadence, owner, and status.
- Do not invent endpoints or assume HEC or individual universities offer a public API.
- If no suitable API exists, use a documented manual/CSV workflow and cite the official page.
- Store source URL, source type, captured/reviewed date, verification status, and reviewer for material facts.
- Respect website terms, copyright, robots/access restrictions, rate limits and privacy requirements.
- Do not store passwords or API secrets in the mobile app or repository.
- Data freshness should be visible. Admission dates and fees must include session/year and should expire or be flagged for review after a configurable interval.
- Keep a “reported/unknown” state rather than filling gaps with estimates.


## 8. Proposed Data Model

Use normalized relational tables and stable IDs. Final names and constraints should be confirmed in migrations before implementation.

- countries: id, ISO code, name.
- regions/cities: id, country_id, name, optional region code.
- institutions: id, canonical name, alternate names, institution type, country_id, official URL, public contact fields, status.
- campuses: id, institution_id, name, city/region, address (only if verified), official URL, status.
- categories: id, slug, display name, description.
- institution_categories: institution_id, category_id (many-to-many).
- disciplines: id, name, parent discipline ID if needed.
- programmes: id, institution_id, optional campus_id, programme name, degree level, discipline_id, duration if verified, status.
- eligibility_rules: id, programme_id, rule type, rule text/structured fields, source_id, effective session, verification status.
- admissions: id, programme_id or institution/campus reference, intake/session, opening date, closing date, status, source_id, verified_at.
- fee_records: id, programme_id or campus reference, fee type, amount, currency, billing period, academic session/year, source_id, verified_at.
- sources: id, source URL, source type, provider, accessed_at, checked_at, notes, usage/permission notes.
- verification_records: id, entity type/id, status, reviewer, reviewed_at, change summary.
- profiles: user_id, minimal preference fields, timestamps (only if accounts are enabled).
- saved_items: user_id or local-only equivalent, entity type/id, created_at.
- admin_audit_log: actor, action, entity, entity_id, timestamp, safe change summary.
- import_jobs/import_errors: file metadata, status, row counts, validation messages, actor and timestamps.

Use foreign keys, uniqueness rules, indexes, check constraints and migrations. Avoid storing multiple unrelated values in a single text field when they need filtering. Define deletion/archive behavior to preserve data integrity.


## 9. API and Integration Requirements

The team should decide between Supabase-generated REST access and a custom backend for each use case. Do not build a separate API server unless it adds value. For Phase 1, a simple, documented API/data-access layer is preferred.

Illustrative logical endpoints (actual routes depend on the implementation):
- GET /institutions?query=&country=&category=&city=&page=
- GET /institutions/{id}
- GET /institutions/{id}/campuses
- GET /programmes?institution_id=&discipline=&degree_level=&query=
- GET /programmes/{id}
- GET /programmes/{id}/eligibility
- GET /admissions?institution_id=&programme_id=&session=
- GET /fees?institution_id=&programme_id=&session=
- GET /categories
- GET /disciplines
- GET /sources/{id} (public source details only)
- POST /admin/import-jobs (admin only, if custom backend is used)
- POST/PATCH /admin/institutions (authorized editor/admin only)
- POST/PATCH /admin/programmes (authorized editor/admin only)
- POST /admin/verification-records (authorized verifier/admin only)
- GET/POST/DELETE /me/saved-items (authenticated user only, if cloud-synced saves are in scope)

These are logical examples, not claims that these routes already exist. Each implemented endpoint must define request/response schema, pagination, filtering, error codes, authentication, authorization and rate limits where applicable. Use consistent errors and avoid exposing internal database details.


## 10. Security, Privacy and Responsible Design

Minimum security controls:
- Enable and test Supabase Row Level Security for every table exposed to client access.
- Deny access by default; grant only required permissions.
- Never ship Supabase service-role keys, private API keys or other secrets in Flutter code or GitHub.
- Use environment-specific configuration and a committed .env.example with placeholders only.
- Validate input on the server/database boundary, not only in the UI.
- Restrict admin functions to authorized roles; log material changes.
- Use HTTPS for remote traffic and supported authentication/session practices.
- Collect only necessary user information; provide a privacy notice and a way to request account/data deletion if accounts are enabled.
- Define backup, restore and incident response basics before pilot use.
- Avoid logging credentials, tokens, private profile fields or sensitive academic data.
- Review third-party SDKs and permissions before adding them.
- Treat eligibility results as informational and link users to official sources.


## 11. Non-Functional Requirements

Usability: clear labels, accessible text contrast, predictable navigation, helpful loading/empty/error states, and no misleading claims of complete coverage.

Performance: pagination for lists, indexed common filters, efficient queries, and agreed response-time targets measured on a representative test dataset. Set numeric targets after a baseline is measured.

Reliability: graceful handling of network failure, retry where safe, and no crash on missing optional data.

Data quality: source attribution for key facts, duplicate detection, consistent country/currency/date formats, and explicit unknown/stale states.

Maintainability: modular Flutter code, typed models, migration-controlled schema changes, documented dependencies and code review.

Localization readiness: use Flutter localization practices and avoid hard-coded text where practical. English may be the initial language; Urdu support should be planned and prioritized explicitly rather than assumed complete.

Compatibility: define and test a minimum Android version and representative device sizes during setup.

Privacy: minimize personal data and keep private records access-controlled.


## 12. Recommended Technical Architecture

Mobile client: Flutter + Dart, developed in VS Code and/or Android Studio.
Backend/data: Supabase with PostgreSQL, Auth if accounts are enabled, Storage only if a real file-upload need is approved, and RLS.
Integration: a source/import layer for authorized APIs and CSV/Excel; scheduled automation only where access, reliability and legal permission are established.
Admin: start with a protected lightweight admin interface or a carefully controlled internal workflow; decide whether to build a separate web dashboard in Phase 1 based on team capacity. A full public web product is out of scope.
Version control: GitHub repository, branch protection/review where available, issues and project board.
Testing: Flutter unit/widget/integration tests, database policy tests and API/data import tests.
Deployment: development and production configuration must be separated. Use a controlled pilot before public launch.


## 13. Suggested Repository Structure

unislection-app/
  mobile/
    lib/
      app/
      core/
      features/
        onboarding/
        profile/
        institutions/
        campuses/
        categories/
        programmes/
        search/
        eligibility/
        admissions/
        fees/
        shortlist/
        comparison/
      shared/
    test/
  backend/
    migrations/
    seed/
    functions/              # only if server-side functions are needed
  data/
    templates/
    validation/
    documentation/
  docs/
    phase-1-master-scope.md
    architecture.md
    data-dictionary.md
    api-contracts.md
    data-source-register.md
    decisions-log.md
    test-plan.md
    release-checklist.md
  .env.example
  .gitignore
  README.md

Adjust this layout to the team's chosen architecture; do not create empty folders solely to match the example.


## 14. Team Roles and Governance

Member A — Product/Architecture/Flutter integration: own the scope, technical decisions, navigation integration, Supabase setup coordination and release readiness.
Member B — Flutter UI/UX: screens, navigation, responsive layouts, loading/error/empty states and UI tests.
Member C — Data/backend: schema, migrations, policies, API/data-access contracts, import validation, admin workflow and source verification.

Shared responsibilities: code reviews, testing, documentation, issue tracking, acceptance criteria and demo reviews. Assign one owner to every task. Use pull requests rather than directly overwriting shared code. Record scope changes and their effect on time, cost and quality.


## 15. Phase 1 Work Breakdown and Sequence

Sprint 0 — Discovery and setup:
- Confirm target users, initial country/institution list, Android minimum version and language plan.
- Create GitHub repository, issue board, branching rules and documentation.
- Validate Flutter/Supabase choices with a small technical spike.
- Create source register and institution data template.

Sprint 1 — Foundation:
- Flutter project skeleton, navigation and design tokens.
- Supabase project environments, schema draft, migrations and RLS baseline.
- Define common models, error handling and API/data access contracts.

Sprint 2 — Catalogue and data:
- Implement institution, campus, category, discipline and programme schema.
- Import a small sample dataset and validate duplicates/missing sources.
- Build list, detail, search and filter flows.

Sprint 3 — Student features:
- Basic profile/preferences if required.
- Eligibility guidance for a small number of rules that can be reliably encoded.
- Shortlist and basic comparison.
- Admission and fee information with clear source/session fields.

Sprint 4 — Admin, security and quality:
- Complete verification and controlled publishing workflow.
- Add CSV validation/import reporting.
- Test RLS, roles, error handling, offline/network states and critical journeys.
- Fix defects and review privacy/security.

Sprint 5 — Pilot and release candidate:
- Populate the agreed starter dataset.
- Run acceptance tests with representative users.
- Prepare app build, known-issues list, setup instructions and release notes.
- Hold a go/no-go review against the acceptance checklist.

Sprint lengths should be decided by the team after estimating the work; these sprint labels are sequencing guidance, not a promise of delivery dates.


## 16. Phase 1 Acceptance Criteria

Phase 1 can be accepted when:
1. The app builds and launches on the agreed Android test devices.
2. A user can browse institution records, open details, search and apply agreed filters.
3. Categories and disciplines are managed as data, and institutions can be associated with multiple categories.
4. Programme details show only supported facts and link to their sources.
5. Eligibility guidance is tested against agreed example cases and clearly states its limitations.
6. Fee/admission records include session/date context and source metadata when shown.
7. Shortlist and comparison work according to the documented guest/account behavior.
8. Data editors can add/update records through the approved workflow; publication requires the defined verification step.
9. Import validation detects invalid rows and reports errors without silently corrupting verified data.
10. Database policies prevent unauthorized access; privileged keys are not present in the client or repository.
11. Critical user journeys and data rules have automated and/or documented tests.
12. README, setup guide, schema/migrations, API contracts, data dictionary, source register, test results and known issues are in GitHub.
13. The agreed starter dataset meets the team's defined completeness and verification threshold.
14. Product limitations and non-covered institutions are clearly communicated to users.


## 17. Risks and Mitigations

Risk: no public API or unstable website. Mitigation: use source register, manual/CSV fallback and avoid promising automated synchronization.
Risk: fees/deadlines become outdated. Mitigation: session/year fields, reviewed-at dates, expiry/review queue and clear stale labels.
Risk: conflicting information. Mitigation: source hierarchy, verifier workflow and change history.
Risk: overlarge MVP. Mitigation: freeze a must-have list, move optional features to backlog and require impact review for scope changes.
Risk: insecure database rules. Mitigation: deny-by-default RLS, policy tests and no service-role key in client.
Risk: inaccurate eligibility. Mitigation: rule source, effective session, test cases, caveat and official link.
Risk: team integration conflicts. Mitigation: module ownership, agreed contracts, small PRs and regular integration builds.
Risk: unclear data-use permissions. Mitigation: review terms/licensing and avoid restricted collection or republishing.


## 18. Decisions Required Before Development

The team should record decisions for:
- Exact MVP institution list and target countries.
- Whether accounts are required or browsing is guest-first.
- Whether shortlist is local-only or cloud-synced in the first release.
- English-only launch versus Urdu localization.
- Whether a separate admin web dashboard is required in Phase 1 or a protected internal workflow is sufficient.
- Minimum Android version and device test matrix.
- Data refresh frequency and ownership.
- Whether Firebase Cloud Messaging is truly needed for MVP.
- Privacy policy/account deletion approach if accounts are enabled.
- Initial acceptance threshold for source verification and data completeness.

Unresolved decisions should be marked “Open” in the decision log; they must not be silently treated as settled.


## 19. Project Logging and Documentation

Maintain these version-controlled records:
- Master scope and change history.
- Architecture decision records (ADRs).
- Task board with owner, priority, status and acceptance criteria.
- Data source/API register.
- Data dictionary and schema migrations.
- API contracts and error conventions.
- Verification log and import reports.
- Test plan, results and known defects.
- Meeting/decision log with date, decision, rationale, owner and follow-up.
- Release checklist and build instructions.

This document does not automatically save every chat message or guarantee that chat history is exported. The team should deliberately copy project decisions and action items into the version-controlled project log after each working session.


## 20. Official Reference Starting Points

- HEC recognized universities: https://www.hec.gov.pk/english/universities/Pages/recognised.aspx
- HEC recognized campuses: https://www.hec.gov.pk/english/universities/Pages/DAIs/HEC-recognized-Campuses.aspx
- Flutter documentation: https://docs.flutter.dev/
- Dart documentation: https://dart.dev/guides
- Supabase documentation: https://supabase.com/docs
- PostgreSQL documentation: https://www.postgresql.org/docs/
- Android Developers: https://developer.android.com/
- Firebase Cloud Messaging documentation (only if push notifications are adopted): https://firebase.google.com/docs/cloud-messaging

These are starting points for implementation. The team must verify current provider documentation, terms, access methods and API availability at the time each integration is built.


## 21. Approval and Change Control

Document owner: UniSelection project team.
Baseline: Version 1.2 proposed for team review.
Approval: team members review scope, open decisions and acceptance criteria before implementation starts.
Change process: record requested change, reason, affected modules, estimated effort, risk, revised milestone and approval. Update the version and change log after approval.
Definition of done: code reviewed, tests passed, source/data checks completed where applicable, documentation updated and merged to the agreed branch.


## 22. Screen Inventory and Core User Journeys

The first release should have a focused screen set. Screens may be implemented as pages or reusable views, depending on the chosen Flutter architecture.

- **Splash / app initialization:** checks configuration and routes the user to the correct starting state.
- **National / International choice:** clearly separates Pakistani institutions from international institutions while allowing users to switch later.
- **Home / Discover:** search entry point, categories, popular disciplines and carefully labelled featured content.
- **Institution list:** paginated results with filters for country, city/region, category and institution type.
- **Search and filter panel:** query, degree level, discipline and data-availability filters; filters should be accessible and resettable.
- **Institution detail:** official website, location, category, campus list, verified facts, source links and last-checked date.
- **Campus detail (when useful):** campus-specific location and official source.
- **Programme list and programme detail:** degree level, discipline, duration, eligibility notes and source.
- **Eligibility guidance:** input form, rule-based result, explanation, caveat and official source link.
- **Admission and fees:** academic session, dates, currency, fee type, verification status and source.
- **Shortlist:** saved institutions/programmes with remove and empty states.
- **Compare:** side-by-side comparison for supported fields, with missing values explicitly marked.
- **Student profile/preferences (if account/profile is enabled):** intended degree level, disciplines and preferences, with edit and privacy information.
- **Sign in / account recovery (only if authentication is included in the first release).**
- **Settings / About / Privacy:** app version, source policy, privacy notice, feedback/contact route and data limitations.
- **Admin review interface:** restricted screens or internal workflow for drafts, source checks, imports, verification and publishing.

Critical journeys to test: choose National or International → search/filter → open institution → open programme → inspect eligibility/source; and open institution → shortlist → compare. A student must still be able to browse public records without creating an account if guest-first access is selected.

## 23. Release Checklist and Definition of Ready

**Before development starts:**
- Team has reviewed this scope, recorded open decisions, selected the initial institution list and assigned owners.
- Flutter SDK, Android tooling, repository access and local setup instructions have been verified on each developer machine.
- Supabase environments, migration approach, role model and RLS test plan are agreed.
- Initial data template, source register and verification rules are approved.

**Before a pilot build:**
- All P0 acceptance criteria in Section 16 pass; unresolved defects are recorded and triaged.
- No secret keys or private credentials are committed; database policies are tested with anonymous, student and admin roles as applicable.
- Search, details, categories, eligibility guidance, shortlist and comparison have been tested on representative devices.
- Each displayed admission date and fee has an academic session/year and source context, or is clearly marked unavailable/unverified.
- Accessibility basics, loading/empty/error states, network failure behavior and data freshness labels are reviewed.
- Privacy notice, support/feedback path, known limitations and source attribution are visible.
- Build version, release notes, test results, rollback/disable plan and responsible release owner are documented.

**Definition of Ready:** user story, acceptance criteria, data/source dependencies, design state, security implications and owner are documented before implementation begins.

**Definition of Done:** code reviewed and merged, tests pass, errors and edge cases handled, documentation updated, and acceptance criteria demonstrated.
