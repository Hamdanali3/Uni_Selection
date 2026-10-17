"""
UniSelection — Comprehensive Pytest Test Suite for M23 Data Intelligence & Sync Engine
"""

import pytest
from datetime import datetime
from data.sync.normalizer import (
    clean_unicode,
    normalize_slug_id,
    extract_acronym_and_name,
    normalize_country_code,
    normalize_province,
    normalize_currency,
    normalize_degree_level,
    normalize_url
)
from data.sync.deduplicator import Deduplicator
from data.sync.change_detector import ChangeDetector
from data.sync.review_classifier import ReviewClassifier
from data.sync.quality_validator import QualityValidator
from data.sync.hec_baseline_connector import HECBaselineConnector
from data.sync.ror_global_connector import RORGlobalConnector
from data.sync.sync_orchestrator import SyncOrchestrator

def test_normalizer_functions():
    assert clean_unicode("  National University \u2013 NUST  ") == "National University – NUST"
    assert normalize_slug_id("Aga Khan University") == "aga-khan-university"
    assert normalize_country_code("Pakistan") == "PAK"
    assert normalize_country_code("United States") == "USA"
    assert normalize_country_code("United Kingdom") == "GBR"
    assert normalize_province("KPK") == "Khyber Pakhtunkhwa"
    assert normalize_province("Punjab") == "Punjab"
    assert normalize_currency("pkr") == "PKR"
    assert normalize_currency("USD") == "USD"
    assert normalize_degree_level("BSc") == "Undergraduate"
    assert normalize_degree_level("Master") == "Postgraduate"

def test_url_normalization():
    assert normalize_url("http://nust.edu.pk/") == "http://nust.edu.pk"
    assert normalize_url("http://http://www.sbbusba.edu.pk") == "http://www.sbbusba.edu.pk"
    assert normalize_url("under process") == ""
    assert normalize_url("under construction") == ""
    assert normalize_url("https://www.lums.edu.pk") == "https://www.lums.edu.pk"

def test_acronym_extraction():
    name, acronym = extract_acronym_and_name("National University of Sciences & Technology (NUST)")
    assert name == "National University of Sciences & Technology"
    assert acronym == "NUST"

    name2, acronym2 = extract_acronym_and_name("Lahore University of Management Sciences")
    assert name2 == "Lahore University of Management Sciences"
    assert acronym2 == ""

def test_deduplicator_exact_and_domain():
    d = Deduplicator()
    existing = [
        {"id": "nust", "name": "National University of Sciences and Technology", "official_website": "https://www.nust.edu.pk", "country_id": "PAK", "city": "Islamabad"},
        {"id": "lums", "name": "Lahore University of Management Sciences", "official_website": "https://www.lums.edu.pk", "country_id": "PAK", "city": "Lahore"},
        {"id": "oxford", "name": "University of Oxford", "official_website": "https://www.ox.ac.uk", "country_id": "GBR", "ror_id": "https://ror.org/052gg0110", "city": "Oxford"}
    ]

    # Exact ID
    m, method, conf = d.resolve_institution_match({"id": "nust", "name": "NUST"}, existing)
    assert m["id"] == "nust"
    assert method == "exact_id"

    # Exact ROR
    m, method, conf = d.resolve_institution_match({"name": "Oxford", "ror_id": "https://ror.org/052gg0110"}, existing)
    assert m["id"] == "oxford"
    assert method == "exact_ror"

    # Domain match
    m, method, conf = d.resolve_institution_match({"name": "NUST Main", "official_website": "http://nust.edu.pk", "country_id": "PAK", "city": "Islamabad"}, existing)
    assert m["id"] == "nust"
    assert method == "domain_match"

def test_deduplicator_prevents_false_merges():
    d = Deduplicator()
    existing = [
        {"id": "bacha-khan", "name": "Bacha Khan University", "official_website": "http://www.bkuc.edu.pk", "country_id": "PAK", "city": "Charsada"},
        {"id": "gcuf", "name": "Government College University, Faisalabad", "official_website": "http://www.gcuf.edu.pk", "country_id": "PAK", "city": "Faisalabad"}
    ]

    # Aga Khan must NOT merge into Bacha Khan
    cand_aku = {"id": "aga-khan", "name": "Aga Khan University", "official_website": "http://www.aku.edu", "country_id": "PAK", "city": "Karachi"}
    m, method, conf = d.resolve_institution_match(cand_aku, existing)
    assert m is None or method == "candidate_review"
    if m:
        assert m["id"] != "bacha-khan" or method != "fuzzy_name"

    # Government College for Women must NOT merge into GCUF
    cand_women = {"id": "gcwuf", "name": "Government College for Women University, Faisalabad", "official_website": "http://www.gcwuf.edu.pk", "country_id": "PAK", "city": "Faisalabad"}
    m, method, conf = d.resolve_institution_match(cand_women, existing)
    assert m is None

def test_change_detector_and_review_classifier():
    detector = ChangeDetector()

    # Deadline shift
    existing_adm = {"id": "adm-1", "application_close_date": "2026-06-30"}
    incoming_adm = {"id": "adm-1", "application_close_date": "2026-07-15"}
    diffs = detector.detect_admission_diffs(incoming_adm, existing_adm, source_id="test")
    assert len(diffs) == 1
    risk, status = ReviewClassifier.classify_change(diffs[0])
    assert risk == "high"
    assert status == "pending"

    # Accreditation change (Critical risk)
    diff = {
        "field_name": "accreditation_body",
        "entity_type": "institution",
        "old_value": "HEC",
        "new_value": "Unaccredited",
        "confidence_score": 90.0
    }
    risk, status = ReviewClassifier.classify_change(diff)
    assert risk == "critical"
    assert status == "pending"

    # Tuition fee jump > 10%
    diff_fee = {
        "field_name": "amount",
        "entity_type": "fee_record",
        "old_value": "100000",
        "new_value": "150000",
        "confidence_score": 98.0
    }
    risk, status = ReviewClassifier.classify_change(diff_fee)
    assert risk == "high"
    assert status == "pending"

def test_quality_validator_rules():
    validator = QualityValidator()

    # Valid institution
    valid_inst = {
        "id": "test-uni",
        "name": "Test University",
        "country_id": "PAK",
        "institution_type": "Public",
        "hec_recognized": True,
        "accreditation_body": "HEC",
        "official_website": "https://www.testuni.edu.pk",
        "last_verified_at": "2026-09-20"
    }
    assert validator.validate_institution(valid_inst) == []

    # Invalid: international marked HEC recognized
    invalid_inst = {
        "id": "intl-uni",
        "name": "International University",
        "country_id": "USA",
        "institution_type": "Private",
        "hec_recognized": True, # VIOLATION!
        "accreditation_body": "NECHE",
        "official_website": "https://www.intl.edu",
        "last_verified_at": "2026-09-20"
    }
    errors = validator.validate_institution(invalid_inst)
    assert any("International institution" in e for e in errors)

def test_hec_baseline_ingestion():
    connector = HECBaselineConnector()
    res = connector.load_and_reconcile()
    assert res["stats"]["total_institutions"] >= 260
    assert res["stats"]["accreditation_rate"] == 100.0

def test_ror_global_connector():
    connector = RORGlobalConnector()
    results = connector.discover_global_universities(limit=10)
    assert len(results) >= 10
    for r in results:
        assert r["hec_recognized"] is False
        assert r["accreditation_body"] != ""
        assert r["country_id"] != "PAK"

def test_sync_idempotency():
    orchestrator = SyncOrchestrator()
    # Pass 1
    res1 = orchestrator.run_full_sync(dry_run=False)
    assert res1["records_ingested"] >= 266

    # Pass 2 immediate re-sync
    res2 = orchestrator.run_full_sync(dry_run=True)
    assert res2["records_updated"] == 0
    assert res2["change_events_generated"] == 0
