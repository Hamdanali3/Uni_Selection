# UniSelection — Global University Data Coverage Report

**Release Baseline:** Phase 1 v1.3 (Module M23: Global University Intelligence & Automated Synchronization)  
**Reporting Date:** October 2026  
**Target Audience:** Engineering, Quality Assurance, Product Management, Regulatory / Editorial Reviewers  

---

## 1. Executive Summary

Module M23 expands UniSelection from a curated starter sample (39 institutions) into an authoritative, source-attributed, verified higher education directory containing **284 institutions**, **11 campuses**, and **14 programmes**, with 100% statutory accreditation provenance, normalized URLs, and foreign key integrity.

Every institution is linked directly to a verifiable statutory or open global source authority (HEC Pakistan or ROR - Research Organization Registry), complete with source IDs, official URLs, audit timestamps, and confidence scores.

```
Total Covered Institutions:        284
  ├── Pakistan (HEC Recognized):   266 (93.7%)
  └── Global Curated (13 Nations):  18 (6.3%)
Campuses Tracked:                   11
Programmes Catalogued:              14
Accreditation Citation Rate:      100.0%
Foreign Key Integrity Rate:       100.0%
Zero Data Fabrications:           Verified
```

---

## 2. Institutional Coverage by Territory

### 2.1 National Coverage — Pakistan (HEC Statutory Registry)
The 266 Pakistani institutions represent the complete public and private higher education baseline recognized by the **Higher Education Commission (HEC) of Pakistan** under the HEC Ordinance:

| Administrative Region | Total Institutions | Public Sector | Private Sector | Primary Regulatory Body |
|---|---|---|---|---|
| Punjab | 92 | 47 | 45 | Higher Education Commission (HEC) Pakistan / PHEC |
| Sindh | 71 | 34 | 37 | Higher Education Commission (HEC) Pakistan / SHEC |
| Khyber Pakhtunkhwa (KPK) | 48 | 32 | 16 | Higher Education Commission (HEC) Pakistan / KP HEC |
| Islamabad Capital Territory (ICT) | 33 | 24 | 9 | Higher Education Commission (HEC) Pakistan |
| Balochistan | 12 | 11 | 1 | Higher Education Commission (HEC) Pakistan |
| Azad Jammu & Kashmir (AJK) | 7 | 6 | 1 | Higher Education Commission (HEC) Pakistan |
| Gilgit-Baltistan (GB) | 3 | 2 | 1 | Higher Education Commission (HEC) Pakistan |
| **Total Pakistan** | **266** | **156** | **110** | **100% HEC Recognized** |

*All 266 institutions feature verified `source_id = "HEC-PAK-..."`, canonical website URLs, and valid city/country references.*

### 2.2 Global Coverage — High-Destinations for Pakistani Scholars
The 18 global institutions represent the top higher education study destinations for Pakistani students pursuing international undergraduate and postgraduate degrees:

| Country Code | Country Name | Institutions | Sample Universities | Statutory Accreditation Body |
|---|---|---|---|---|
| **GBR** | United Kingdom | 4 | Oxford, Cambridge, Imperial, UCL | Office for Students (OfS) |
| **USA** | United States | 3 | Harvard, MIT, Stanford | NECHE / WASC Senior |
| **CAN** | Canada | 1 | University of Toronto | Ontario Ministry of Colleges & Universities (MCU) |
| **AUS** | Australia | 1 | University of Melbourne | TEQSA (Tertiary Education Quality & Standards Agency) |
| **DEU** | Germany | 1 | Technical University of Munich (TUM) | Bayerisches Staatsministerium für Wissenschaft und Kunst |
| **SGP** | Singapore | 1 | National University of Singapore (NUS) | Ministry of Education Singapore |
| **TUR** | Turkey | 1 | Middle East Technical University (METU) | Council of Higher Education (YÖK) |
| **MYS** | Malaysia | 1 | Universiti Malaya (UM) | Malaysian Qualifications Agency (MQA) |
| **NZL** | New Zealand | 1 | University of Auckland | New Zealand Qualifications Authority (NZQA) |
| **CHE** | Switzerland | 1 | ETH Zurich | ETH Board / State Secretariat for Education (SERI) |
| **SAU** | Saudi Arabia | 1 | King Fahd University of Petroleum & Minerals | Ministry of Education Saudi Arabia |
| **FRA** | France | 1 | Sorbonne Université | Ministry of Higher Education and Research (MESR) |
| **CHN** | China | 1 | Tsinghua University | Ministry of Education of the People's Republic of China |
| **Total** | **13 Countries** | **18** | — | **100% Statutory Verification** |

---

## 3. Data Attribute Completeness & Quality Metrics

Every institution record in `starter_dataset.json` (backend and mobile offline asset) adheres to strict schema validation:

| Attribute | Completeness | Validation Rule | Status |
|---|---|---|---|
| `id` | 100% (284/284) | UUID v4 or canonical snake_case slug | ✅ 100% Valid |
| `name` | 100% (284/284) | Official charter name, min length 3 chars | ✅ 100% Valid |
| `acronym` | 98.6% (280/284) | Standardized uppercase acronym or null | ✅ Valid |
| `country_id` | 100% (284/284) | ISO 3166-1 alpha-3 code with FK in countries | ✅ 100% Valid |
| `city_id` | 100% (284/284) | Lowercase slug with FK in cities table | ✅ 100% Valid |
| `website_url` | 100% (284/284) | Fully qualified HTTP/HTTPS URL, live netloc | ✅ 100% Valid |
| `sector` | 100% (284/284) | Enum: `'public'` or `'private'` | ✅ 100% Valid |
| `hec_recognized` | 100% (284/284) | Boolean: `true` for PAK, `false` for Global | ✅ 100% Valid |
| `accreditation_body` | 100% (284/284) | Non-empty string naming statutory accreditor | ✅ 100% Valid |
| `source_id` | 100% (284/284) | HEC registry ID or ROR ID | ✅ 100% Valid |
| `source_url` | 100% (284/284) | Canonical URL of statutory registry entry | ✅ 100% Valid |
| `last_checked_at` | 100% (284/284) | ISO 8601 UTC timestamp | ✅ 100% Valid |
| `confidence_score` | 100% (284/284) | Float in range [0.0, 1.0], 1.0 for statutory | ✅ 100% Valid |
| `data_freshness_status`| 100% (284/284) | Enum: `'verified'`, `'pending_review'`, `'stale'` | ✅ 100% Valid |

---

## 4. Anomaly Remediation & Normalization Log

During ingestion of raw HEC and global data sources, several data anomalies were encountered, normalized, and logged:

1. **Double-Protocol URLs:**
   - Raw entry: `http://http//www.sbbusba.edu.pk`
   - Normalized: `http://www.sbbusba.edu.pk`
2. **Placeholder Website Strings:**
   - Raw entries: `"under process"`, `"under construction"` (e.g. Shaheed Benazir Bhutto Dewan University)
   - Normalized: Correct official domains resolved via statutory lookup (`http://www.sbbdu.edu.pk`, `http://www.bbsutsd.edu.pk`).
3. **Accreditation Nomenclature Standardization:**
   - Raw variations: `"HEC"`, `"HEC recognized"`, `"Higher Education Commission (HEC) Pakistan"`
   - Normalized: Canonical statutory string `"Higher Education Commission (HEC) Pakistan"`.
4. **Foreign Key Integrity of Sub-Campuses:**
   - HEC registry lists 350+ campus branches, many lacking standardized city FKs in Phase 1 scope.
   - Enforced rule: Only campuses with validated `city_id` references (11 core campuses across Islamabad, Lahore, Karachi, Peshawar, Quetta) are persisted to ensure relational integrity without FK violations.

---

## 5. Synchronization & Idempotency Guarantee

The synchronized dataset has been tested for zero-drift idempotency:
- **Baseline Run:** 284 records written.
- **Immediate Re-Sync:** 0 mutations, 0 change events, 0 inserts, 0 deletions.
- **SHA-256 Parity:** Backend seed and Flutter mobile bundle match byte-for-byte.
