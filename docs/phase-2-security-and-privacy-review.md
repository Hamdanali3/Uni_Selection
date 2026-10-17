# UniSelection — Phase 2 Security, Privacy & Reliability Review

**Document Title:** Phase 2 Security & Privacy Review (`docs/phase-2-security-and-privacy-review.md`)  
**Scope Baseline:** `UniSelection_Phase_2_Master_Scope_v1.0.md` (Module P2-16)  
**Security Lead / Reviewer:** Senior Application Security Reviewer, Principal PostgreSQL Engineer  
**Status Date:** October 17, 2026  
**Audit Scope:** Database RLS Policies, Mobile Data Minimization, API Network Transport, Local Storage Privacy

---

## 1. Security & Privacy Audit Summary

Phase 2 was architected with privacy-by-design and least-privilege principles at its core.

```
================================================================================
SECURITY & DATA PRIVACY AUDIT VERDICT
================================================================================
1. Personal Data Minimization:       PASSED (Zero CNIC, passport, or financial storage)
2. Application Planner Privacy:      PASSED (100% on-device SharedPreferences; 0 cloud sync)
3. Discrepancy Reporting RLS:        PASSED (Insert-only for public; zero read leakage)
4. PostgreSQL RLS Policies:          PASSED (All 3 new tables protected with RLS)
5. Supabase Anon Key Exposure:       PASSED (Safe anon key; service_role kept off-device)
6. App Transport Security:           PASSED (All official links enforce HTTPS)
================================================================================
OVERALL SECURITY VERDICT:            🟢 PASS (Hardened & Privacy Compliant)
================================================================================
```

---

## 2. Row Level Security (RLS) Policy Audit (Migration 004)

All Phase 2 tables in `backend/migrations/004_phase2_schema.sql` have explicit RLS enabled and tested:

### A. `public.scholarships`
- **Policy:** `Public students can read published scholarships`
  - Targets: `anon`, `authenticated`
  - Operation: `SELECT`
  - Condition: `USING (status = 'published')`
  - Threat Mitigated: Unpublished draft or archived scholarships cannot be scraped or accessed by unauthorized users.
- **Policy:** `Admins have full access to scholarships`
  - Targets: `service_role`
  - Operation: `ALL`
  - Condition: `USING (true) WITH CHECK (true)`

### B. `public.discrepancy_reports` (P2-08 User Feedback Protection)
- **Policy:** `Students can submit discrepancy reports`
  - Targets: `anon`, `authenticated`
  - Operation: `INSERT`
  - Condition: `WITH CHECK (true)`
  - Benefit: Allows any student to report inaccurate data without authentication barriers.
- **Strict Privacy Shield:**
  - **No `SELECT` policy is granted to `anon` or `authenticated`.**
  - Threat Mitigated: Users **cannot** enumerate, read, or spy on discrepancy reports filed by other students.
- **Policy:** `Editorial admins can review discrepancy reports`
  - Targets: `service_role`
  - Operation: `ALL`
  - Condition: `USING (true) WITH CHECK (true)`

### C. `public.country_guidance` (P2-12)
- **Policy:** `Public students can read published country guidance`
  - Targets: `anon`, `authenticated`
  - Operation: `SELECT`
  - Condition: `USING (status = 'published')`

---

## 3. Data Minimization & Local Privacy Architecture

1. **Zero Collection of Sensitive Student Records:**
   - UniSelection **does not** prompt for, collect, store, or transmit:
     - Computerized National Identity Card (CNIC) numbers
     - Passport scans or passport numbers
     - Student bank account statements, IBANs, or tax returns
     - Official educational marksheets or certificates
2. **Local-Only Application Planner (P2-04):**
   - Application plans, custom checklist milestones, and deadline reminders are stored strictly in `SharedPreferences` on the physical device.
   - Code inspection confirms that `LocalStorageService.saveApplicationPlan()` never calls `RemoteApiService` or any external endpoint.
3. **Local-Only Notifications (P2-06):**
   - Reminders are scheduled locally using device scheduling primitives.
   - No external device tokens (FCM/APNS) are sent to cloud push relays.

---

## 4. Network Transport & Credential Hygiene

- **PostgREST Endpoints:** Secured with HTTPS and postgREST query timeouts (`apiTimeoutSeconds: 15`).
- **Secret Separation:** The Flutter codebase contains no secret service-role keys or database superuser passwords. `AppConfig` continues to use standard runtime environment variable placeholders (`String.fromEnvironment`).
