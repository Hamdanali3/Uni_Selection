# UniSelection — Phase 2 Master Scope
**Version:** 1.0  
**Status:** Draft for team review and approval  
**Project:** UniSelection — Higher Education Discovery & Admissions Guidance Platform  
**Repository:** https://github.com/Hamdanali3/Uni_Selection  
**Phase 1 reference:** `UniSelection_Phase_1_Master_Scope_v1.3.md` and `AllAboutPhase1.md`  
**Primary client:** Flutter Android application  
**Backend/data direction:** Existing Flutter architecture and PostgreSQL/Supabase direction, subject to repository verification  
**Audience:** Product owner, project manager, mobile/backend/data engineers, QA, security reviewer, data editors

> **Baseline rule:** This document defines intended Phase 2 scope. It does not prove that any feature already exists or that a test has passed. Before implementation, the team must inspect the current repository, deployment configuration, database migrations, source data, and actual test outputs. Any discrepancy between this document and the codebase must be recorded, not silently assumed away.

---

## 1. Executive Summary

Phase 2 turns UniSelection from a Phase 1 discovery, directory, comparison, eligibility-guidance, and data-intelligence foundation into a more useful admissions-planning product. It focuses on **actionable scholarship discovery, richer eligibility assessment, transparent recommendations, application planning, reliable reminders, broader verified institution/programme coverage, cloud-backed discrepancy review, scheduled data synchronization, and operational quality**.

Phase 2 must preserve the core principles documented for Phase 1:

1. **Zero fabricated data:** Never invent a university, programme, accreditation, fee, scholarship, admission date, visa rule, or official contact.
2. **Traceable claims:** Display the source URL, source owner/authority, last-checked timestamp, and verification status for changeable claims.
3. **Guest-first exploration:** Directory, search, compare, and basic guidance must not require registration unless an explicitly approved feature requires an account.
4. **Data minimization:** Do not collect CNIC, passport, bank statements, transcripts, or other sensitive documents in Phase 2 unless a separate, approved privacy/security design explicitly authorizes it.
5. **Human review for consequential data:** Critical regulatory status and high-impact financial/deadline changes must not be auto-published merely because a connector detected them.
6. **Accessible and honest guidance:** Eligibility and recommendation results are guidance, not admission guarantees.
7. **Incremental, testable delivery:** Phase 2 must not destabilize the Phase 1 M1–M23 baseline.

## 2. Product Context and Phase Boundaries

### 2.1 Phase 1 baseline to preserve

`AllAboutPhase1.md` describes M1–M22 plus M23 Global Data Intelligence & Synchronization, including:
- National/international scope selection and onboarding.
- Basic local student preferences/profile.
- Institution and campus directory; discipline categories and programme catalogue.
- Search, filters, institution/programme details, admissions, fee information.
- Basic aggregate-percentage eligibility guidance.
- Local shortlist/bookmarks and comparison.
- Admin review workflow and data import/validation.
- PostgreSQL/Supabase-oriented data access, guest-first access, and role-based admin gates.
- Privacy/security notices and operational diagnostics.
- Python synchronization concepts: source connectors, normalization, deduplication, field-level change detection, quality checks, idempotency, safe failure, and human-in-the-loop review.
- Scholarships data model/tab and student discrepancy-reporting UI are described in the Phase 1 compendium; their production/cloud completeness must be verified rather than presumed.

The compendium reports 284 institution records (266 Pakistan, 18 international), 11 campuses, 14 programmes, 14 eligibility rules, 5 admission cycles, and 14 fee structures. These are **reported Phase 1 figures, not an independent guarantee of current completeness or correctness**. Phase 2 should improve verified coverage and data depth instead of presenting record count alone as quality.

### 2.2 Phase 2 outcomes

By Phase 2 closure, a student should be able to:
- Explore relevant institutions/programmes and see where information came from.
- Discover scholarships/financial aid and understand their published eligibility, coverage, deadline, and application route.
- Receive a more informative, rule-based eligibility assessment with missing-data and uncertainty handling.
- Get transparent, explainable recommendations based on stated preferences and published facts.
- Save a shortlist and manage an application plan with deadlines and reminders.
- Report a suspected data issue and have it reach a secure review workflow.
- Receive timely reminders only where permissions and notification settings allow.
- Explore a carefully bounded set of international opportunities with source-attributed admissions and country/visa guidance, without treating visa information as legal advice.
- Benefit from more reliable data synchronization, review, monitoring, and release operations.

### 2.3 Out of scope for Phase 2 unless separately approved

- A generative AI education/admissions assistant that answers open-ended questions from arbitrary sources.
- Unexplained or opaque machine-learning admissions predictions.
- Automated admission applications, application submission, or impersonation on university portals.
- Collection/storage of passports, CNICs, bank statements, transcripts, or full application-document uploads.
- Visa approval predictions, legal advice, or guaranteed immigration outcomes.
- Paid subscriptions, advertisements, marketplace payments, or escrow.
- Full web/iOS product parity unless the team explicitly changes platform priorities.
- Nationwide claims that every university/programme/scholarship has complete data before coverage audits support that claim.
- Unapproved third-party scraping, access-control bypass, or high-rate crawling.

These are candidate Phase 3 or separately scoped items, not hidden Phase 2 requirements.

## 3. Users and Key Journeys

### 3.1 Primary user groups
1. Pakistani intermediate/FSc/A-Level students choosing a BS programme.
2. Current students and graduates exploring MS/MPhil/PhD options.
3. Pakistani students comparing local and selected international opportunities.
4. Students searching for scholarships/financial aid.
5. Editorial/admin reviewers responsible for trustworthy public information.

### 3.2 Core journeys
- **Discover:** Open app as guest → select national/international scope → search/filter → view institution → inspect programmes, fees, admissions, sources, and freshness.
- **Assess:** Enter only necessary academic facts → select programme/institution → receive eligible / potentially eligible / not currently eligible / insufficient information result with explanation.
- **Find aid:** Set degree level, discipline, destination, and relevant non-sensitive preferences → browse matching scholarships → inspect criteria, coverage, deadline, official link, and source.
- **Plan application:** Save institution/programme/scholarship → add application tasks and deadlines → receive opt-in reminders → mark tasks complete.
- **Compare and decide:** Shortlist options → compare normalized attributes → inspect data gaps and source freshness → make an informed choice.
- **Report a discrepancy:** Open institution detail → report incorrect field and observed value with optional official evidence URL → receive submission status → editor reviews and records decision.
- **International exploration:** Choose country/degree level → inspect selected verified institutions → view official admissions and scholarship sources → see last-checked country/visa guidance and explicit disclaimer.
- **Admin review:** Authenticate with authorized role → inspect queued changes/reports → compare old/new/source → approve/reject/request clarification → audit trail records who changed what and when.

## 4. Prioritization and Delivery Plan

Priority definitions:
- **P0 — Required for Phase 2 closure:** Must pass acceptance criteria.
- **P1 — Important:** Implement if it fits the agreed release capacity; if deferred, document owner, rationale, and target phase.
- **P2 — Optional enhancement:** Do not block Phase 2 closure unless promoted by team decision.

### Suggested increments
1. **Increment A — Audit and hardening:** Establish verified Phase 1 baseline; database/security review; data contracts; migration and test baselines.
2. **Increment B — Aid and eligibility:** Scholarship Finder, expanded eligibility rules, missing-data treatment, official-source display.
3. **Increment C — Decision support:** Recommendation scoring, shortlist/compare improvements, preferences.
4. **Increment D — Application planning:** Application tracker, calendar, notification preferences and local/push reminder implementation.
5. **Increment E — Data operations:** Cloud discrepancy reports, editor queue, scheduled sync, data-quality dashboards and safe-failure/idempotency tests.
6. **Increment F — Bounded international coverage:** Prioritized countries/institutions and official admissions/visa-source pages.
7. **Increment G — Release readiness:** accessibility, privacy/security, regression, performance, documentation, release candidate and pilot feedback.

The team may change the sequence after the initial audit, but must preserve dependencies and record the decision.

## 5. Functional Modules

### P0-01 — Scholarship and Financial Aid Finder

**Purpose:** Help users discover relevant, verifiable financial aid without implying that funding is guaranteed.

**Requirements**
- Provide searchable/filterable scholarship listings by institution, degree level, discipline, country/destination, coverage type, deadline status, and eligible applicant category where verified.
- Each scholarship record should support: stable ID; official name; provider; associated institution(s), if applicable; country; degree levels; disciplines; eligibility criteria; coverage type (full/partial/tuition/stipend/fee waiver/other); currency/amount only if explicitly sourced; deadline or application window; official application URL; official source URL; last checked; status; language/notes; and editorial verification status.
- Distinguish “no deadline published,” “deadline passed,” “upcoming,” and “date not verified.” Never convert missing dates into invented dates.
- Show the official source and last-checked date prominently.
- If the user’s profile does not contain enough facts to assess a criterion, show “Not enough information”; do not assume the criterion is satisfied.
- Allow saving scholarships to a shortlist/application plan.
- Use clear empty, loading, offline, stale-data, and error states.
- Where no reliable data is available, show official financial-aid portal links rather than fabricated scholarship records.

**Security/data**
- Public users can read published scholarships only.
- Only authorized editors can create/update/publish records.
- Validate URLs, lengths, dates, enumerations, relationships, and source metadata.
- Avoid storing sensitive documents or financial account data.

**Acceptance criteria**
- Search and filters work together and can be cleared.
- Every published record has a valid official source URL and a visible verification/freshness state.
- Missing or expired dates are rendered accurately.
- Tests cover full/partial aid, missing criteria, passed deadlines, no deadline, invalid URL, duplicate record, and empty results.
- Unpublished or review-pending records are never shown as verified public records.

### P0-02 — Advanced Eligibility Assessment

**Purpose:** Extend the Phase 1 percentage calculator into a transparent rule-based evaluator.

**Requirements**
- Support programme-specific published requirements where verified: minimum aggregate/marks, required subjects, degree level, entry test requirements, domicile/residency constraints, and other criteria only when an authoritative source exists.
- Represent criteria as structured rules with source, applicability period/admission cycle, required/optional status, and verification state.
- Return one of: **Meets listed criteria**, **May meet criteria — manual confirmation required**, **Does not meet one or more listed criteria**, or **Insufficient verified information**.
- Explain each criterion as pass / fail / unknown and show the source for the rule.
- Separate arithmetic calculations from official admissions decisions.
- Handle boundary values, absent marks, different scales, rounding, and invalid input deterministically.
- Never assume equivalence between grading systems without an explicit approved conversion rule.
- Allow users to revise inputs and compare multiple programmes.
- Include a prominent disclaimer that universities may change rules and only the institution can confirm eligibility.

**Acceptance criteria**
- Unit tests cover exact threshold, above/below threshold, missing rule, missing student value, invalid values, multiple criteria, conflicting/expired rules, and different scales.
- Unknown criteria never silently count as passed.
- Every decisive published rule has source and applicable cycle/freshness metadata.
- UI explains why a result was produced and what must be confirmed manually.

### P0-03 — Transparent Personalized Recommendations

**Purpose:** Rank options against user-selected preferences without presenting recommendations as guarantees.

**Requirements**
- Use a documented, deterministic baseline scoring model first; no black-box AI required.
- Potential signals: selected degree level, discipline, preferred city/country, public/private preference, tuition range where verified, programme availability, eligibility status, scholarship availability, and user-selected priorities.
- Let users select or adjust priority weights where practical.
- Explain each recommendation with “Why this is shown” factors and clearly identify missing information.
- Do not use protected or sensitive characteristics to rank students or institutions.
- Do not infer personal attributes from name, location, religion, ethnicity, gender, or other sensitive proxies.
- Exclude institutions/programmes that fail hard constraints only when those constraints are explicitly selected or objectively required; otherwise show them with a warning.
- Keep ranking stable and testable for the same inputs/data version.

**Acceptance criteria**
- Scoring formula and tie-break rules are documented.
- Tests prove that changing a preference changes ranking predictably.
- Missing tuition/eligibility data is shown as unknown, not as free/eligible.
- Every recommendation includes a concise explanation and a route to the underlying source data.
- No claim such as “you will get admission” or “best university for you” without a qualified explanation.

### P0-04 — Application Planner and Tracker

**Purpose:** Let students organize applications without submitting them on the user's behalf.

**Requirements**
- Users can create an application plan for an institution/programme and optionally associate a scholarship.
- Track stages such as Interested, Researching, Preparing, Ready to Apply, Submitted (user-reported), Decision Received, Accepted, Rejected, Withdrawn. Explain that submitted/decision statuses are user-entered, not verified by UniSelection.
- Provide editable tasks/checklists with title, due date, completion status, optional note, and official reference link.
- Allow users to remove/export their plan and understand where data is stored.
- Prefer local storage for guest plans; if cloud sync is introduced, require explicit opt-in, authentication, access controls, deletion behavior, and privacy notice.
- Do not upload documents in Phase 2.
- Do not scrape or automate university application submission.

**Acceptance criteria**
- Create, edit, complete, reopen, and delete flows work.
- Data persists according to the stated storage model and survives app restart.
- Guest/local data is not accidentally sent to backend logs or analytics.
- Dates use the device timezone for display and are stored consistently.
- Deletion behavior is tested and documented.

### P0-05 — Admissions Calendar and Deadline View

**Requirements**
- Consolidate verified application deadlines from institution/programme/admission-cycle records.
- Offer calendar/list views, filters, and upcoming/past/unknown states.
- Identify the source and admission cycle for each deadline.
- Avoid presenting historical deadlines as current.
- Allow a user to add a personal deadline to their plan, clearly distinguishing personal entries from official dates.
- Handle timezone and date-only semantics consistently.

**Acceptance criteria**
- Upcoming, past, missing, and unverified dates display distinctly.
- Calendar and list views show the same records.
- No unsupported date is generated from an approximate academic calendar.
- Tests cover timezone boundaries, same-day deadlines, and empty calendars.

### P0-06 — Reminder and Notification System

**Requirements**
- Support configurable reminders for saved applications, tasks, scholarships, and deadlines.
- Initial implementation may use local notifications; remote push must only be added if backend/provider setup, consent, token lifecycle, and delivery tests are completed.
- Default reminder schedule should be configurable (suggested default: 7 days before, with optional 3 days/1 day/day-of reminders).
- Users can disable all notifications, customize categories, and revoke permission.
- Notification content must be accurate, non-alarming, and link to the relevant detail screen.
- Do not send reminders for stale/unverified deadlines without clearly marking the uncertainty.
- Handle duplicate scheduling, edited deadlines, deleted plans, timezone changes, and permission denial.

**Acceptance criteria**
- Each notification maps to a real saved item/deadline.
- Changing or deleting a deadline updates/cancels scheduled reminders.
- Permission-denied state degrades gracefully.
- Tests cover duplicate prevention, rescheduling, cancellation, timezone handling, and opt-out.
- Push notification claims are not made unless end-to-end delivery is proven.

### P0-07 — Shortlist and Comparison Improvements

**Requirements**
- Preserve Phase 1 local bookmark functionality.
- Add scholarships and programme-level items to shortlist where data model permits.
- Compare a maximum of four institutions/programmes unless usability testing justifies a change.
- Compare only normalized, meaningful fields: location, sector, available programmes, published fee/currency/period, admission status/deadline, accreditation/recognition source, scholarship links, and data freshness.
- Distinguish “not available” from zero, free, not applicable, or not recognized.
- Show side-by-side source/freshness indicators and avoid misleading comparisons across different currencies, years, or fee periods.
- Provide clear removal and empty states.

**Acceptance criteria**
- Existing Phase 1 shortlist and comparison journeys remain functional.
- Incompatible fee periods/currencies are not compared as if equivalent.
- Missing data is labelled explicitly.
- Regression tests cover four-item limit, add/remove, offline persistence, and stale values.

### P0-08 — Student Data Discrepancy Reporting (Cloud-Backed)

**Requirements**
- Extend the Phase 1 discrepancy-report UI into a reliable, secure submission and review lifecycle.
- A report includes target record, field/category, observed value or description, optional official evidence URL, submitted timestamp, status, and reviewer notes. Avoid collecting unnecessary personal details.
- Anonymous/guest reporting may be allowed with rate limits and abuse controls; if authentication is required, explain why.
- Store submissions in a dedicated backend table or approved equivalent; do not expose reports publicly.
- Status lifecycle: Submitted → In Review → Accepted / Rejected / Needs More Evidence / Duplicate.
- Accepted reports create a proposed change; they do not automatically override high-risk fields.
- Add rate limiting, input validation, URL validation, spam/abuse handling, and audit events.
- Provide the user with a safe confirmation/reference ID if feasible, without exposing internal admin data.

**Acceptance criteria**
- A valid report reaches the backend and appears in the authorized review queue.
- Anonymous users cannot read other users’ reports or reviewer notes.
- Rejected/duplicate reports remain auditable.
- Critical/high-impact values require human review.
- Offline failure is explicit; reports are not falsely shown as submitted when no server acknowledgement exists.

### P0-09 — Editorial/Admin Review and Governance

**Requirements**
- Secure admin/editor access using server-enforced authorization, not UI-only role checks.
- Separate roles where needed: read-only auditor, editor, reviewer, administrator.
- Review queue supports filters, old/new diff, source evidence, severity, submitter report context, decision notes, timestamps, and actor identity.
- Require reason/note for consequential approve/reject actions.
- Use server-side validation and transaction-safe updates.
- Preserve audit history for changes to accreditation, recognition, legal name, sector, tuition, deadlines, and scholarship eligibility.
- Do not allow a normal mobile client to bypass review policies by calling the database/API directly.
- Provide safe pagination and bounded query sizes.

**Acceptance criteria**
- Security tests demonstrate that unauthorized users cannot create/publish changes or access private reports.
- Every consequential decision produces an audit record.
- Rejected proposals do not mutate published values.
- Approved proposals update the intended record only, with transaction/rollback coverage.
- UI shows server-confirmed state rather than optimistic success alone.

### P0-10 — Scheduled Data Synchronization and Change Detection

**Requirements**
- Build on the Phase 1 M23 Python sync architecture only after reviewing actual implementation and source legality.
- Schedule approved connectors (e.g., HEC public directory and ROR where appropriate) via a suitable runner such as GitHub Actions or a managed scheduled function. Choose one based on secrets handling, logs, runtime, reliability, and cost.
- Use a documented schedule; suggested baseline is weekly automated checks for suitable sources and monthly statutory audit checks, adjusted to source policy and rate limits.
- Add retry/backoff for transient errors, explicit timeouts, bounded concurrency, user-agent/contact policy, and rate limits.
- Ensure idempotency: unchanged upstream data creates no unintended mutations or duplicate change events.
- Normalize and deduplicate candidates; preserve unmatched existing records; never delete published data solely because a source temporarily omitted it.
- Critical regulatory changes and high-impact fees/deadlines must be staged for human review.
- Record sync run status, source, timestamps, records discovered/updated, proposed changes, errors, and checksum where appropriate.
- Support dry-run mode and safe rollback on failed validation.
- Never bypass authentication, CAPTCHA, robots restrictions, paywalls, or explicit site restrictions.

**Acceptance criteria**
- Repeated sync against unchanged fixtures/source data is idempotent.
- A simulated timeout/HTTP error does not corrupt the baseline.
- Invalid or suspicious changes are staged or rejected according to policy.
- Duplicate candidates do not create duplicate institutions.
- Sync schedule, secrets, logs, and failure notifications are documented.
- A live source run is only called verified if its logs are actually captured.

### P0-11 — Data Quality, Coverage and Freshness Dashboard

**Requirements**
- Provide internal metrics for coverage and quality, including records by country/region/sector, programme depth, verified source rate, stale/missing source fields, broken URLs, duplicate candidates, unresolved proposals, and last successful sync.
- Report counts and denominators clearly. Do not label a record “100% verified” merely because a confidence field defaults to 1.0.
- Separate data presence, source citation, editorial verification, freshness, and legal recognition.
- Add threshold alerts for sync failure, unusual record count changes, broken-source spikes, or growing review backlog.
- Public-facing diagnostics must not expose secrets, internal endpoints, personal reports, or private reviewer information.

**Acceptance criteria**
- Dashboard metrics are derived from real records and have documented definitions.
- Counts reconcile with database queries.
- Stale/missing data is visible and does not silently appear fully verified.
- Alerts can be tested with controlled failure fixtures.

### P0-12 — Bounded International Admissions and Country Guidance

**Requirements**
- Select a bounded initial set of destination countries based on team capacity and student value; record the approved list before implementation.
- For each included country, provide source-attributed general admissions steps, common document checklist, degree-level differences, language/test requirements only when verified, scholarship links, official university portals, and relevant official immigration/visa authority links.
- Distinguish university requirements from country-level visa requirements.
- State clearly that rules change and official government/university pages control.
- Do not provide visa eligibility guarantees or legal advice.
- Do not infer or invent processing times, financial thresholds, work rights, or visa success probabilities.
- Keep the initial data structured so more countries can be added later without duplicating UI logic.

**Acceptance criteria**
- Each published country guide has an official government/immigration source and last-checked timestamp.
- University admission requirements link to the relevant university source.
- Missing or conflicting information is marked for review.
- Tests verify country routing, empty states, and correct separation of admissions vs visa guidance.

### P1-13 — Institution, Campus and Programme Coverage Expansion

**Requirements**
- Expand coverage based on a documented prioritization strategy, not record count alone.
- Use HEC or the relevant official statutory body for recognition claims; a global registry such as ROR can identify organizations but must not be treated as proof of programme accreditation or admission availability.
- Expand campuses only when parent relationships, official location, and evidence are sufficiently reliable.
- Add programme-level detail progressively: degree level, discipline, duration, entry requirements, fee period/currency, admissions cycle, official source.
- Maintain a coverage matrix showing which fields are verified for each institution and region.
- Preserve distinct institutions with similar names and prevent unsafe fuzzy merges.
- Include manual editorial review for ambiguous legal names, mergers, campuses, and recognition status.

**Acceptance criteria**
- Every new record passes schema/relationship/URL validation.
- No institution is labelled HEC-recognized based solely on a general global registry.
- Sampled records are checked against official sources.
- Coverage report identifies gaps and confidence/freshness honestly.

### P1-14 — Profile and Preference Controls

**Requirements**
- Keep profile fields limited to what improves filtering/recommendation/eligibility.
- Let users edit or clear preferences and reset personalization.
- Clearly label local-only versus cloud-synced data.
- No CNIC/passport upload or sensitive demographic inference.
- If account/cloud sync is added, define consent, data retention, export, deletion, and access rules.

**Acceptance criteria**
- Clearing preferences removes them from the relevant local/cloud store.
- No preference data is sent to analytics without disclosed purpose and appropriate consent.
- Privacy copy matches actual data flows.

### P1-15 — Accessibility, UX, Localization and Performance

**Requirements**
- Support accessible text scaling, screen-reader labels, semantic controls, adequate contrast, keyboard/focus behavior where relevant, and touch target sizing.
- Maintain consistent Material 3 patterns and clear error/loading/empty/offline states.
- Keep the interface understandable for first-time applicants; explain terms such as accreditation, aggregate, tuition period, and eligibility.
- Urdu localization may be planned or implemented only with a reviewable translation workflow; do not ship machine-translated legal/admissions wording without review.
- Optimize long lists with pagination/lazy loading and avoid unnecessary repeated network calls.
- Do not block basic browsing on authentication or network connectivity.

**Acceptance criteria**
- Accessibility review is completed for core journeys.
- No critical overflow/crash on supported screen sizes.
- Search/list/detail screens meet agreed performance budgets on representative devices.
- Offline/slow-network behavior is tested.

### P0-16 — Security, Privacy and Reliability

**Requirements**
- Review database schema, Row Level Security (RLS), API policies, auth configuration, storage permissions, environment variables, secrets, and logs.
- Keep service-role keys and privileged secrets out of mobile apps, source control, screenshots, and logs.
- Enforce authorization at the backend/database layer.
- Use least privilege, input validation, rate limits, secure transport, dependency review, and safe error messages.
- Define retention/deletion for discrepancy reports and any optional account/profile data.
- Avoid collecting sensitive personal documents in Phase 2.
- Add backup/restore and migration rollback/recovery procedures for the chosen backend.
- Treat all external source text and URLs as untrusted input.
- Document threat model and incident/contact process appropriate to pilot scale.

**Acceptance criteria**
- RLS tests cover anonymous, authenticated student, editor, reviewer, and admin access paths where those roles exist.
- No privileged secret is present in the Flutter bundle or public repository.
- Data deletion and retention behavior is documented and tested.
- Dependency/security scan results are reviewed; critical unresolved issues block release.
- Backup/restore procedure is tested in a non-production environment.

### P0-17 — Testing, CI/CD and Release Operations

**Requirements**
- Preserve and rerun Phase 1 Flutter analysis/tests, Python tests, data validation, and sync CLI scenarios.
- Add tests for each Phase 2 module at unit, widget, integration, API/RLS, and end-to-end levels appropriate to risk.
- Add CI workflow for formatting/linting, Flutter tests/build, Python tests, schema/data validation, and migration checks.
- Keep fixtures deterministic and do not make unit tests depend on live websites.
- Separate test/staging/production configuration and credentials.
- Capture actual command output and commit/build identifiers in release evidence.
- Conduct a pilot with a defined group, feedback process, defect severity, and rollback plan.
- Document release notes, known limitations, support/contact path, and production data update policy.

**Acceptance criteria**
- CI is reproducible from a clean checkout using documented prerequisites.
- No release decision is based solely on a README assertion or generated report.
- Core journeys pass on a real or representative Android device/emulator.
- High-severity bugs have no unresolved blockers.
- A release candidate can be built with environment-specific secrets excluded from the artifact.

### P1-18 — Privacy-Preserving Product Analytics

**Requirements**
- Use only minimal aggregate events needed to understand feature reliability and adoption.
- Do not log academic scores, detailed profile values, scholarship applications, personal report text, precise location, or sensitive data unless separately approved and necessary.
- Document event names, purposes, retention, opt-out, and access.
- Prefer privacy-preserving aggregate measurements over individual profiling.

**Acceptance criteria**
- Analytics events are documented and reviewed.
- Sensitive fields are absent from event payloads and logs.
- Opt-out behavior is honored where applicable.

## 6. Shared Data and API Requirements

### 6.1 Source/provenance fields
For published changeable data, use a consistent model where applicable:
- `source_id` / source name
- `source_url`
- `last_checked_at`
- `verification_status` (for example draft, in_review, verified, stale, rejected)
- `confidence_score` only if its calculation is documented
- `valid_from` / `valid_until` or admission-cycle applicability where appropriate
- editor/reviewer identity and audit timestamps for changes

Do not conflate a source citation with independent verification or statutory accreditation.

### 6.2 API and repository behavior
- Use repository/service abstractions rather than embedding database calls throughout widgets.
- Handle loading, empty, offline, timeout, unauthorized, validation, and server-error states distinctly.
- Use pagination and bounded query sizes for growing datasets.
- Validate input on both client and server.
- Avoid logging credentials, personal reports, or sensitive profile data.
- Keep offline fallback behavior explicit and visible; do not present stale seed data as live data.

### 6.3 Suggested entities to review/add
Actual schema must be determined by auditing current migrations first. Candidate entities include:
- scholarships and scholarship eligibility/source records
- application plans and tasks (local-only first unless cloud sync is approved)
- notification preferences/scheduled reminder identifiers
- discrepancy reports and report status history
- data source/sync runs/change events (likely present in Phase 1 M23; verify)
- recommendation preferences or reproducible score inputs if persistence is needed
- country guidance/source checks
- audit events and editor review decisions

Use migrations that are backward-compatible where practical. Never rename/drop existing tables or columns without an explicit migration and rollback strategy.

## 7. Non-Functional Requirements and Quality Attributes

- **Correctness:** Published claims match attributable sources.
- **Reliability:** Failed network/source operations do not corrupt existing records.
- **Security:** Backend-enforced authorization and least privilege.
- **Privacy:** Minimal data collection and transparent storage.
- **Usability:** Clear explanations, understandable states, accessible core journeys.
- **Maintainability:** Feature-based Flutter structure, clear domain models, repository/service boundaries.
- **Testability:** Deterministic fixtures, automated tests, reproducible CI.
- **Performance:** Responsive lists/search and bounded network/database work.
- **Observability:** Useful operational logs/metrics without sensitive payloads.
- **Portability:** Documented local setup and environment configuration.
- **Auditability:** Source attribution and consequential edit history.
- **Legal/ethical data acquisition:** Follow source terms, applicable laws, robots directives, rate limits, and licensing.

## 8. Acceptance and Phase 2 Closure Gates

A Phase 2 release candidate is **READY** only when all P0 requirements are implemented and verified, or the team has formally approved a written scope change. Use these status definitions:

- **READY FOR PHASE 2 CLOSURE:** All P0 acceptance criteria pass; no unresolved release-blocking defects; evidence is reproducible.
- **CONDITIONALLY READY:** Only explicitly approved low-risk gaps remain, each with owner, mitigation, and due date.
- **NOT READY:** Any P0 requirement is unimplemented/unverified, a critical security/data integrity issue exists, or core journeys fail.
- **NOT VERIFIED:** Required code, environment, credentials, source evidence, or execution output was unavailable. Do not convert “not verified” into “pass.”

### Mandatory evidence pack
- Repository commit SHA and branch.
- Scope-to-code traceability matrix for every P0/P1 module.
- Flutter format/analyze/test/build outputs.
- Python test and data validation outputs.
- Migration application and rollback/recovery evidence.
- RLS/API authorization test results.
- Idempotency, duplicate detection, safe failure, and change-review evidence.
- Sampled official-source verification and freshness report.
- Core journey screenshots or test recordings.
- Accessibility/performance review.
- Security/privacy review and secrets scan.
- Known issues, release notes, and pilot feedback summary.

## 9. Phase 2 Traceability Matrix

| ID | Module | Priority | Depends on | Required evidence |
|---|---|---:|---|---|
| P2-01 | Scholarship & Financial Aid Finder | P0 | Phase 1 schema/source model | Tests, official-source audit |
| P2-02 | Advanced Eligibility Assessment | P0 | P2-01 optional integration; programme rules | Rule tests and explanations |
| P2-03 | Transparent Recommendations | P0 | Profile/preferences, verified data | Scoring docs and deterministic tests |
| P2-04 | Application Planner & Tracker | P0 | Local persistence; optional auth | CRUD/persistence/deletion tests |
| P2-05 | Admissions Calendar | P0 | Admissions cycles/deadlines | Date/time tests |
| P2-06 | Reminders & Notifications | P0 | Planner/calendar | Scheduling, opt-out, cancellation tests |
| P2-07 | Shortlist/Compare Enhancements | P0 | Directory/fees/programmes | Regression and comparison tests |
| P2-08 | Cloud Discrepancy Reporting | P0 | Backend/auth/RLS | API/RLS and review lifecycle tests |
| P2-09 | Admin Editorial Governance | P0 | Auth/RLS/audit | Role and audit tests |
| P2-10 | Scheduled Sync & Change Detection | P0 | M23 sync engine/source policy | Idempotency/failure/live-run evidence |
| P2-11 | Quality/Coverage Dashboard | P0 | Source/freshness/sync metadata | Reconciled metrics/alert tests |
| P2-12 | International Guidance | P0 | Approved country scope/source review | Official-source checklist |
| P2-13 | Institution/Campus/Programme Expansion | P1 | Source coverage strategy | Coverage and sample audit |
| P2-14 | Profile/Preference Controls | P1 | Existing profile model | Privacy/storage tests |
| P2-15 | Accessibility/UX/Performance | P1 | Core journeys | Review and performance evidence |
| P2-16 | Security/Privacy/Reliability | P0 | All backend/data modules | RLS, secrets, recovery evidence |
| P2-17 | Testing/CI/CD/Release | P0 | All modules | Reproducible CI and release pack |
| P2-18 | Privacy-Preserving Analytics | P1 | Privacy review | Event schema and payload audit |

## 10. Phase 3 Boundary and Handoff

Candidate Phase 3 work, not a Phase 2 commitment:
- AI-powered admissions/education assistant grounded in an approved, cited knowledge base.
- Advanced personalization or machine-learning recommendations after data quality and explainability standards are met.
- More countries, institutions, programmes, and scholarship coverage.
- Carefully approved account/cloud synchronization expansion.
- Broader launch, growth, support, analytics, and scalability improvements.
- Additional platforms only after product and operational priorities are approved.

Before Phase 3 begins, Phase 2 should hand over:
- Current architecture and ADRs.
- Data-source registry, licensing notes, and freshness policy.
- API/schema contracts and migration history.
- Recommendation/eligibility rule documentation.
- Security/privacy assessment and unresolved risks.
- Test/CI/release evidence.
- Known limitations and prioritised backlog.

## 11. Team Working Agreement

- Three-person team responsibilities must be agreed explicitly; suggested ownership areas are Mobile/Product UX, Backend/Data Operations, and QA/Security/Integration, with shared code review.
- Every feature must have an owner, acceptance criteria, tests, documentation, and a demonstrable user journey.
- No one should mark a feature “done” based only on UI appearance or a mock response.
- No fabricated source records or test evidence.
- Review pull requests for regression, security, data correctness, and scope creep.
- Keep decisions in ADRs or the project decision log.
- Update this scope through versioned change proposals rather than silent edits.

## 12. Open Decisions to Confirm Before Coding

1. Which initial international destination countries are P0 for Phase 2?
2. Is application-plan data local-only for this phase, or is account-based cloud sync approved?
3. Will notifications be local-only for the first release, or is remote push required?
4. Which scheduler will run data sync (GitHub Actions or managed function), and who owns its secrets/alerts?
5. Which roles will exist in the editorial console, and who can approve critical data?
6. What is the initial pilot size and release target?
7. Is Urdu localization a Phase 2 requirement or a later enhancement?
8. Which measurable performance budgets and supported Android versions will be used?

If a decision is not answered, use the safest low-complexity default, document the assumption, and do not implement a high-risk irreversible choice without approval.

---

**End of Phase 2 Master Scope v1.0**
