"""
UniSelection — Global University Intelligence Feasibility Audit
Audits network availability, HTTP status, headers, robots.txt, ETag/Last-Modified support,
and rate limits for candidate sources.
"""

import sys
import json
import urllib.parse
from datetime import datetime
import requests

CANDIDATE_SOURCES = [
    {
        "id": "eduvision",
        "name": "Eduvision Pakistan",
        "url": "https://www.eduvision.edu.pk/",
        "robots_url": "https://www.eduvision.edu.pk/robots.txt",
        "category": "Aggregator (Pakistan)",
        "expected_role": "Discovery / Cross-checking"
    },
    {
        "id": "vision_edu",
        "name": "Vision University / Web",
        "url": "https://www.vision.edu/web/",
        "robots_url": "https://www.vision.edu/robots.txt",
        "category": "Institutional Portal (Single Institution)",
        "expected_role": "Individual Institution Website (Not a General Directory)"
    },
    {
        "id": "eduhubpak",
        "name": "EduHub Pakistan",
        "url": "https://eduhubpak.com/",
        "robots_url": "https://eduhubpak.com/robots.txt",
        "category": "Aggregator (Pakistan)",
        "expected_role": "Discovery / Candidate URLs"
    },
    {
        "id": "pakunifinder",
        "name": "PakUniFinder",
        "url": "https://www.pakunifinder.com/",
        "robots_url": "https://www.pakunifinder.com/robots.txt",
        "category": "Aggregator (Pakistan)",
        "expected_role": "Discovery / Candidate URLs"
    },
    {
        "id": "hec_campuses",
        "name": "HEC Recognized Campuses",
        "url": "https://www.hec.gov.pk/english/universities/Pages/DAIs/HEC-recognized-Campuses.aspx",
        "robots_url": "https://www.hec.gov.pk/robots.txt",
        "category": "Statutory Authority (Pakistan)",
        "expected_role": "Statutory Campus Recognition Authority"
    },
    {
        "id": "hec_accreditation",
        "name": "HEC Accreditation Section",
        "url": "https://www.hec.gov.pk/english/services/universities/Pages/Accreditation.aspx",
        "robots_url": "https://www.hec.gov.pk/robots.txt",
        "category": "Statutory Authority (Pakistan)",
        "expected_role": "Statutory Institutional Accreditation Policy"
    },
    {
        "id": "hec_foreign_heis",
        "name": "HEC Foreign HEIs Recognition Procedure",
        "url": "https://www.hec.gov.pk/english/services/students/DES/Pages/Procedure/Foreign-HEIs.aspx",
        "robots_url": "https://www.hec.gov.pk/robots.txt",
        "category": "Statutory Authority (Pakistan)",
        "expected_role": "Statutory Foreign Recognition Criteria"
    },
    {
        "id": "ror_api",
        "name": "Research Organization Registry (ROR) API",
        "url": "https://api.ror.org/v2/organizations?query=National%20University%20of%20Sciences",
        "robots_url": "https://ror.org/robots.txt",
        "category": "Open Global Registry (International)",
        "expected_role": "Global Institution Discovery & Persistent Identifiers (ROR ID)"
    },
    {
        "id": "openalex_api",
        "name": "OpenAlex Institutions API",
        "url": "https://api.openalex.org/institutions?search=NUST&per-page=3",
        "robots_url": "https://openalex.org/robots.txt",
        "category": "Open Scholarly Registry (International)",
        "expected_role": "Global Institution Discovery & Persistent Identifiers (OpenAlex ID)"
    }
]

HEADERS = {
    "User-Agent": "UniSelection-Auditor/1.0 (+https://github.com/Hamdanali3/Uni_Selection; educational research; contact: dev@uniselection.pk)"
}

def audit_source(source):
    result = {
        "id": source["id"],
        "name": source["name"],
        "url": source["url"],
        "category": source["category"],
        "expected_role": source["expected_role"],
        "tested_at": datetime.utcnow().isoformat() + "Z",
        "http_status": None,
        "robots_status": None,
        "robots_allows": True,
        "has_etag": False,
        "has_last_modified": False,
        "content_type": None,
        "response_time_ms": None,
        "notes": []
    }

    # 1. Test Robots.txt
    try:
        r_robots = requests.get(source["robots_url"], headers=HEADERS, timeout=8)
        result["robots_status"] = r_robots.status_code
        if r_robots.status_code == 200:
            lines = [line.strip().lower() for line in r_robots.text.splitlines() if line.strip()]
            disallows = [line for line in lines if line.startswith("disallow: /")]
            if disallows:
                result["notes"].append(f"Robots.txt has {len(disallows)} global/root disallow rules")
            else:
                result["notes"].append("Robots.txt allows polite crawling")
        else:
            result["notes"].append(f"Robots.txt returned HTTP {r_robots.status_code}")
    except Exception as e:
        result["robots_status"] = "ERROR"
        result["notes"].append(f"Robots.txt check failed: {type(e).__name__}")

    # 2. Test Main Endpoint / API
    try:
        start_t = datetime.now()
        r_main = requests.get(source["url"], headers=HEADERS, timeout=12)
        duration = (datetime.now() - start_t).total_seconds() * 1000
        result["http_status"] = r_main.status_code
        result["response_time_ms"] = round(duration, 1)
        result["content_type"] = r_main.headers.get("Content-Type", "")
        result["has_etag"] = "ETag" in r_main.headers or "etag" in r_main.headers
        result["has_last_modified"] = "Last-Modified" in r_main.headers or "last-modified" in r_main.headers

        if r_main.status_code == 200:
            result["notes"].append("Endpoint reachable and returning 200 OK")
            if "application/json" in result["content_type"]:
                result["notes"].append("Structured JSON API response verified")
            elif "text/html" in result["content_type"]:
                result["notes"].append("HTML page content verified")
        elif r_main.status_code in (401, 403):
            result["notes"].append(f"Access restricted / Cloudflare protection (HTTP {r_main.status_code})")
        else:
            result["notes"].append(f"Returned unexpected HTTP status: {r_main.status_code}")
    except Exception as e:
        result["http_status"] = "ERROR"
        result["notes"].append(f"Connection failed: {type(e).__name__} ({str(e)[:100]})")

    return result

def main():
    print("=" * 70)
    print("UniSelection — Source Feasibility Audit Running...")
    print("=" * 70)

    audit_results = []
    for src in CANDIDATE_SOURCES:
        print(f"[*] Auditing {src['name']} ({src['url']})...")
        res = audit_source(src)
        audit_results.append(res)
        print(f"    -> Status: HTTP {res['http_status']} | Robots: {res['robots_status']} | Time: {res['response_time_ms']}ms")
        for note in res["notes"]:
            print(f"       • {note}")

    out_path = "data/sync/source_feasibility_results.json"
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(audit_results, f, indent=2)

    print("=" * 70)
    print(f"[V] Audit complete! Results saved to {out_path}")
    print("=" * 70)

if __name__ == "__main__":
    main()
