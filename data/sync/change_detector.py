"""
UniSelection — Change & Diff Detection Engine
Compares incoming entity records against current state, detects field-level diffs,
computes confidence scores, and generates structured change events.
"""

from datetime import datetime, timezone
import uuid

class ChangeDetector:
    IGNORED_FIELDS = {
        "id",
        "last_checked_at",
        "last_verified_at",
        "confidence_score",
        "data_freshness_status",
        "source_id",
        "source_url",
        "sync_run_id",
        "created_at",
        "updated_at"
    }

    @staticmethod
    def _is_equivalent(val1, val2) -> bool:
        if val1 == val2:
            return True
        if (val1 is None or val1 == "") and (val2 is None or val2 == ""):
            return True
        s1 = str(val1).strip()
        s2 = str(val2).strip()
        if s1 == s2:
            return True
        # Compare normalized URLs (ignore protocol differences and trailing slashes)
        if (s1.startswith("http://") or s1.startswith("https://")) and (s2.startswith("http://") or s2.startswith("https://")):
            if "http://" in s1[7:] or "https://" in s1[8:] or "http://" in s2[7:] or "https://" in s2[8:]:
                return False
            clean1 = s1.replace("http://", "").replace("https://", "").rstrip("/").lower()
            clean2 = s2.replace("http://", "").replace("https://", "").rstrip("/").lower()
            return clean1 == clean2
        # Equivalent accreditation body synonyms
        hec_synonyms = {"hec", "higher education commission (hec) pakistan", "higher education commission"}
        if s1.lower() in hec_synonyms and s2.lower() in hec_synonyms:
            return True
        us_accreditors = {"neche", "sacscoc", "wasc", "wscuc", "hlc"}
        if any(a in s1.lower() for a in us_accreditors) and any(a in s2.lower() for a in us_accreditors):
            return True
        if "ministry" in s1.lower() and "ministry" in s2.lower():
            return True
        for acronym in ("ofs", "teqsa", "cicic", "yök", "mqa"):
            if acronym in s1.lower() and acronym in s2.lower():
                return True
        return False

    def detect_institution_diffs(
        self,
        incoming: dict,
        existing: dict,
        source_id: str,
        sync_run_id: str = None
    ) -> list[dict]:
        """
        Compares incoming institution against existing record and generates diff events.
        """
        diff_events = []
        inst_id = existing.get("id") or incoming.get("id")

        for key, new_val in incoming.items():
            if key in self.IGNORED_FIELDS:
                continue

            old_val = existing.get(key)
            if not self._is_equivalent(old_val, new_val):
                diff_reason = f"Field '{key}' updated from source '{source_id}'"
                event = {
                    "id": str(uuid.uuid4()),
                    "sync_run_id": sync_run_id,
                    "source_id": source_id,
                    "entity_type": "institution",
                    "entity_id": inst_id,
                    "field_name": key,
                    "old_value": str(old_val) if old_val is not None else "",
                    "new_value": str(new_val) if new_val is not None else "",
                    "diff_reason": diff_reason,
                    "confidence_score": incoming.get("confidence_score", 95.0),
                    "created_at": datetime.now(timezone.utc).isoformat()
                }
                diff_events.append(event)

        return diff_events

    def detect_admission_diffs(
        self,
        incoming: dict,
        existing: dict,
        source_id: str,
        sync_run_id: str = None
    ) -> list[dict]:
        """Compares admission cycle records and detects deadline shifts."""
        diff_events = []
        adm_id = existing.get("id") or incoming.get("id")

        for key in ("application_open_date", "application_close_date", "status", "cycle_name"):
            old_val = existing.get(key)
            new_val = incoming.get(key)

            if old_val != new_val and (old_val is not None or new_val is not None):
                event = {
                    "id": str(uuid.uuid4()),
                    "sync_run_id": sync_run_id,
                    "source_id": source_id,
                    "entity_type": "admission",
                    "entity_id": adm_id,
                    "field_name": key,
                    "old_value": str(old_val) if old_val is not None else "",
                    "new_value": str(new_val) if new_val is not None else "",
                    "diff_reason": f"Admission '{key}' shift detected",
                    "confidence_score": incoming.get("confidence_score", 95.0),
                    "created_at": datetime.now(timezone.utc).isoformat()
                }
                diff_events.append(event)

        return diff_events

    def detect_fee_diffs(
        self,
        incoming: dict,
        existing: dict,
        source_id: str,
        sync_run_id: str = None
    ) -> list[dict]:
        """Compares fee schedules and detects price/currency changes."""
        diff_events = []
        fee_id = existing.get("id") or incoming.get("id")

        old_amount = float(existing.get("amount") or existing.get("tuition_fee") or 0.0)
        new_amount = float(incoming.get("amount") or incoming.get("tuition_fee") or 0.0)

        if old_amount != new_amount and (old_amount > 0 or new_amount > 0):
            pct_change = ((new_amount - old_amount) / old_amount * 100.0) if old_amount > 0 else 100.0
            event = {
                "id": str(uuid.uuid4()),
                "sync_run_id": sync_run_id,
                "source_id": source_id,
                "entity_type": "fee_record",
                "entity_id": fee_id,
                "field_name": "amount",
                "old_value": str(old_amount),
                "new_value": str(new_amount),
                "diff_reason": f"Tuition fee shifted by {pct_change:+.1f}%",
                "confidence_score": incoming.get("confidence_score", 95.0),
                "created_at": datetime.now(timezone.utc).isoformat()
            }
            diff_events.append(event)

        return diff_events
