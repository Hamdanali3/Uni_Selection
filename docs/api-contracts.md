# UniSelection — API Contracts & PostgREST Access Specifications

**Version:** 1.0  
**Scope Reference:** Section 9 of `UniSelection_Phase_1_Master_Scope_v1.2.md`

This document defines the REST API access contracts exposed by Supabase PostgREST and consumed by the Flutter mobile client.

---

## 1. Conventions & Global Headers

- **Base URL:** `https://<project-ref>.supabase.co/rest/v1`
- **Headers:**
  - `apikey: <SUPABASE_ANON_KEY>`
  - `Authorization: Bearer <SUPABASE_ANON_KEY>` (or User JWT when signed in)
  - `Content-Type: application/json`
  - `Prefer: return=representation` (on mutations)

---

## 2. Public Read Endpoints

### 2.1 Discover Institutions
- **Endpoint:** `GET /institutions`
- **Query Parameters:**
  - `select`: `*,cities(*),countries(*),institution_categories(categories(*))`
  - `country_id`: `eq.PAK` (or `neq.PAK` for international)
  - `institution_categories.category_id`: `eq.<category_uuid>`
  - `name`: `ilike.*keyword*`
  - `status`: `eq.published`
  - `order`: `name.asc`
  - `limit`: `20`
  - `offset`: `0`
- **Response Format (200 OK):**
```json
[
  {
    "id": "nust",
    "name": "National University of Sciences & Technology",
    "short_name": "NUST",
    "country_id": "PAK",
    "institution_type": "Public",
    "hec_recognized": true,
    "official_website": "https://nust.edu.pk",
    "admissions_url": "https://ugadmissions.nust.edu.pk",
    "status": "published",
    "last_verified_at": "2026-09-15",
    "cities": {
      "name": "Islamabad",
      "province_state": "Islamabad Capital Territory"
    },
    "institution_categories": [
      { "categories": { "name": "Engineering & Technology", "slug": "engineering" } },
      { "categories": { "name": "Computing & IT", "slug": "computing-it" } }
    ]
  }
]
```

### 2.2 Get Institution Details
- **Endpoint:** `GET /institutions?id=eq.<id>&select=*,cities(*),countries(*),campuses(*),institution_categories(categories(*))`
- **Response Format (200 OK):** Single object or array of 1 element.

### 2.3 List Programmes
- **Endpoint:** `GET /programmes`
- **Query Parameters:**
  - `institution_id`: `eq.<institution_id>`
  - `discipline_id`: `eq.<discipline_uuid>`
  - `degree_level`: `eq.Undergraduate`
  - `name`: `ilike.*query*`
- **Response Format (200 OK):** Array of programme objects including duration, study mode, and official prospectus link.

### 2.4 Get Eligibility Rules
- **Endpoint:** `GET /eligibility_rules?programme_id=eq.<programme_uuid>`
- **Response Format (200 OK):**
```json
[
  {
    "id": "4920257e-3759-4fa2-bfeb-ff646e3e5711",
    "programme_id": "8482025e-3759-4fa2-bfeb-ff646e3e5722",
    "rule_type": "min_percentage",
    "min_percentage": 60.00,
    "required_subjects": "Physics, Mathematics, Chemistry or Computer Science",
    "accepted_entry_tests": "NUST Entry Test (NET), SAT Subject / ACT",
    "rule_explanation": "Minimum 60% aggregate marks in HSSC / F.Sc (Pre-Engineering / ICS) or equivalent A-Level.",
    "caveat": "Meeting minimum eligibility does not guarantee admission. Final selection is based strictly on competitive merit weightage.",
    "effective_session": "2025-2026",
    "source_url": "https://ugadmissions.nust.edu.pk/eligibility",
    "last_verified_at": "2026-09-15"
  }
]
```

### 2.5 Get Admissions & Deadlines
- **Endpoint:** `GET /admissions?institution_id=eq.<id>&order=closing_date.asc`
- **Response Format (200 OK):** Array of session dates, opening/closing deadlines, test dates, and official source links.

### 2.6 Get Fee Records
- **Endpoint:** `GET /fee_records?programme_id=eq.<programme_uuid>`
- **Response Format (200 OK):** Array of fee records with tuition fee, billing basis, academic session, one-time dues, and prospectus source link.

---

## 3. User & Shortlist Endpoints (Authenticated)

### 3.1 Get User Shortlist
- **Endpoint:** `GET /saved_items?user_id=eq.<auth.uid()>`
- **Auth:** Requires User JWT (`Authorization: Bearer <jwt>`)

### 3.2 Add Item to Shortlist
- **Endpoint:** `POST /saved_items`
- **Body:**
```json
{
  "entity_type": "institution",
  "entity_id": "nust"
}
```

### 3.3 Remove Item from Shortlist
- **Endpoint:** `DELETE /saved_items?id=eq.<saved_item_id>`

---

## 4. Standard Error Codes

| HTTP Status | Error Code | Meaning | User Message |
|---|---|---|---|
| `400` | `PGRST100` | Invalid query filter or syntax | "Invalid search parameters." |
| `401` | `PGRST301` | JWT expired or invalid | "Session expired. Please log in again." |
| `403` | `42501` | RLS policy violation / unauthorized write | "Access denied. Action requires administrative permission." |
| `404` | `PGRST116` | Record not found | "Requested institution or programme was not found." |
| `500` | `PGRST500` | Database error | "Unable to load data. Showing offline verified information." |
