# UniSelection — Data Source Register & Integration Policy

**Version:** 1.0  
**Scope Reference:** Section 7 of `UniSelection_Phase_1_Master_Scope_v1.2.md`

This register catalogs all authorized, public information sources used to populate and verify records in UniSelection Phase 1.

---

## 1. Source Hierarchy & Data Policy

UniSelection operates under a **source-first policy**. All published facts (accreditation, degrees, deadlines, eligibility criteria, and fee structures) must link directly to an authoritative source:
1. **Tier 1 (National Regulators):** Higher Education Commission (HEC) of Pakistan recognized institution and campus directories; relevant statutory professional bodies (PEC for engineering, PMDC for medicine, NCEAC for computing).
2. **Tier 2 (Official University Admissions Portals):** Primary domain registrar-verified university websites.
3. **Tier 3 (Published Prospectuses & Schedules):** Official PDF prospectus downloads and gazetted fee circulars.
4. **Strictly Prohibited:** Commercial coaching sites, unofficial forums, scraping behind credentials, or speculative projections.

---

## 2. Regulator References

| Source Code | Organization | Portal URL | Purpose | Refresh Cadence |
|---|---|---|---|---|
| `SRC-HEC-UNI` | Higher Education Commission (HEC) Pakistan | https://www.hec.gov.pk/english/universities/Pages/recognised.aspx | Recognized Universities and Degree Awarding Institutes (DAIs) | Monthly |
| `SRC-HEC-CMP` | Higher Education Commission (HEC) Pakistan | https://www.hec.gov.pk/english/universities/Pages/DAIs/HEC-recognized-Campuses.aspx | Verified sub-campuses and regional branches | Monthly |
| `SRC-PEC` | Pakistan Engineering Council (PEC) | https://www.pec.org.pk/ | First Schedule Accredited Engineering Programmes | Quarterly |
| `SRC-PMDC` | Pakistan Medical & Dental Council (PMDC) | https://pmdc.pk/ | Recognized Medical and Dental Colleges | Quarterly |

---

## 3. Initial Target Institution Register (Sample Baseline)

### 3.1 Pakistani Universities (National Scope)

| ID | Institution Name | Official Portal | Admissions Link | Primary Campus | HEC Status |
|---|---|---|---|---|---|
| `nust` | National University of Sciences & Technology | https://nust.edu.pk | https://ugadmissions.nust.edu.pk | Islamabad (H-12) | Recognized |
| `lums` | Lahore University of Management Sciences | https://lums.edu.pk | https://admissions.lums.edu.pk | Lahore (DHA) | Recognized |
| `giki` | Ghulam Ishaq Khan Institute of Engineering Sciences | https://giki.edu.pk | https://giki.edu.pk/admissions | Topi, Swabi, KPK | Recognized |
| `fast-nu` | National University of Computer & Emerging Sciences | https://nu.edu.pk | https://admissions.nu.edu.pk | Islamabad, Lahore, Karachi, Peshawar, CFD | Recognized |
| `qau` | Quaid-i-Azam University | https://qau.edu.pk | https://qau.edu.pk/admissions | Islamabad | Recognized |
| `aku` | Aga Khan University | https://aku.edu | https://www.aku.edu/admissions | Karachi | Recognized |
| `comsats`| COMSATS University Islamabad | https://comsats.edu.pk | https://admissions.comsats.edu.pk | Islamabad, Lahore, Abbottabad, Wah, Attock, Sahiwal, Vehari | Recognized |
| `uet-lahore`| University of Engineering and Technology Lahore | https://uet.edu.pk | https://admission.uet.edu.pk | Lahore, Kala Shah Kaku, Faisalabad, Narowal | Recognized |
| `iba-karachi`| Institute of Business Administration Karachi | https://iba.edu.pk | https://admissions.iba.edu.pk | Karachi (Main & City Campus) | Recognized |
| `pieas` | Pakistan Institute of Engineering and Applied Sciences | https://pieas.edu.pk | https://admissions.pieas.edu.pk | Nilore, Islamabad | Recognized |
| `pu` | University of the Punjab | https://pu.edu.pk | https://admissions.pu.edu.pk | Lahore (Quaid-i-Azam & Allama Iqbal) | Recognized |
| `uok` | University of Karachi | https://uok.edu.pk | https://uok.edu.pk/admissions | Karachi | Recognized |
| `ned` | NED University of Engineering & Technology | https://neduet.edu.pk | https://admissions.neduet.edu.pk | Karachi | Recognized |
| `kemu` | King Edward Medical University | https://kemu.edu.pk | https://kemu.edu.pk/admissions | Lahore | Recognized |
| `dow` | Dow University of Health Sciences | https://duhs.edu.pk | https://admissions.duhs.edu.pk | Karachi | Recognized |
| `habib` | Habib University | https://habib.edu.pk | https://habib.edu.pk/admissions | Karachi | Recognized |
| `bnu` | Beaconhouse National University | https://bnu.edu.pk | https://bnu.edu.pk/admissions | Tarogil, Lahore | Recognized |
| `kinnaird`| Kinnaird College for Women | https://kinnaird.edu.pk | https://kinnaird.edu.pk/admissions | Lahore | Recognized |
| `fccollege`| Forman Christian College (A Chartered University) | https://fccollege.edu.pk | https://fccollege.edu.pk/admissions | Lahore | Recognized |
| `cust` | Capital University of Science and Technology | https://cust.edu.pk | https://cust.edu.pk/admissions | Islamabad | Recognized |
| `air` | Air University | https://au.edu.pk | https://portals.au.edu.pk/admissions | Islamabad | Recognized |
| `bahria` | Bahria University | https://bahria.edu.pk | https://bahria.edu.pk/admissions | Islamabad, Karachi, Lahore | Recognized |
| `numl` | National University of Modern Languages | https://numl.edu.pk | https://numl.edu.pk/admissions | Islamabad | Recognized |
| `iium` | International Islamic University Islamabad | https://iiu.edu.pk | https://admission.iiu.edu.pk | Islamabad | Recognized |
| `szabist`| SZABIST | https://szabist.edu.pk | https://admissions.szabist.edu.pk | Karachi, Islamabad, Larkana, Hyderabad | Recognized |

### 3.2 Selected International Institutions (Sample Baseline)

| ID | Institution Name | Country | Official Portal | International Admissions Link | Accreditation Body |
|---|---|---|---|---|---|
| `oxford` | University of Oxford | GBR (UK) | https://ox.ac.uk | https://www.ox.ac.uk/admissions | Office for Students (OfS) |
| `cambridge` | University of Cambridge | GBR (UK) | https://cam.ac.uk | https://www.undergraduate.study.cam.ac.uk | Office for Students (OfS) |
| `imperial` | Imperial College London | GBR (UK) | https://imperial.ac.uk | https://www.imperial.ac.uk/study | Office for Students (OfS) |
| `harvard` | Harvard University | USA | https://harvard.edu | https://college.harvard.edu/admissions | NECHE (USA) |
| `mit` | Massachusetts Institute of Technology | USA | https://mit.edu | https://mitadmissions.org | NECHE (USA) |
| `stanford` | Stanford University | USA | https://stanford.edu | https://admission.stanford.edu | WSCUC (USA) |
| `toronto` | University of Toronto | CAN (Canada) | https://utoronto.ca | https://future.utoronto.ca | Ontario Ministry of Colleges |
| `mcgill` | McGill University | CAN (Canada) | https://mcgill.ca | https://www.mcgill.ca/undergraduate-admissions | MES Quebec |
| `tum` | Technical University of Munich | DEU (Germany) | https://tum.de | https://www.tum.de/en/studies/application | Bavarian State Ministry |
| `heidelberg` | Heidelberg University | DEU (Germany) | https://uni-heidelberg.de | https://www.uni-heidelberg.de/en/study/international-studies | Ministry of Science Baden-Württemberg |
| `unimelb` | University of Melbourne | AUS (Australia) | https://unimelb.edu.au | https://study.unimelb.edu.au | TEQSA (Australia) |
| `nus` | National University of Singapore | SGP (Singapore) | https://nus.edu.sg | https://nus.edu.sg/admissions | Ministry of Education Singapore |
| `metu` | Middle East Technical University | TUR (Turkey) | https://metu.edu.tr | https://iso.metu.edu.tr | YÖK (Council of Higher Education) |
| `malaya` | Universiti Malaya | MYS (Malaysia) | https://um.edu.my | https://study.um.edu.my | Malaysian Qualifications Agency (MQA) |

---

## 4. Verification Workflow

1. **Review Frequency:** Admission deadlines and tuition fee tables must be checked at least once per academic cycle (Fall / Spring).
2. **Staleness Threshold:** Any date older than 180 days without editorial re-verification is automatically flagged as `Under Review`.
3. **Audit Trail:** Any change to an institution record generates an immutable row in `admin_audit_log`.
