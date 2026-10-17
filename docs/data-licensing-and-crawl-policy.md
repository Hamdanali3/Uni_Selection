# UniSelection — Data Licensing, Lawful Ingestion & Ethical Crawling Policy

**Version:** 1.0  
**Effective Date:** 17 October 2026  
**Scope Reference:** Section 6 & Section 7 of `UniSelection_Phase_1_Master_Scope_v1.3.md`

---

## 1. Principles of Lawful Access & Data Ethics

UniSelection operates under strict adherence to legal, regulatory, and ethical standards for higher education data acquisition. Access to public university portals, regulatory registers, and open scholarly APIs is governed by the following non-negotiable principles:

1. **Lawful Access as a Prerequisite:** Ingestion connectors are constructed exclusively using publicly accessible, unauthenticated endpoints or authorized APIs. Circumventing access restrictions, bypass mechanisms, CAPTCHAs, paywalls, or authenticated portals is strictly forbidden.
2. **Robots Exclusion Standard (`robots.txt`):** Prior to making HTTP requests to any domain, the ingestion engine inspects `/robots.txt`. If a path is disallowed for the user agent or globally (`Disallow: /`), automated crawling of that path is suppressed and flagged for manual editorial review.
3. **Respect for Website Terms of Service:** If a platform's terms of use explicitly prohibit automated extraction, UniSelection does not build a disguised scraper. Instead, lawful alternatives (authorized open datasets, direct university feeds, or public regulatory filings) are utilized.
4. **Attribution & Provenance:** Every piece of factual data collected retains its lineage: original source URL, source organization, access timestamp, and cryptographic content hash.
5. **Data Minimization:** No personal data (student records, personal emails, phone numbers of individual professors, or applicant dossiers) is ever scraped or stored. Only public, institutional facts (institution names, addresses, accreditations, degree titles, published fees, and official deadlines) are retained.
6. **Copyright & Database Rights:** UniSelection collects only non-copyrightable factual data points (dates, amounts, criteria, names) and minimal bibliographic citation metadata. Full copyrighted prospectuses, brochures, and marketing narratives are never republished or mirrored.

---

## 2. Technical Crawling Standards & Politeness Controls

To prevent server load or disruption to educational institutions, the ingestion engine implements strict politeness controls:

```
┌──────────────────────────────────────────────────────────────┐
│                  Polite Crawling Pipeline                    │
│                                                              │
│  [URL Request]                                               │
│       │                                                      │
│       ├── 1. Check robots.txt (Disallowed? → Abort & Flag)   │
│       ├── 2. Rate Limiter (Token bucket: 0.5 – 1.0 req/sec)   │
│       ├── 3. Custom Descriptive User-Agent Attached           │
│       ├── 4. Conditional Headers (If-None-Match / ETag)       │
│       ├── 5. Timeout Guard (10-15s per request)              │
│       ├── 6. HTTP 429 / 503 → Exponential Backoff (2^n secs) │
│       └── 7. Safe Failure Handler (Source fails → DB safe)   │
└──────────────────────────────────────────────────────────────┘
```

### 2.1 User-Agent Identification
All automated requests must identify themselves clearly with an explicit user agent containing contact information:
```http
User-Agent: UniSelection-DataBot/1.0 (+https://github.com/Hamdanali3/Uni_Selection; educational research & student guidance; contact: data-transparency@uniselection.pk)
```

### 2.2 Rate Limiting & Concurrency
- **Maximum Request Rate:** 1.0 request per second per target domain (0.5 RPS for government/regulatory portals).
- **Concurrency:** Maximum of 1 concurrent connection per host.
- **Request Jitter:** Random sleep intervals (500ms to 1500ms) injected between sequential requests.

### 2.3 Conditional HTTP Requests
To eliminate redundant bandwidth consumption, connectors send conditional HTTP headers when re-checking sources:
- `If-None-Match`: Carries the previous `ETag`. If the source returns `304 Not Modified`, zero payload is transferred.
- `If-Modified-Since`: Carries the previous `Last-Modified` timestamp.

### 2.4 Backoff and Retry Policy
- Retries: Maximum of 3 attempts with exponential backoff: 2s, 4s, 8s.
- On HTTP 429 (Too Many Requests): Pause operations on that domain for the duration specified in the `Retry-After` header (or a default of 60 seconds).
- On persistent HTTP 5xx or connection timeout: Mark connector status as `degraded` and log an operational alert without deleting existing database records.

---

## 3. Source-by-Source Licensing & Permitted Access Policy

| Source Category | Representative Sources | Permitted Ingestion Method | Licensing & Legal Ground | Allowed Usage in UniSelection |
|---|---|---|---|---|
| **Statutory Regulators (Pakistan)** | HEC Pakistan (`hec.gov.pk`), PEC, PMDC, NCEAC | Polite HTML fetch of public statutory lists; CSV imports | Public statutory records under Pakistani Freedom of Information Act / Public Notices | Official recognition proof, campus accreditation, foreign HEI rules |
| **Open Scholarly Registries** | ROR (`ror.org`), OpenAlex (`openalex.org`) | REST API with query parameters | Creative Commons Zero (CC0 1.0 Universal) / Open Database License | Worldwide institutional discovery, persistent IDs, parent-child hierarchies |
| **Statutory Regulators (Global)** | UK OfS, Australia CRICOS, US Dept of Ed | Public registry search, open data downloads | Government Open Data Licenses (OGL, Public Domain) | National institutional accreditation and degree-granting verification |
| **Official University Portals** | Official university websites (`.edu.pk`, `.ac.uk`, `.edu`) | Polite HTML fetch of public admission/prospectus pages | Factual public notice / Fair dealing for informational guidance | Programme titles, published deadlines, fee schedules, eligibility criteria |
| **Educational Aggregators** | Eduvision (`eduvision.edu.pk`), Eduhubpak (`eduhubpak.com`), PakUniFinder (`pakunifinder.com`) | Polite discovery check only; no bulk extraction | Proprietary / All Rights Reserved | Candidate URL discovery and secondary cross-verification only; never treated as primary regulatory proof |

---

## 4. Prohibited Activities

The following practices are expressly prohibited in UniSelection:
1. **No Circumvention:** Never defeat Cloudflare, Akamai, or custom anti-bot systems via header spoofing, proxy rotation networks, or CAPTCHA-solving APIs.
2. **No Bulk Scrapes of Aggregators:** Do not mirror, scrape in bulk, or reproduce database compilations from commercial educational aggregators.
3. **No Private/Intranet Extraction:** Never attempt to access student management systems, LMS portals (Canvas, Moodle, Blackboard), or faculty intranets.
4. **No Deep Document Parsing of Unverified Files:** PDFs over 25MB or binary archives are not downloaded automatically to prevent memory exhaustion and bandwidth misuse.
5. **No Data Modification at Source:** Ingestion connectors are strictly read-only (`GET` and `HEAD` requests only).

---

## 5. Takedown & Webmaster Inquiries

If any university webmaster or copyright holder requests exclusion or rate-limit adjustments:
- Contact: `data-transparency@uniselection.pk`
- The domain connector can be immediately disabled via `UPDATE source_connectors SET status = 'disabled' WHERE base_url LIKE '%domain%'`.
- Data points derived from that source will be flagged for manual re-verification against alternate statutory portals.
