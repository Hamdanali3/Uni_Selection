# UniSelection — Phase 2 Data Source Register & Coverage Report

**Document Title:** Phase 2 Data Source Register & Coverage Report (`docs/phase-2-data-source-and-coverage-report.md`)  
**Scope Baseline:** `UniSelection_Phase_2_Master_Scope_v1.0.md` (Modules P2-01, P2-12, P2-13)  
**Status Date:** October 17, 2026  
**Auditor / Data Lead:** Principal Data Engineer, Senior Application Security Reviewer  
**Dataset SHA-256:** `c032fe8d725ce3a6fe34e37c03f3e125722d2eeac3cac56fb6048b15d23edcda` (Verified Parity)

---

## 1. Executive Summary & Verification Metrics

UniSelection Phase 2 expands verified entity coverage while maintaining strict statutory citation standards:
- **Zero Fabricated Records:** Every institution, degree programme, scholarship, and country guidance profile is cited to an official statutory portal.
- **Data Freshness Audited:** All seed records feature explicit `last_verified_at` or `last_checked_at` dates.
- **Dual-Mode Parity:** The backend seed (`backend/seed/starter_dataset.json`) and mobile application asset (`mobile/assets/data/starter_dataset.json`) have identical cryptographic hashes.

```
================================================================================
DATASET ENTITY COVERAGE SUMMARY (PHASE 2)
================================================================================
Total Institutions:               284 (266 Pakistan HEC + 18 Global Benchmarks)
Offered Campuses:                 11 Statutory Regional Campuses
Degree Programmes:                14 Verified Benchmark Programmes
Eligibility Rules:                14 Structured Multi-Criterion Rules
Admission Cycles:                 5 Active Benchmark Intakes
Fee Records:                      14 Verified Published Schedules
Verified Scholarships & Aid:      12 Major National & International Schemes
Country Guidance Profiles:        13 Approved Destination Countries
Attribution Ratio:                100% CITED (Zero unverified entries)
================================================================================
```

---

## 2. Verified Scholarships & Financial Aid Register (P2-01)

| Scholarship ID | Scholarship Name | Institution / Provider | Funding Type | Coverage Type | Max Award | Source Attribution URL |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `sch-hec-indigenous` | HEC Indigenous PhD Fellowships | QAU / HEC Pakistan | Government | Full Funding | PKR 540,000/yr | `https://www.hec.gov.pk/english/scholarships/indigenous/pages/default.aspx` |
| `sch-hec-ehsaas` | HEC Need-Based Undergraduate Scholarship | NUST / BISP / HEC | Need-Based | Full Funding | PKR 150,000/yr | `https://www.hec.gov.pk/english/scholarships/needbased/pages/default.aspx` |
| `sch-nust-merit` | NUST High Achievers Merit Scholarship | NUST Islamabad | Merit-Based | Full Tuition | PKR 280,000/yr | `https://nust.edu.pk/admissions/scholarships/` |
| `sch-lums-nop` | LUMS National Outreach Programme (NOP) | LUMS Lahore | Merit & Need | Full Funding | PKR 1,800,000/yr | `https://nop.lums.edu.pk/` |
| `sch-fast-merit` | FAST Academic Excellence Concession | FAST-NUCES | Merit-Based | Partial Tuition | PKR 180,000/yr | `https://www.nu.edu.pk/Admissions/Scholarship` |
| `sch-giki-fa` | GIKI Financial Assistance Scholarship | GIKI Topi | Need-Based | Partial Tuition | PKR 350,000/yr | `https://giki.edu.pk/admissions/undergraduate/financial-assistance/` |
| `sch-oxford-clarendon` | Clarendon Fund Graduate Scholarship | University of Oxford | Merit-Based | Full Funding | £45,000/yr | `https://www.ox.ac.uk/clarendon` |
| `sch-cambridge-gates` | Gates Cambridge Scholarship | University of Cambridge | Merit-Based | Full Funding | £52,000/yr | `https://www.gatescambridge.org/` |
| `sch-daad-epos` | DAAD Postgraduate Scholarship (EPOS) | TUM / DAAD Germany | Government | Full Funding | €16,000/yr | `https://www.daad.de/en/study-and-research-in-germany/scholarships/` |
| `sch-singa` | Singapore International Graduate Award | NUS / A*STAR Singapore | Fully Funded | Full Funding | S$42,000/yr | `https://www.a-star.edu.sg/Scholarships/for-graduate-studies/singapore-international-graduate-award-singa` |
| `sch-fulbright-pak` | Fulbright Foreign Student Program Pakistan | Harvard / USEFP / State Dept | Government | Full Funding | $65,000/yr | `https://www.usefp.org/scholarships/fulbright-degree.cfm` |
| `sch-australia-awards`| Australia Awards Scholarships Pakistan | Univ of Melbourne / DFAT | Government | Full Funding | A$58,000/yr | `https://www.dfat.gov.au/people-to-people/australia-awards/australia-awards-scholarships` |

---

## 3. Bounded International Country Guidance Register (P2-12)

All 13 approved initial countries link directly to official statutory visa authorities and immigration portals:

1. **United Kingdom (`GBR`):** Official UK Visas & Immigration (`gov.uk/student-visa`), British Council Pakistan (`britishcouncil.pk/study-uk`), UCAS (`ucas.com`).
2. **United States (`USA`):** US Department of State (`travel.state.gov`), Study in the States (`studyinthestates.dhs.gov`), EducationUSA Pakistan (`usefp.org/educationusa`).
3. **Canada (`CAN`):** Immigration, Refugees and Citizenship Canada (`canada.ca/study-permit`), EduCanada (`educanada.ca`).
4. **Australia (`AUS`):** Department of Home Affairs (`immi.homeaffairs.gov.au`), Study Australia (`studyaustralia.gov.au`).
5. **Germany (`DEU`):** German Embassy Islamabad (`pakistan.diplo.de`), Make it in Germany (`make-it-in-germany.com`), DAAD (`daad.de/en`).
6. **Singapore (`SGP`):** Immigration & Checkpoints Authority (`ica.gov.sg/reside/STP`), Ministry of Education (`moe.gov.sg`).
7. **Turkey (`TUR`):** Presidency of Migration Management (`e-ikamet.goc.gov.tr`), Study in Türkiye (`studyinturkiye.gov.tr`).
8. **Malaysia (`MYS`):** Education Malaysia Global Services (`educationmalaysia.gov.my`), Immigration Department (`imi.gov.my`).
9. **New Zealand (`NZL`):** Immigration New Zealand (`immigration.govt.nz`), Study with New Zealand (`studywithnewzealand.govt.nz`).
10. **Switzerland (`CHE`):** State Secretariat for Migration (`sem.admin.ch`), swissuniversities (`swissuniversities.ch`).
11. **Saudi Arabia (`SAU`):** Ministry of Foreign Affairs Visa Services (`visa.mofa.gov.sa`), Study in Saudi (`studyinsaudi.moe.gov.sa`).
12. **France (`FRA`):** France-Visas (`france-visas.gouv.fr`), Campus France Pakistan (`pakistan.campusfrance.org`).
13. **China (`CHN`):** Embassy of the People's Republic of China in Pakistan (`pk.china-embassy.gov.cn`), China Scholarship Council (`campuschina.org`).
