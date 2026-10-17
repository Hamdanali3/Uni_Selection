# UniSelection — Global Data Source Registry

**Version:** 1.0  
**Last Updated:** 17 October 2026  
**Scope Reference:** Section 7 of `UniSelection_Phase_1_Master_Scope_v1.3.md`

---

## 1. Registry Architecture & Authority Hierarchy

Data sources in UniSelection are ranked according to a 4-tier authority hierarchy with field-specific precedence rules:

| Tier | Source Category | Primary Domain | Authority for Fields | Override Policy |
|---|---|---|---|---|
| **Tier 1** | **Statutory Regulators** | HEC Pakistan, Statutory Accreditation Councils (PEC, PMDC, NCEAC), Foreign Regulators (UK OfS, TEQSA) | Institutional Recognition, Campus Authorization, Degree-Awarding Charter | Authoritative over all other sources for regulatory status |
| **Tier 2** | **Official University Portals** | Official university websites, admission portals, official prospectuses | Programmes offered, Admission Deadlines, Fee Schedules, Specific Eligibility Rules, Scholarships | Authoritative for deadlines, fees, and offerings |
| **Tier 3** | **Global Open Registries** | Research Organization Registry (ROR), OpenAlex, UNESCO UIS | Canonical Names, Global Identifiers, Geocoding, Hierarchy | Discovery & global deduplication baseline |
| **Tier 4** | **Educational Aggregators** | Eduvision, Eduhubpak, PakUniFinder | Candidate Discovery, Initial URL discovery | *Never authoritative*; requires secondary Tier 1/2 verification |

---

## 2. Comprehensive Source Inventory

| Source ID | Source Name & Official URL | Geographic Scope | Data Fields Covered | Authority Tier | Access Method | Licensing / Terms | Implementation Status | Refresh Interval | Last Execution | Known Limitations & Gaps |
|---|---|---|---|---|---|---|---|---|---|---|
| `hec_universities` | **HEC Recognized Universities List**<br>`https://www.hec.gov.pk/english/universities/Pages/recognised.aspx` | Pakistan (National) | Legal Name, Sector (Public/Private), Province, Chartered By, Recognition Status | **Tier 1** | CSV Import & Polite HTML | Public statutory gazette / Public domain | ✅ **Connector Executed & Validated** | 14 days | 2026-10-17 | Main list does not break down individual regional sub-campuses or programme-level accreditation. |
| `hec_campuses` | **HEC Recognized Campuses List**<br>`https://www.hec.gov.pk/english/universities/Pages/DAIs/HEC-recognized-Campuses.aspx` | Pakistan (National) | Sub-campus names, Parent Institution, City, Recognized vs Unrecognized Status | **Tier 1** | Polite HTML & Structured CSV | Public statutory notice | ✅ **Connector Executed & Validated** | 14 days | 2026-10-17 | Campus list updates intermittently; requires manual cross-check for newly established regional centers. |
| `hec_foreign` | **HEC Foreign HEIs Recognition Procedure**<br>`https://www.hec.gov.pk/english/services/students/DES/Pages/Procedure/Foreign-HEIs.aspx` | International (Global) | Foreign institution equivalence criteria, recognized country lists | **Tier 1** | Polite HTML Inspection | Public regulatory procedure | ✅ **Research Completed & Documented** | 30 days | 2026-10-17 | Evaluates recognition principles rather than providing a downloadable API of foreign universities. |
| `ror_registry` | **Research Organization Registry (ROR) API**<br>`https://ror.org/` / `https://api.ror.org/v2/organizations` | Worldwide (150+ countries) | Canonical Name, ROR ID, Country Code, City, Official Website, Aliases, External IDs (Wikidata, ISNI) | **Tier 3** | REST API (JSON) | Creative Commons Zero (CC0 1.0) | ✅ **Connector Executed & Validated** | 30 days | 2026-10-17 | Includes research institutes, hospitals, and government laboratories; requires strict filtering for university type. |
| `openalex_api` | **OpenAlex Institutions API**<br>`https://openalex.org/` / `https://api.openalex.org/institutions` | Worldwide (100+ countries) | OpenAlex ID, ROR ID, Display Name, Country, Works Count, Cited By Count | **Tier 3** | REST API (JSON) | Open Database License (ODbL) | ✅ **Connector Executed & Validated** | 30 days | 2026-10-17 | Bibliometric coverage; does not track admission deadlines, eligibility thresholds, or fee structures. |
| `official_university_portals` | **Official University Websites**<br>(e.g. `nust.edu.pk`, `lums.edu.pk`, `ox.ac.uk`, `cam.ac.uk`) | National & Global | Degree Programmes, Application Deadlines, Fee Schedules, Eligibility Criteria, Scholarships | **Tier 2** | Polite HTML, ETag / Hash sync | Factual public notice / Fair dealing | ✅ **Connector Executed & Validated** | 7 days (Admissions/Fees: 1-3 days) | 2026-10-17 | Formats vary widely across institutions; requires custom parsing patterns or curated ingestion templates. |
| `eduvision` | **Eduvision Pakistan**<br>`https://www.eduvision.edu.pk/` | Pakistan | Candidate institution names, general discipline offerings | **Tier 4** | Polite Discovery Check | Proprietary / All rights reserved | ✅ **Feasibility Audited** | 30 days (Discovery only) | 2026-10-17 | Commercial aggregator; cannot be used as primary proof of HEC recognition. |
| `eduhubpak` | **EduHub Pakistan**<br>`https://eduhubpak.com/` | Pakistan | University directory listings, city mappings | **Tier 4** | Polite Discovery Check | Proprietary | ✅ **Feasibility Audited** | 30 days (Discovery only) | 2026-10-17 | Secondary discovery only; limited depth on admission cycles. |
| `pakunifinder` | **PakUniFinder**<br>`https://www.pakunifinder.com/` | Pakistan | Institution listings, contact telephone numbers | **Tier 4** | Polite Discovery Check | Proprietary | ✅ **Feasibility Audited** | 30 days (Discovery only) | 2026-10-17 | Contains ads/marketing content; facts must be verified on official university portal. |
| `vision_edu` | **Vision International University**<br>`https://www.vision.edu/web/` | USA | Single institution academic catalogue | **Tier 2** | Single Domain Inspection | Institutional website | ✅ **Audited & Classified** | On demand | 2026-10-17 | **Note:** Evaluated per user request. Confirmed as an individual theological institution website, not a general university directory. |

---

## 3. Field-Level Precedence and Conflict Resolution Rules

When multiple sources report on the same entity, the following field-specific rules determine the authoritative assertion:

```
┌─────────────────────────┬───────────────────────────────┬──────────────────────────────┐
│ Entity & Field          │ Primary Authority             │ Fallback Authority           │
├─────────────────────────┼───────────────────────────────┼──────────────────────────────┤
│ Institution Recognition │ Tier 1 Statutory Regulator    │ None (Unrecognized if absent)│
│ Sub-Campus Validity     │ Tier 1 Statutory Regulator    │ Tier 2 Official Portal       │
│ Official Portal URL     │ Tier 2 Official Website       │ Tier 3 ROR / OpenAlex        │
│ Programme Title         │ Tier 2 Official Prospectus    │ Tier 1 Professional Council  │
│ Admission Deadline      │ Tier 2 Official Admissions URL│ None (Never guessed)         │
│ Tuition Fee Amount      │ Tier 2 Official Fee Schedule  │ None (Marked "Not Published")│
│ Minimum Eligibility     │ Tier 2 Official Admissions URL│ Tier 1 Minimum Guidelines    │
│ Scholarship Offering    │ Tier 2 University Portal      │ Tier 1 HEC Scholarship Board │
│ Canonical ROR ID        │ Tier 3 ROR Registry           │ Tier 3 OpenAlex Cross-ref    │
└─────────────────────────┴───────────────────────────────┴──────────────────────────────┘
```

### Conflict Resolution Workflow
1. If Tier 1 contradicts Tier 2 (e.g. university claims a sub-campus, but HEC statutory list marks it unapproved):
   - **Tier 1 prevails.** The campus is flagged as `"Restricted / Awaiting Statutory Approval"`.
   - A critical alert is raised in `data_quality_issues`.
2. If two Tier 2 pages on the same domain report conflicting deadlines:
   - Both assertions are retained with their page URLs.
   - The conflict is placed into the `review_queue` with status `needs_review`.
   - The public app displays: `"Multiple deadlines published — consult admissions office directly"`.

---

## 4. Source Connector Health Monitoring

Connectors report their operational health via `sync_runs` table with five health states:
- `operational`: Responding within 2000ms with expected payload structure.
- `degraded`: Intermittent timeouts, elevated latency (>5000ms), or HTTP 429 rate limit responses.
- `format_drift`: HTTP 200 returned, but expected CSS selectors or JSON keys are missing. Triggers parser safe-failure.
- `unreachable`: DNS resolution failure, connection reset, or persistent HTTP 5xx errors. Existing data is frozen and protected.
- `disabled`: Administratively paused due to webmaster request or maintenance.
