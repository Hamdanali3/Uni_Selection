# UniSelection — Release Readiness Checklist & Definition of Done

**Version:** 1.0  
**Scope Reference:** Section 23 of `UniSelection_Phase_1_Master_Scope_v1.2.md`

Use this checklist prior to releasing a pilot build or milestone deliverable.

---

## 1. Pre-Development Gate (Sprint 0)
- [x] Scope document reviewed and baseline established.
- [x] Initial institution starter list (25+ Pakistan, 12+ International) compiled with official portals.
- [x] Architecture Decision Records (ADRs) logged for stack, guest model, and RLS.
- [x] Data dictionary and entity relationships documented.
- [x] Git repository initialized with clean `.gitignore` and `.env.example`.
- [x] Flutter SDK, Android tooling, and Chrome testing environment verified.

---

## 2. Security & Policy Gate
- [ ] No private API keys, service-role keys, or JWT secrets committed to source control.
- [ ] Supabase Row Level Security (RLS) enabled on all exposed tables.
- [ ] Anonymous users have read-only access to records where `status = 'published'`.
- [ ] Anonymous insert/update/delete attempts to catalogue tables are rejected with 403 Forbidden.
- [ ] All remote endpoints use HTTPS encryption.
- [ ] Data minimization enforced: no CNIC, passport, or banking documents collected.

---

## 3. Data Integrity & Verification Gate
- [ ] 100% of published institutions have official portal URLs.
- [ ] 100% of published programmes, admission deadlines, and fees have `last_verified_at` dates.
- [ ] Fee amounts specify academic session and billing basis (per semester / per year).
- [ ] Outdated records (>180 days without audit) marked as `Under Review`.
- [ ] Python batch validation script (`validate_dataset.py`) passes with zero errors on seed dataset.

---

## 4. UI/UX & Functional Gate
- [ ] App launches with responsive layout and distinct Material 3 color theme.
- [ ] Clear separation between National (Pakistan) and International catalogues.
- [ ] Search and multi-facet filtering (Category, City, Type) functions with fast response.
- [ ] Empty states provide clear recovery actions (e.g. "Reset Filters").
- [ ] Eligibility calculator accurately applies minimum percentage rules and renders legal caveat.
- [ ] Shortlist persists locally and allows removing items.
- [ ] Comparison screen renders side-by-side attributes with clear handling of missing values.
- [ ] Settings screen contains Terms, Privacy Notice, Data Limitations, and Source Register link.

---

## 5. Build & Packaging Gate
- [ ] Flutter unit tests and widget tests pass (`flutter test`).
- [ ] Android APK / App Bundle builds cleanly without lint errors.
- [ ] Web build runs and functions cleanly on modern desktop/mobile browsers.
- [ ] Release notes and version bump recorded in `pubspec.yaml`.
