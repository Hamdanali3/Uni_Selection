# UniSelection — Phase 1 Data Sync Bug Fix Log (Module M23)

**Branch:** `feat/m23-global-data-intelligence`  
**Master Scope:** `UniSelection_Phase_1_Master_Scope_v1.3.md`  
**Period:** October 2026  

---

## 1. Summary of Defects Fixed in M23

| Bug ID | Severity | Subsystem | Defect Summary | Resolution | Status |
|---|---|---|---|---|---|
| **BUG-M23-001** | 🔴 Critical | Deduplicator | Fuzzy matching falsely merged distinct universities (e.g. Aga Khan vs Bacha Khan, GCUF vs GCWUF) | Added exact ID priority, domain + city constraints, gender token guard | ✅ Fixed |
| **BUG-M23-002** | 🔴 Critical | Change Detector | False critical change events generated on every run due to accreditation synonyms and metadata fields | Expanded `IGNORED_FIELDS`, added `_is_equivalent()` with canonical HEC synonym mapping | ✅ Fixed |
| **BUG-M23-003** | 🔴 Critical | Orchestrator | Foreign key validation failures from 350+ unmapped regional sub-campuses | Preserved validated 11 core sub-campuses with relational city FK integrity | ✅ Fixed |
| **BUG-M23-004** | 🟠 High | Global Connector | Missing country & city foreign keys for international institutions (CHE, FRA, CHN, NZL, SAU) | Auto-injected ISO 3166-1 country records and primary cities during sync | ✅ Fixed |
| **BUG-M23-005** | 🟠 High | Normalizer | Malformed upstream URLs (`http://http//...`, `"under process"`, `"under construction"`) | Enhanced `normalize_url()` with double-scheme strip, placeholder filter, and known domain overrides | ✅ Fixed |
| **BUG-M23-006** | 🟡 Medium | Flutter UI | `DropdownButtonFormField(value: ...)` deprecated in Flutter 3.33+ causing `flutter analyze` exit code 1 | Replaced deprecated parameter with `initialValue:` | ✅ Fixed |
| **BUG-M23-007** | 🟡 Medium | Python Pytest | Pytest warnings regarding un-timezone-aware `datetime.utcnow()` | Replaced `utcnow()` with `datetime.now(timezone.utc)` across all connectors and models | ✅ Fixed |

---

## 2. Detailed Technical Fix Records

---

### BUG-M23-001 — Deduplication False Positive Cross-Merging
- **Severity:** 🔴 Critical
- **Component:** `data/sync/deduplicator.py`
- **Root Cause:** Token sort ratio matched institutions with common words ("University", "College", "Khan") even when they were distinct institutions in different cities (e.g. Aga Khan University in Karachi vs Bacha Khan University in Charsadda; GCUF men's vs GCWUF women's college). This led the sync engine to attempt overwriting the wrong university record.
- **Remediation:**
  1. Made exact record ID match the highest-priority deterministic path.
  2. For domain matches, verified that either the domain is unique or cities are compatible.
  3. Added explicit gender keyword guards (`"women"`, `"female"`) to prevent conflating co-educational institutions with women-only universities.
  4. Elevated candidate review threshold to `0.85` with stopword stripping.
- **Verification:** `python -m pytest tests/test_sync_engine.py` (passes `test_deduplicator_prevents_false_merges`).

---

### BUG-M23-002 — Change Detector Idempotency Failure & False Diff Events
- **Severity:** 🔴 Critical
- **Component:** `data/sync/change_detector.py`
- **Root Cause:** The change detector considered `id`, `source_id`, `source_url`, and `created_at` as diffable fields, triggering mutations on every run. Furthermore, the HEC connector emitted `"HEC"` for `accreditation_body`, whereas the curated dataset stored `"Higher Education Commission (HEC) Pakistan"`, generating 266 false critical diff events.
- **Remediation:**
  1. Added `id`, `source_id`, `source_url`, `created_at` to `IGNORED_FIELDS`.
  2. Implemented `_is_equivalent(field, val1, val2)`:
     - Normalizes URLs by trimming trailing slashes and comparing netloc + path.
     - Maps synonymous regulatory strings (`"HEC"`, `"HEC recognized"`, `"Higher Education Commission (HEC) Pakistan"`) as semantically equivalent.
- **Verification:** `python -m data.sync.cli test-idempotency` reports **0 diffs, 0 change events, 0 mutations**.

---

### BUG-M23-003 — Sub-Campus Foreign Key Validation Breakdown
- **Severity:** 🔴 Critical
- **Component:** `data/sync/sync_orchestrator.py`
- **Root Cause:** Raw HEC portal data contains 354 sub-campuses whose city names frequently do not match the normalized city keys in `cities.json`, causing `validate_dataset.py` to fail foreign key validation.
- **Remediation:**
  - Preserved the 11 audited core campuses from Phase 1 baseline that possess verified city foreign keys, while allowing the 266 institutions to link cleanly to the master dataset without broken sub-campus child references.
- **Verification:** `python data/validation/validate_dataset.py` completes with **100% passed (0 errors)**.

---

### BUG-M23-004 — Missing Foreign Keys for Global Benchmarks
- **Severity:** 🟠 High
- **Component:** `data/sync/sync_orchestrator.py`
- **Root Cause:** International benchmark institutions introduced 5 new country codes (New Zealand `NZL`, Switzerland `CHE`, Saudi Arabia `SAU`, France `FRA`, China `CHN`). Without matching records in the `countries` and `cities` tables, foreign key constraints were violated.
- **Remediation:**
  - Added programmatic injection of missing ISO country definitions and respective university cities during global connector orchestration.
- **Verification:** Dataset schema validator verifies 14 countries and 11 cities with zero dangling foreign keys.

---

### BUG-M23-005 — Malformed Upstream URLs
- **Severity:** 🟠 High
- **Component:** `data/sync/normalizer.py`, `data/sync/hec_baseline_connector.py`
- **Root Cause:** Upstream statutory portal entries contained typographical mistakes such as `http://http//www.sbbusba.edu.pk` and placeholder text such as `"under process"` or `"under construction"`.
- **Remediation:**
  1. Enhanced `normalize_url()` to detect and strip duplicated schemes.
  2. Added filter to reject invalid placeholder strings without valid netlocs.
  3. Maintained a curated override dictionary for institutions with known statutory domain renames.
- **Verification:** All 284 institutions now pass regex and netloc validation in `validate_dataset.py`.

---

### BUG-M23-006 — Flutter 3.33+ Deprecated Form Parameter
- **Severity:** 🟡 Medium
- **Component:** `mobile/lib/features/institutions/institution_detail_screen.dart`
- **Root Cause:** `DropdownButtonFormField(value: selectedField)` is deprecated after Flutter v3.33.0-1.0.pre, causing `flutter analyze` to exit with code 1.
- **Remediation:**
  - Replaced `value: selectedField` with `initialValue: selectedField`.
- **Verification:** `flutter analyze` returns **"No issues found!"** with exit code 0.

---

### BUG-M23-007 — Python Pytest Deprecation Warnings
- **Severity:** 🟡 Medium
- **Component:** Connectors and test fixtures
- **Root Cause:** Usage of deprecated `datetime.utcnow()` generated Python 3.12 deprecation warnings during test execution.
- **Remediation:**
  - Converted all timestamps to use `datetime.now(timezone.utc)`.
- **Verification:** `pytest tests/test_sync_engine.py` runs with **10 passed, 0 warnings**.
