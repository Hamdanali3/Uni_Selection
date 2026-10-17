"""
UniSelection — Entity Quality & Integrity Validator
Enforces data quality gates defined in data-quality-and-provenance.md.
"""

import re
import urllib.parse
from datetime import datetime

class QualityValidator:
    URL_REGEX = re.compile(r"^https?://[^\s/$.?#].[^\s]*$", re.IGNORECASE)
    YEAR_REGEX = re.compile(r"^20\d{2}-20\d{2}$")

    def validate_institution(self, inst: dict) -> list[str]:
        """Validates an institution record. Returns list of error strings."""
        errors = []
        inst_id = inst.get("id", "")
        name = inst.get("name", "")
        country = inst.get("country_id", "")
        website = inst.get("official_website", "")
        sector = inst.get("institution_type", "")
        hec_rec = inst.get("hec_recognized", False)
        accred_body = inst.get("accreditation_body", "")

        if not inst_id or not re.match(r"^[a-z0-9_-]+$", inst_id):
            errors.append(f"Institution '{name}' has invalid slug ID '{inst_id}'")

        if not name:
            errors.append(f"Institution '{inst_id}' has empty canonical name")

        if not country or len(country) != 3:
            errors.append(f"Institution '{inst_id}' has invalid country code '{country}'")

        if website and not self.URL_REGEX.match(website):
            errors.append(f"Institution '{inst_id}' has malformed website URL '{website}'")

        if sector not in ("Public", "Private"):
            errors.append(f"Institution '{inst_id}' has invalid sector '{sector}' (must be Public or Private)")

        # Accreditation Regulatory Separation Gate
        if country == "PAK":
            if not hec_rec:
                errors.append(f"Pakistani institution '{inst_id}' must be HEC recognized")
            if accred_body != "HEC":
                errors.append(f"Pakistani institution '{inst_id}' must cite 'HEC' as accreditation body")
        else:
            if hec_rec:
                errors.append(f"International institution '{inst_id}' cannot be marked HEC recognized")
            if accred_body == "HEC":
                errors.append(f"International institution '{inst_id}' cannot cite HEC as accreditation body")

        return errors

    def validate_programme(self, prog: dict, valid_inst_ids: set) -> list[str]:
        """Validates a programme offering."""
        errors = []
        inst_id = prog.get("institution_id")
        name = prog.get("name")
        level = prog.get("degree_level")

        if inst_id not in valid_inst_ids:
            errors.append(f"Programme '{name}' references non-existent institution '{inst_id}'")

        if not name:
            errors.append(f"Programme has missing name for institution '{inst_id}'")

        if level not in ("Undergraduate", "Postgraduate", "Doctorate"):
            errors.append(f"Programme '{name}' has invalid degree level '{level}'")

        return errors

    def validate_admission(self, adm: dict, valid_inst_ids: set) -> list[str]:
        """Validates an admission cycle."""
        errors = []
        inst_id = adm.get("institution_id")
        open_d = adm.get("application_open_date")
        close_d = adm.get("application_close_date")
        ay = adm.get("academic_year")

        if inst_id not in valid_inst_ids:
            errors.append(f"Admission cycle references invalid institution '{inst_id}'")

        if ay and not self.YEAR_REGEX.match(ay):
            errors.append(f"Admission cycle has invalid academic year syntax '{ay}'")

        if open_d and close_d:
            try:
                d_open = datetime.strptime(open_d, "%Y-%m-%d")
                d_close = datetime.strptime(close_d, "%Y-%m-%d")
                if d_close < d_open:
                    errors.append(f"Admission close date {close_d} is earlier than open date {open_d}")
            except ValueError:
                errors.append(f"Admission dates '{open_d}' or '{close_d}' fail YYYY-MM-DD parsing")

        return errors

    def validate_fee(self, fee: dict, valid_inst_ids: set, inst_country_map: dict) -> list[str]:
        """Validates a tuition fee schedule."""
        errors = []
        inst_id = fee.get("institution_id")
        amount = float(fee.get("amount") or fee.get("tuition_fee") or 0.0)
        currency = fee.get("currency", "PKR")
        basis = fee.get("billing_basis", "")

        if inst_id not in valid_inst_ids:
            errors.append(f"Fee record references invalid institution '{inst_id}'")

        if amount <= 0:
            errors.append(f"Fee record for '{inst_id}' has non-positive amount {amount}")

        country = inst_country_map.get(inst_id, "PAK")
        if country == "PAK" and currency != "PKR":
            errors.append(f"Pakistani institution '{inst_id}' fee must be in PKR, got '{currency}'")

        if basis not in ("per_semester", "per_year", "per_credit_hour", "total_programme"):
            errors.append(f"Fee record for '{inst_id}' has unrecognized billing basis '{basis}'")

        return errors
