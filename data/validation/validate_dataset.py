#!/usr/bin/env python3
"""
UniSelection Data Ingestion & Quality Validation Script
Module: M15 (Data Import and Validation)
Scope: Phase 1 Master Scope v1.2
"""

import json
import os
import sys
import re
from urllib.parse import urlparse
from datetime import datetime

URL_REGEX = re.compile(
    r'^(?:http|ftp)s?://'  # http:// or https://
    r'(?:(?:[A-Z0-9](?:[A-Z0-9-]{0,61}[A-Z0-9])?\.)+(?:[A-Z]{2,6}\.?|[A-Z0-9-]{2,}\.?)|'  # domain...
    r'localhost|'  # localhost...
    r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})'  # ...or ip
    r'(?::\d+)?'  # optional port
    r'(?:/?|[/?]\S+)$', re.IGNORECASE)

def is_valid_url(url: str) -> bool:
    if not url or not isinstance(url, str):
        return False
    return bool(URL_REGEX.match(url.strip()))

def is_valid_date(date_str: str) -> bool:
    if not date_str:
        return False
    try:
        datetime.strptime(date_str, "%Y-%m-%d")
        return True
    except ValueError:
        return False

def validate_starter_dataset(file_path: str):
    print(f"[*] Validating starter dataset: {file_path}")
    if not os.path.exists(file_path):
        print(f"[!] Error: File does not exist at {file_path}")
        return False

    with open(file_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    errors = []
    warnings = []

    # Check root sections
    expected_sections = [
        "countries", "cities", "categories", "disciplines",
        "institutions", "campuses", "programmes",
        "eligibility_rules", "admissions", "fee_records"
    ]
    for section in expected_sections:
        if section not in data:
            errors.append(f"Missing root section: '{section}'")

    country_ids = {c["id"] for c in data.get("countries", [])}
    city_ids = {c["id"] for c in data.get("cities", [])}
    category_ids = {c["id"] for c in data.get("categories", [])}
    discipline_ids = {d["id"] for d in data.get("disciplines", [])}
    institution_ids = {inst["id"] for inst in data.get("institutions", [])}
    campus_ids = {cmp["id"] for cmp in data.get("campuses", [])}
    programme_ids = {p["id"] for p in data.get("programmes", [])}

    # 1. Countries
    for c in data.get("countries", []):
        if len(c.get("id", "")) != 3:
            errors.append(f"Country ID '{c.get('id')}' must be 3-letter ISO code.")

    # 2. Cities
    for city in data.get("cities", []):
        if city.get("country_id") not in country_ids:
            errors.append(f"City '{city.get('name')}' references unknown country_id '{city.get('country_id')}'")

    # 3. Disciplines
    for disc in data.get("disciplines", []):
        if disc.get("category_id") not in category_ids:
            errors.append(f"Discipline '{disc.get('name')}' references unknown category_id '{disc.get('category_id')}'")

    # 4. Institutions
    for inst in data.get("institutions", []):
        inst_id = inst.get("id")
        if not inst.get("name"):
            errors.append(f"Institution '{inst_id}' missing required 'name'")
        if inst.get("country_id") not in country_ids:
            errors.append(f"Institution '{inst_id}' references invalid country_id '{inst.get('country_id')}'")
        if inst.get("city_id") and inst.get("city_id") not in city_ids:
            errors.append(f"Institution '{inst_id}' references invalid city_id '{inst.get('city_id')}'")
        if not is_valid_url(inst.get("official_website", "")):
            errors.append(f"Institution '{inst_id}' has invalid official_website URL: '{inst.get('official_website')}'")
        if inst.get("admissions_url") and not is_valid_url(inst.get("admissions_url")):
            errors.append(f"Institution '{inst_id}' has invalid admissions_url: '{inst.get('admissions_url')}'")
        if not is_valid_date(inst.get("last_verified_at", "")):
            errors.append(f"Institution '{inst_id}' missing or invalid last_verified_at date.")
        for cat in inst.get("category_ids", []):
            if cat not in category_ids:
                errors.append(f"Institution '{inst_id}' references unknown category '{cat}'")

    # 5. Campuses
    for campus in data.get("campuses", []):
        cmp_id = campus.get("id")
        if campus.get("institution_id") not in institution_ids:
            errors.append(f"Campus '{cmp_id}' references invalid institution_id '{campus.get('institution_id')}'")
        if campus.get("city_id") not in city_ids:
            errors.append(f"Campus '{cmp_id}' references invalid city_id '{campus.get('city_id')}'")

    # 6. Programmes
    for prog in data.get("programmes", []):
        p_id = prog.get("id")
        if prog.get("institution_id") not in institution_ids:
            errors.append(f"Programme '{p_id}' references invalid institution_id '{prog.get('institution_id')}'")
        if prog.get("campus_id") and prog.get("campus_id") not in campus_ids:
            errors.append(f"Programme '{p_id}' references invalid campus_id '{prog.get('campus_id')}'")
        if prog.get("discipline_id") not in discipline_ids:
            errors.append(f"Programme '{p_id}' references invalid discipline_id '{prog.get('discipline_id')}'")
        if not is_valid_url(prog.get("official_url", "")):
            errors.append(f"Programme '{p_id}' has invalid official_url: '{prog.get('official_url')}'")
        if not is_valid_date(prog.get("last_verified_at", "")):
            errors.append(f"Programme '{p_id}' missing or invalid last_verified_at date.")

    # 7. Eligibility Rules
    for elg in data.get("eligibility_rules", []):
        elg_id = elg.get("id")
        if elg.get("programme_id") not in programme_ids:
            errors.append(f"Eligibility rule '{elg_id}' references invalid programme_id '{elg.get('programme_id')}'")
        if not elg.get("rule_explanation"):
            errors.append(f"Eligibility rule '{elg_id}' missing rule_explanation.")
        if not elg.get("caveat"):
            warnings.append(f"Eligibility rule '{elg_id}' missing legal caveat.")
        if not is_valid_url(elg.get("source_url", "")):
            errors.append(f"Eligibility rule '{elg_id}' has invalid source_url: '{elg.get('source_url')}'")

    # 8. Admissions
    for adm in data.get("admissions", []):
        adm_id = adm.get("id")
        if adm.get("institution_id") not in institution_ids:
            errors.append(f"Admission cycle '{adm_id}' references invalid institution_id '{adm.get('institution_id')}'")
        if not is_valid_url(adm.get("source_url", "")):
            errors.append(f"Admission cycle '{adm_id}' has invalid source_url: '{adm.get('source_url')}'")
        if not is_valid_date(adm.get("last_verified_at", "")):
            errors.append(f"Admission cycle '{adm_id}' missing valid last_verified_at date.")

    # 9. Fee Records
    for fee in data.get("fee_records", []):
        fee_id = fee.get("id")
        if fee.get("programme_id") not in programme_ids:
            errors.append(f"Fee record '{fee_id}' references invalid programme_id '{fee.get('programme_id')}'")
        if fee.get("tuition_fee", 0) < 0:
            errors.append(f"Fee record '{fee_id}' has negative tuition fee.")
        if not fee.get("currency"):
            errors.append(f"Fee record '{fee_id}' missing currency.")
        if not is_valid_url(fee.get("source_url", "")):
            errors.append(f"Fee record '{fee_id}' has invalid source_url: '{fee.get('source_url')}'")

    # Print summary
    print(f"[*] Total Institutions verified: {len(data.get('institutions', []))}")
    print(f"[*] Total Programmes verified: {len(data.get('programmes', []))}")
    print(f"[*] Total Eligibility Rules verified: {len(data.get('eligibility_rules', []))}")
    print(f"[*] Total Admission Cycles verified: {len(data.get('admissions', []))}")
    print(f"[*] Total Fee Records verified: {len(data.get('fee_records', []))}")

    if warnings:
        print(f"\n[!] {len(warnings)} Warnings:")
        for w in warnings:
            print(f"  - {w}")

    if errors:
        print(f"\n[X] Validation FAILED with {len(errors)} Errors:")
        for e in errors:
            print(f"  - {e}")
        return False
    else:
        print("\n[V] Dataset Validation PASSED with 0 errors!")
        return True

if __name__ == "__main__":
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    target_json = os.path.join(base_dir, "..", "backend", "seed", "starter_dataset.json")
    success = validate_starter_dataset(target_json)
    sys.exit(0 if success else 1)
