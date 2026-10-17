"""
UniSelection — Synchronization Orchestrator
Coordinates ingestion across sources, executes deduplication, performs
change detection, applies risk classification, and manages the review queue.
"""

import json
import uuid
from datetime import datetime, timezone
from pathlib import Path
from .hec_baseline_connector import HECBaselineConnector
from .ror_global_connector import RORGlobalConnector
from .deduplicator import Deduplicator
from .change_detector import ChangeDetector
from .review_classifier import ReviewClassifier
from .quality_validator import QualityValidator
from .exporter import DataExporter

class SyncOrchestrator:
    REPO_ROOT = Path(__file__).resolve().parent.parent.parent
    SEED_PATH = REPO_ROOT / "backend" / "seed" / "starter_dataset.json"

    def __init__(self):
        self.hec_connector = HECBaselineConnector()
        self.ror_connector = RORGlobalConnector()
        self.deduplicator = Deduplicator()
        self.change_detector = ChangeDetector()
        self.validator = QualityValidator()

    def load_current_dataset(self) -> dict:
        """Loads the current authoritative seed dataset."""
        if not self.SEED_PATH.exists():
            return {}
        with open(self.SEED_PATH, "r", encoding="utf-8") as f:
            return json.load(f)

    def run_full_sync(self, dry_run: bool = False, query: str = None) -> dict:
        """
        Executes end-to-end synchronization:
        1. Ingests HEC baseline (Layer B)
        2. Ingests Global ROR baseline (Layer A)
        3. Deduplicates entities
        4. Detects field diffs against current dataset
        5. Classifies risk & populates review queue
        6. Validates data quality
        7. Exports updated state (if not dry_run)
        """
        sync_run_id = str(uuid.uuid4())
        started_at = datetime.now(timezone.utc).isoformat()
        current_data = self.load_current_dataset()

        existing_institutions = {inst["id"]: inst for inst in current_data.get("institutions", [])}
        existing_inst_list = list(existing_institutions.values())

        # Step 1: Ingest Pakistani HEC Baseline
        hec_result = self.hec_connector.load_and_reconcile()
        hec_institutions = hec_result["institutions"]
        hec_campuses = hec_result["campuses"]

        # Step 2: Ingest Global ROR Discovery
        ror_institutions = self.ror_connector.discover_global_universities(query=query)

        # Step 3: Deduplication & Merge
        merged_institutions = []
        change_events = []
        review_queue = []
        records_discovered = len(hec_institutions) + len(ror_institutions)
        records_updated = 0
        matched_existing_ids = set()

        all_incoming = hec_institutions + ror_institutions

        for incoming in all_incoming:
            matched, method, confidence = self.deduplicator.resolve_institution_match(
                incoming, existing_inst_list
            )

            if matched and method != "candidate_review":
                matched_existing_ids.add(matched["id"])
                # Entity exists -> detect diffs
                diffs = self.change_detector.detect_institution_diffs(
                    incoming, matched, source_id=incoming.get("source_id", "sync"), sync_run_id=sync_run_id
                )
                record_had_update = False
                for diff in diffs:
                    risk_level, status = ReviewClassifier.classify_change(diff)
                    diff["risk_level"] = risk_level
                    diff["status"] = status
                    change_events.append(diff)

                    if status == "pending":
                        review_queue.append({
                            "id": str(uuid.uuid4()),
                            "change_event_id": diff["id"],
                            "entity_id": diff["entity_id"],
                            "field_name": diff["field_name"],
                            "old_value": diff["old_value"],
                            "new_value": diff["new_value"],
                            "risk_level": risk_level,
                            "diff_reason": diff["diff_reason"],
                            "created_at": diff["created_at"],
                            "status": "pending"
                        })
                    elif status == "auto_published":
                        matched[diff["field_name"]] = incoming[diff["field_name"]]
                        record_had_update = True

                if record_had_update:
                    records_updated += 1

                # Update freshness metadata
                matched["last_checked_at"] = incoming.get("last_checked_at", matched.get("last_checked_at"))
                matched["data_freshness_status"] = incoming.get("data_freshness_status", "current")
                merged_institutions.append(matched)
            else:
                # If candidate review, flag potential ambiguity for human review
                if matched and method == "candidate_review":
                    review_queue.append({
                        "id": str(uuid.uuid4()),
                        "change_event_id": str(uuid.uuid4()),
                        "entity_id": incoming.get("id"),
                        "field_name": "entity_identity",
                        "old_value": matched.get("name", ""),
                        "new_value": incoming.get("name", ""),
                        "risk_level": "medium",
                        "diff_reason": f"Potential duplicate identity ({confidence}% similarity with {matched.get('name')})",
                        "created_at": datetime.now(timezone.utc).isoformat(),
                        "status": "pending"
                    })

                # New institution discovered
                merged_institutions.append(incoming)
                records_updated += 1

        # Preserve existing institutions that were not part of this incoming feed
        for inst in existing_inst_list:
            if inst["id"] not in matched_existing_ids:
                merged_institutions.append(inst)

        # Deduplicate merged list by ID
        unique_institutions = {}
        for inst in merged_institutions:
            unique_institutions[inst["id"]] = inst
        final_institutions = list(unique_institutions.values())

        # Ensure international countries and cities are registered
        countries = list(current_data.get("countries", []))
        country_ids = {c["id"] for c in countries}
        additional_countries = [
            {"id": "NZL", "name": "New Zealand", "currency_code": "NZD"},
            {"id": "CHE", "name": "Switzerland", "currency_code": "CHF"},
            {"id": "SAU", "name": "Saudi Arabia", "currency_code": "SAR"},
            {"id": "FRA", "name": "France", "currency_code": "EUR"},
            {"id": "CHN", "name": "China", "currency_code": "CNY"},
        ]
        for ac in additional_countries:
            if ac["id"] not in country_ids:
                countries.append(ac)
                country_ids.add(ac["id"])

        cities = list(current_data.get("cities", []))
        city_ids = {c["id"] for c in cities}
        additional_cities = [
            {"id": "c-akl", "name": "Auckland", "country_id": "NZL"},
            {"id": "c-zrh", "name": "Zurich", "country_id": "CHE"},
            {"id": "c-thw", "name": "Thuwal", "country_id": "SAU"},
            {"id": "c-par", "name": "Paris", "country_id": "FRA"},
            {"id": "c-bjg", "name": "Beijing", "country_id": "CHN"},
        ]
        for ac in additional_cities:
            if ac["id"] not in city_ids:
                cities.append(ac)
                city_ids.add(ac["id"])

        # Build complete output dataset preserving existing programmes, admissions, fees, scholarships
        output_dataset = {
            "countries": countries,
            "cities": cities,
            "categories": current_data.get("categories", []),
            "disciplines": current_data.get("disciplines", []),
            "institutions": final_institutions,
            "campuses": current_data.get("campuses", []),
            "programmes": current_data.get("programmes", []),
            "eligibility_rules": current_data.get("eligibility_rules", []),
            "admissions": current_data.get("admissions", []),
            "fee_records": current_data.get("fee_records", []),
            "scholarships": current_data.get("scholarships", []),
            "sync_runs": current_data.get("sync_runs", []),
            "review_queue": current_data.get("review_queue", [])
        }

        # Step 4: Validate Data Quality
        valid_inst_ids = {inst["id"] for inst in final_institutions}
        validation_errors = []
        for inst in final_institutions:
            validation_errors.extend(self.validator.validate_institution(inst))

        # Record this Sync Run
        sync_record = {
            "id": sync_run_id,
            "trigger_type": "manual" if query else "scheduled",
            "started_at": started_at,
            "completed_at": datetime.now(timezone.utc).isoformat(),
            "status": "completed" if not validation_errors else "completed_with_warnings",
            "records_discovered": records_discovered,
            "records_ingested": len(final_institutions),
            "records_updated": records_updated,
            "change_proposals_created": len(review_queue),
            "error_log": "\n".join(validation_errors[:5]) if validation_errors else ""
        }
        output_dataset["sync_runs"].insert(0, sync_record)
        output_dataset["review_queue"].extend(review_queue)

        # Export if not dry-run
        if not dry_run:
            DataExporter.export_all(output_dataset)

        return {
            "sync_run_id": sync_run_id,
            "records_discovered": records_discovered,
            "records_ingested": len(final_institutions),
            "records_updated": records_updated,
            "change_events_generated": len(change_events),
            "review_queue_items": len(review_queue),
            "validation_errors_count": len(validation_errors),
            "status": sync_record["status"]
        }
