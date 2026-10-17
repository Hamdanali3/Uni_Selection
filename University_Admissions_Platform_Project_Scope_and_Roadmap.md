# Project Scope & Delivery Roadmap
## Pakistan University, Admissions, Scholarships & Study-Abroad Guidance Platform

**Version:** 1.0  
**Prepared:** 12 October 2026  
**Delivery model:** Solo developer, phased MVP

## 1. Executive summary
Build an Android-first Flutter app that helps students in Pakistan discover universities, campuses and programmes; understand admissions, deadlines and fees; find scholarships; save a shortlist; and access later study-abroad and visa guidance linked to official sources.

**Recommended stack:** Flutter/Dart, VS Code, Android Studio for Android SDK/emulator tooling, Git/GitHub, Supabase PostgreSQL/Auth/Storage as needed, and Supabase Edge Functions for narrow server-side tasks. Start without a separate FastAPI backend; add one only when justified.

## 2. Vision and goals
- Make higher-education choices more transparent.
- Search and filter Pakistani universities, programmes and scholarships.
- Show eligibility, deadlines, fee basis, official links and last-verified date.
- Let users save opportunities and report incorrect information.
- Build a maintainable content-review workflow.
- Expand internationally only after the Pakistan MVP has reliable data operations.

Proposed targets (to validate in pilot): 95%+ of published records have source URL and verification date; search responds within 2 seconds on the agreed test dataset; core flows pass acceptance tests.

## 3. Roles
- **Guest/student:** browse public records and official links.
- **Registered student:** profile preferences, shortlist and reports.
- **Editor:** create/update drafts and attach sources.
- **Admin:** approve/publish/archive, review reports and audit changes.
- **Automation:** least-privilege imports/validation.

## 4. Scope

### MVP
- Pakistan university/campus directory and HEC recognition source.
- Programme directory: level, discipline, campus, duration, eligibility and official link.
- Admissions cycles/deadlines with source and verification date.
- Fee records labelled by academic year and basis (per semester/year/credit/one-time).
- Scholarship directory with eligibility, benefit, deadline, required documents and official link.
- Search/filters, details pages, shortlist, basic profile and correction reporting.
- Admin workflow: draft → review → publish → stale/archive.
- Privacy policy, terms, disclaimers, support and account deletion process.

### Later phases
- International university catalogue and scholarship coverage.
- Country-specific visa guidance linked to official immigration authorities.
- AI assistant, explainable recommendations, document parsing and voice input.
- Push reminders, calendar integration, application tracker, iOS and web portal.

### Exclusions / guardrails
No admission, scholarship or visa guarantees. No assumption that a public API exists. No prohibited scraping. No passport/CNIC/bank-document collection in MVP. AI guidance is not an official decision. Payments/counselling marketplace are separate future decisions.

## 5. Core user journeys
1. Search → filter → university/programme details → official source.
2. Save and compare programmes by location, eligibility, duration, fee basis and deadline.
3. Enter scholarship criteria → see potential matches → verify official eligibility and apply at official link.
4. Report inaccurate data → admin review → correction logged.
5. Admin creates draft → validates source and fields → reviews → publishes with verification date.

## 6. Screen inventory
Plan approximately 18–24 routes/components:
- Splash, onboarding/preferences, home.
- University list, search/filter sheet, university detail, campus detail.
- Programme list, programme detail, compare programmes.
- Admissions/deadline detail and requirements checklist.
- Scholarship list, filters, detail, eligibility questionnaire/results.
- Sign-in, sign-up, password reset, profile/preferences, saved shortlist.
- Source/verification view, report issue, FAQ/help, privacy, terms.
- Loading, empty, offline/error and consent states.
- Later: AI assistant, international search, visa guide, notification centre and application tracker.

Suggested bottom navigation: **Home | Explore | Scholarships | Saved | Profile**.

## 7. Functional requirements
- **P0:** university/campus browsing, search/filter, programme details, source/freshness metadata, admin content workflow.
- **P0:** scholarship listing and criteria; label matches as potential, not guaranteed.
- **P1:** auth, shortlist, correction reports.
- **P2:** international/visa content, AI recommendations and notifications.

## 8. Non-functional requirements
Security (RLS, least privilege, secret management), privacy/data minimization, reliable error states and backups, indexed/paginated queries, accessible typography, localization-ready English/Urdu, maintainable feature-based code and clear distinction between official facts, estimates and AI suggestions.

## 9. Technology and architecture
**Flutter app → Supabase API → PostgreSQL with Row Level Security.** Supabase Auth for accounts; Storage only if needed; Edge Functions for trusted server-side work. Add a web admin interface after core data workflows are understood.

Do not put service-role/secret keys in Flutter. A client-side key is safe only when RLS and permissions are correctly configured. Hiding a UI control is not authorization.

Suggested Flutter structure:
```text
lib/
  app/       # router, theme, app shell
  core/      # errors, constants, shared widgets
  features/  # home, universities, programs, admissions,
             # scholarships, saved, auth, profile, feedback
  data/      # repositories, remote sources, DTOs
  l10n/      # localization
  main.dart
```

## 10. Initial data model
- `universities`: id, name, sector, province, city, official_url, recognition status/source, status, timestamps.
- `campuses`: id, university_id, name, city, province, official_url, source_url.
- `programs`: id, university_id, campus_id, title, degree_level, discipline, duration, mode, eligibility, official_url, status.
- `admission_cycles`: id, program_id, intake, opens_on, deadline_on, status, source_url, verified_at.
- `fee_records`: id, program/campus, amount, currency, fee_basis, academic_year, breakdown, source_url, verified_at.
- `scholarships`: id, provider, title, award type/value, official URL, deadline, status, verified_at.
- `scholarship_criteria`: id, scholarship_id, criterion type/operator/value/notes.
- `profiles`: auth user id, optional name and preferences, consent flags.
- `saved_items`: user_id, entity_type, entity_id, created_at.
- `issue_reports`: entity, category, description, status and timestamps.
- `content_sources`: entity, URL, source type, checked_at/by, notes.
- `audit_log`: actor, action, entity, timestamp, safe change summary.

Use UUIDs, foreign keys, constraints, timestamps, indexes and RLS. Refine relationships before migrations.

## 11. APIs and data sources
There may not be one public API covering Pakistani admissions, fees and scholarships. Discover and verify each source before promising automation.

| Need | Approach |
|---|---|
| HEC recognition/campuses | HEC official listings; confirm whether permitted bulk download/API exists |
| Admissions/programmes | Official university/department pages; curate manually initially |
| Fees | Official prospectus/fee schedule; store year, currency, fee basis and verification date |
| Scholarships | Official university/provider scholarship pages |
| International study | Official university sites and permitted official/open datasets |
| Visa guidance | Destination-country government/immigration/embassy sources only |
| Maps | Optional Google Maps Platform or OpenStreetMap-based provider; review terms/cost |
| Email | Supabase Auth email or transactional email service |
| Push | Firebase Cloud Messaging if reminders are introduced |
| AI | Optional provider through a server-side function, with approved-source retrieval and privacy controls |

For each integration, check ownership/terms, auth, rate limits, cost, caching, timeout/retry, payload validation, secret storage, logging and manual fallback. Any scraping needs terms/robots/copyright and load review.

## 12. Data quality operations
1. Maintain a source register.
2. Require source URL, verification date, academic year where relevant, and next review date.
3. Use statuses: draft, needs review, published, stale/under review, archived.
4. Start with a smaller accurate catalogue; expand gradually.
5. Recheck deadlines and fees each intake/year.
6. Provide a user correction flow.
7. Link recognition claims to the authoritative regulator, not marketing copy.

## 13. Security and privacy
- Enable/test RLS on every client-exposed table.
- Ensure users can access only their own profile and saved items.
- Restrict admin roles and never trust client-supplied roles.
- Keep service secrets out of mobile builds and source control.
- Minimize personal data; do not collect identity/financial documents in MVP.
- Publish privacy, terms, disclaimers, retention and deletion instructions.
- Review applicable Pakistan laws, cross-border data and app-store requirements with qualified counsel before launch.

## 14. Testing and release gates
- Unit: eligibility matching, dates, fee formatting and validation.
- Widget: cards, filters, detail, empty/loading/error and accessibility states.
- Integration: auth, queries, shortlist, reports and RLS.
- Security: anonymous writes denied; users cannot access each other's private records.
- Data: missing source, invalid date, duplicate and stale records.
- Device: different Android sizes, slow network, offline/retry.
- Release: no secrets in bundle/repo; privacy links work; production configuration verified.

Release only when critical/high security defects are resolved, core flows pass, sources/dates are visible, policies are accessible and backup/recovery is documented.

## 15. Solo-developer roadmap
| Phase | Estimate | Exit deliverable |
|---|---:|---|
| Discovery/MVP definition | 1 week | Audience, scope, journeys and pilot dataset |
| Design/environment | 1 week | Wireframes, Git, Flutter, VS Code, Android SDK |
| Supabase foundation | 1 week | Schema, RLS, migrations, seed data |
| Core discovery | 2 weeks | Home, university list, search, details |
| Admissions/fees | 1–2 weeks | Cycles, deadlines, fee records and sources |
| Scholarships/shortlist | 2 weeks | Scholarship criteria, auth, saved items |
| Admin/data operations | 1–2 weeks | Review/publish workflow, reports, CSV tools |
| QA and pilot | 2 weeks | Tests, feedback and defect fixes |
| Release preparation | 1 week | Production config, policies, support and release build |
| Phase 2 | After pilot | International data, visa links, AI and reminders |

Indicative MVP: around **11–14 focused weeks**, excluding extensive learning, data collection, legal review and API approvals. Data curation may take longer than coding; re-estimate after two weeks.

## 16. First 14 days
1. Confirm audience and MVP boundaries.
2. Choose 20–30 universities and 50–100 programmes for pilot data.
3. Wireframe Home, Explore, Detail, Scholarships and Saved.
4. Install/verify Git, VS Code, Flutter, Android Studio/SDK; run `flutter doctor -v`.
5. Create a private GitHub repository.
6. Create Supabase project and secure environment configuration.
7. Create schema and sample records with sources.
8–9. Build app shell, navigation, theme and states.
10–11. Build university list/detail connected to database.
12. Add search/filter.
13. Show source and verification date.
14. Demo, test and re-estimate.

## 17. Deliverables
Scope document, prioritized backlog, wireframes, ERD, migrations/RLS tests, source register, CSV template, Flutter repository and README, test plan, defect log, pilot feedback, privacy/terms and release checklist.

## 18. Key risks
- **Stale data:** verification dates, reports and review workflow.
- **No official API:** manual curation and permitted downloads.
- **Scope creep:** freeze MVP; defer AI/international scale.
- **Solo capacity:** weekly demo and one vertical slice at a time.
- **Security errors:** RLS from day one and cross-user tests.
- **Unexpected costs:** usage monitoring and budget limits.
- **AI misinformation:** approved-source retrieval and explicit caveats.
- **Legal/brand concerns:** review data rights and claims before launch.

## 19. Decisions to confirm
- Undergraduate only or postgraduate in MVP?
- All Pakistan at launch or a controlled initial catalogue?
- English only or English + Urdu from day one?
- Recommended: guest browsing; sign-in only for saved items.
- Official fees only or clearly labelled estimates too?
- Recommended: defer international/visa module until Pakistan data is reliable.

## 20. Official references
- Flutter + VS Code: https://docs.flutter.dev/install/with-vs-code
- Flutter Android setup: https://docs.flutter.dev/platform-integration/android/setup
- Supabase Flutter docs: https://supabase.com/docs/reference/dart/start?framework=flutter
- Supabase docs: https://supabase.com/docs
- HEC recognised universities: https://www.hec.gov.pk/english/universities/Pages/recognised.aspx
- HEC recognised campuses: https://www.hec.gov.pk/english/universities/Pages/DAIs/HEC-recognized-Campuses.aspx

*Planning baseline only; recheck official pages during implementation. This is not legal advice and does not imply third-party API availability.*
