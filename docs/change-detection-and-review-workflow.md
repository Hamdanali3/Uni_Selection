# UniSelection — Change Detection & Editorial Review Workflow (Module M23)

**Document Version:** 1.0  
**Phase Baseline:** Phase 1 v1.3  
**Audience:** Data Engineering, Operations, Content Editorial Team  

---

## 1. Overview and Objectives

In higher education, data changes continuously: tuition fee structures are revised, admission deadlines shift, and regulatory recognitions change. However, automatically applying upstream crawls directly to production poses severe risks of data corruption, accidental vandalism, or upstream website errors overriding verified facts.

Module M23 introduces a **verifiable, multi-tier change detection and human-in-the-loop review architecture** that guarantees:
1. No critical regulatory or financial field is updated without editorial confirmation.
2. Low-risk formatting improvements are normalized efficiently.
3. Every change maintains an immutable audit trail showing old value, new value, source URI, and reviewer decision.

---

## 2. Change Detection Pipeline Architecture

```
                  ┌───────────────────────────────┐
                  │ Upstream Data Ingestion       │
                  │ (HEC Baseline & ROR Global)   │
                  └──────────────┬────────────────┘
                                 │
                                 ▼
                  ┌───────────────────────────────┐
                  │ Normalization & Deduplication │
                  │ (Canonical IDs, URLs, Names)  │
                  └──────────────┬────────────────┘
                                 │
                                 ▼
                  ┌───────────────────────────────┐
                  │ Change Detector Engine        │
                  │ (Field-by-Field Diffing)      │
                  └──────────────┬────────────────┘
                                 │
                ┌────────────────┴────────────────┐
                ▼                                 ▼
      [No Changes Detected]              [Field Differences Found]
                │                                 │
                ▼                                 ▼
         Log Idempotent Run             Classify Severity
         (0 mutations to disk)                    │
                                ┌─────────────────┴─────────────────┐
                                ▼                                   ▼
                       [LOW / Formatting]                  [CRITICAL / HIGH]
                        - Acronym formatting                - Accreditation Body
                        - Trailing slash normalization      - Sector / Charter
                                │                           - Tuition Fees
                                ▼                           - Admission Deadlines
                         Auto-Apply Mode                            │
                         (With Audit Log)                           ▼
                                                    Stage in Change Review Queue
                                                    (data_change_events)
                                                            │
                                                            ▼
                                                    Admin Review Console
                                                    (Approve / Reject Action)
```

---

## 3. Severity Classification Matrix

| Field Name | Severity Level | Auto-Apply Allowed? | Review Rationale |
|---|---|---|---|
| `accreditation_body` | 🔴 **CRITICAL** | ❌ No | Accreditations impact legal degree recognition; cannot be changed automatically. |
| `hec_recognized` | 🔴 **CRITICAL** | ❌ No | Statutory standing must be validated against official gazette or gazette circular. |
| `name` | 🔴 **CRITICAL** | ❌ No | Name changes may signify institutional restructuring or deduplication errors. |
| `sector` | 🔴 **CRITICAL** | ❌ No | Public vs private classification impacts tuition subsidy models and charter laws. |
| `tuition_fee` | 🟠 **HIGH** | ❌ No | Financial changes directly affect student budgeting; requires prospectus citation. |
| `application_deadline`| 🟠 **HIGH** | ❌ No | Admissions timelines must be confirmed to avoid misleading applicants. |
| `website_url` | 🟡 **MEDIUM** | ⚠️ Conditional | Domain changes require safety checks to prevent phishing or broken redirects. |
| `acronym` | 🟢 **LOW** | ✅ Yes | Case-insensitive formatting or standardized uppercase normalization. |
| `source_url` | 🟢 **LOW** | ✅ Yes | Upstream link updates to new canonical paths on the same host domain. |

---

## 4. Editorial Review Process (Admin Console)

When change proposals are enqueued, editorial staff review them using the **Data Verification & Editorial Console**:

1. **Review Item Card:**
   - Displays severity badge (`CRITICAL`, `HIGH`, `MEDIUM`).
   - Displays affected institution and field name.
   - Shows a side-by-side comparison of `OLD: <current published value>` and `NEW: <proposed upstream value>`.
   - Cites the originating upstream source connector.
2. **Action — Approve:**
   - The proposed value replaces the active value in the active dataset.
   - The event status is marked `'approved'` in `data_change_events`.
   - `last_checked_at` timestamp is updated to the current UTC timestamp.
   - The change is removed from the pending review queue.
3. **Action — Reject:**
   - The proposed value is discarded; the existing published record remains untouched.
   - The event status is marked `'rejected'` in `data_change_events` with the rejection timestamp.
   - Prevents the same upstream discrepancy from re-alerting until the next major sync cycle.

---

## 5. Student Crowdsourced Discrepancy Reporting

In addition to automated upstream crawlers, students on the ground can identify real-time discrepancies:

1. **Reporting Trigger:**
   - On any Institution Detail screen, students tap the **Flag** icon or the **Report Issue** CTA inside the Verified Provenance card.
2. **Discrepancy Dialog:**
   - Field selector: *Admissions / Deadline*, *Tuition Fee Shift*, *Accreditation / Recognition*, *Official Website / Portal*, *Programme / Degree Info*.
   - Observed value text input.
   - Citation / source link input.
3. **Queue Ingestion:**
   - Student reports are instantly staged into `data_change_events` with `source = 'user_crowdsourced'`.
   - An administrator verifies the student's citation before merging the correction.
