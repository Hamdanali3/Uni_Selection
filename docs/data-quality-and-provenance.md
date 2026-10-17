# UniSelection — Data Quality, Freshness & Provenance Framework

**Version:** 1.0  
**Effective Date:** 17 October 2026  
**Scope Reference:** Section 11 of `UniSelection_Phase_1_Master_Scope_v1.3.md`

---

## 1. Principles of Verifiable Provenance

UniSelection rejects unverified data aggregation. Every factual claim presented to a student must possess verifiable lineage:
1. **Primary Attribution:** Every record in `institutions`, `programmes`, `admissions`, `fee_records`, and `scholarships` links to an official source record via `source_id` and `source_url`.
2. **Dual-Timestamp Tracking:** The platform records two distinct temporal milestones:
   - `last_checked_at`: The most recent timestamp when an automated ingestion connector successfully fetched and examined the upstream webpage or API.
   - `last_verified_at`: The date on which an authoritative fact was confirmed by an official publication date or verified by an editorial reviewer.
3. **Traceability to Official Source:** In the mobile UI, students can tap an external link button on any card to view the primary prospectus or statutory government registry entry in their device browser.

---

## 2. Entity-by-Entity Quality Validation Rules

The automated validation suite (`quality_validator.py` and `validate_dataset.py`) enforces strict validation rules across all entities before publication:

### 2.1 Institution Entity Rules
- `id`: Non-empty alphanumeric slug (`^[a-z0-9_-]+$`), maximum 50 characters.
- `name`: Full legal canonical name, non-empty, title-cased.
- `country_id`: Valid ISO 3166-1 alpha-3 code (e.g. `PAK`, `GBR`, `USA`, `CAN`, `AUS`, `TUR`, `MYS`).
- `official_website`: Valid absolute URL beginning with `https://` (or `http://` where institution lacks TLS). Hostname must match the institution domain.
- `institution_type`: Restricted to `Public` or `Private`.
- `hec_recognized`: Boolean.
  - If `country_id == 'PAK'`: Must be `true` for accredited Pakistani DAIs, with `accreditation_body = 'HEC'`.
  - If `country_id != 'PAK'`: Must be `false`, with `accreditation_body` referencing the foreign statutory body (e.g. `Office for Students (OfS)`, `NECHE`, `TEQSA`, `YÖK`).
- `status`: Restricted to `published`, `in_review`, or `draft`.

### 2.2 Programme Entity Rules
- `institution_id`: Foreign key matching an existing institution in `institutions`.
- `name`: Official programme title (e.g. "Bachelor of Science in Computer Science").
- `degree_level`: Restricted to `Undergraduate`, `Postgraduate`, or `Doctorate`.
- `discipline_id`: Foreign key matching a valid discipline in `disciplines`.
- `duration_years`: Positive float between 1.0 and 6.0 years.
- `source_url`: Valid HTTPS link to the department or programme overview.

### 2.3 Admission Cycle Entity Rules
- `institution_id`: Foreign key matching an existing institution.
- `cycle_name` / `session_name`: Non-empty string (e.g. "Fall 2026", "Spring 2026").
- `academic_year`: Regex pattern `^20\d{2}-20\d{2}$` (e.g. "2025-2026", "2026-2027").
- `application_open_date` & `application_close_date`: Valid `YYYY-MM-DD` syntax.
- **Logical Date Check:** `application_close_date >= application_open_date`.
- `status`: Derived dynamically based on current date:
  - If `now() < open_date`: `upcoming`
  - If `open_date <= now() <= close_date`: `open`
  - If `close_date - now() <= 7 days`: `closing_soon`
  - If `now() > close_date`: `closed`

### 2.4 Fee Record Entity Rules
- `institution_id`: Foreign key matching an existing institution.
- `amount` / `tuition_fee`: Positive float $> 0.0$.
- `currency`: Valid 3-letter ISO 4217 code.
  - National institutions (`PAK`): Must equal `PKR`.
  - International institutions: Must match home country currency (`GBP`, `USD`, `AUD`, `CAD`, `EUR`, `CHF`, `TRY`).
- `billing_basis`: Restricted to `per_semester`, `per_year`, `per_credit_hour`, or `total_programme`.
- `academic_year`: Valid format matching active session.

### 2.5 Scholarship Entity Rules
- `institution_id`: Foreign key matching an existing institution.
- `title`: Official scholarship or financial aid name.
- `funding_type`: Restricted to `fully_funded`, `partial_tuition`, `merit_stipend`, or `need_based`.
- `award_amount`: Numeric or null if variable.
- `application_deadline`: Valid date or null if continuous/rolling.
- `official_portal_url`: Mandatory direct link to scholarship guidelines.

---

## 3. Freshness Thresholds & Stale Data Degradation

Data freshness is monitored continually. When a factual field exceeds its maximum freshness threshold without an updated source check, its status degrades:

```
┌───────────────────────┬────────────────────────┬──────────────────────┬───────────────────────────────┐
│ Entity Type           │ Current (< Threshold)  │ Stale Window         │ Action Taken on Stale Record  │
├───────────────────────┼────────────────────────┼──────────────────────┼───────────────────────────────┤
│ Admission Deadlines   │ $\le 30$ days          │ $> 30$ days          │ Status sets to "Closed / Past";│
│                       │                        │                      │ Amber badge: "Needs Recheck"  │
│ Tuition Fees          │ $\le 180$ days         │ $> 180$ days         │ Displays "Historical Session";│
│                       │                        │                      │ Prompts user to check portal  │
│ Scholarships          │ $\le 90$ days          │ $> 90$ days          │ Suppressed from active filter │
│ Institution Catalog   │ $\le 365$ days         │ $> 365$ days         │ Flagged in data_quality_issues│
│ Regulatory Status     │ $\le 60$ days          │ $> 60$ days          │ Immediate priority sync task  │
└───────────────────────┴────────────────────────┴──────────────────────┴───────────────────────────────┘
```

---

## 4. Confidence Scoring Methodology

Every record is assigned a composite `confidence_score` between 0.0 and 100.0, derived from objective, observable factors:

$$\text{Confidence Score} = W_{\text{tier}} + W_{\text{status}} + W_{\text{age}} + W_{\text{corroboration}}$$

### Scoring Calibration Weights:
1. **Source Authority Weight ($W_{\text{tier}}$, max 50 points):**
   - Tier 1 Statutory Regulator: 50 pts
   - Tier 2 Official University Domain (`.edu.pk`, `.edu`, `.ac.uk`): 45 pts
   - Tier 3 Global Scholarly Registry (ROR, OpenAlex): 40 pts
   - Tier 4 Educational Aggregator: 15 pts
2. **Network Response & Integrity ($W_{\text{status}}$, max 20 points):**
   - Direct HTTP 200 with structured JSON / confirmed DOM: 20 pts
   - HTTP 200 with generic HTML pattern: 15 pts
   - Redirect chain: 10 pts
3. **Verification Age Weight ($W_{\text{age}}$, max 20 points):**
   - Verified $\le 30$ days ago: 20 pts
   - Verified $31 - 90$ days ago: 15 pts
   - Verified $91 - 180$ days ago: 10 pts
   - Verified $> 180$ days ago: 0 pts
4. **Independent Corroboration ($W_{\text{corroboration}}$, max 10 points):**
   - Matched by both Tier 1 and Tier 2 source: 10 pts
   - Single source assertion: 5 pts

### Confidence Interpretation in Application:
- **$\ge 90.0$ (High Confidence):** Displayed with green verified shield badge. Eligible for auto-publishing.
- **$70.0 - 89.9$ (Moderate Confidence):** Displayed with standard styling. Non-critical changes permitted.
- **$< 70.0$ (Low Confidence / Stale):** Displayed with amber warning: *"Information awaiting editorial re-verification"*. High-risk changes blocked.

---

## 5. User Issue Reporting & Feedback Channel

In compliance with responsible data governance, students and university representatives can submit corrections directly from the mobile app via the "Report an Issue" feature.

When submitted, reports are inserted into `data_quality_issues` with:
- Entity type and ID
- Reported issue category (`incorrect_fee`, `closed_admission`, `wrong_website`, `broken_link`)
- User-provided note or link to official notice
- Timestamp of submission

Reports appear in the Admin Review Console for editorial review and verification.
