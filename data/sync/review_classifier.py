"""
UniSelection — Review Risk Classifier
Classifies change events into risk levels and assigns execution action:
auto_published (low risk) vs pending_review (high risk).
"""

class ReviewClassifier:
    HIGH_RISK_FIELDS = {
        "hec_recognized",
        "accreditation_body",
        "status",
        "application_close_date",
        "minimum_percentage",
        "amount"
    }

    @classmethod
    def classify_change(cls, event: dict) -> tuple[str, str]:
        """
        Evaluates a change event and returns (risk_level, status).
        risk_level: 'critical', 'high', 'medium', 'low'
        status: 'auto_published', 'pending'
        """
        field_name = event.get("field_name", "")
        entity_type = event.get("entity_type", "")
        confidence = float(event.get("confidence_score", 100.0))

        # 1. Critical: Accreditation or Recognition Status
        if field_name in ("hec_recognized", "accreditation_body"):
            return "critical", "pending"

        # 2. High: Admission Deadlines or Eligibility Thresholds
        if field_name in ("application_close_date", "minimum_percentage"):
            return "high", "pending"

        # 3. High: Large Tuition Fee Jump (>10%)
        if field_name == "amount" and entity_type == "fee_record":
            try:
                old_val = float(event.get("old_value", 0))
                new_val = float(event.get("new_value", 0))
                if old_val > 0:
                    pct = abs(new_val - old_val) / old_val
                    if pct > 0.10:
                        return "high", "pending"
                    else:
                        return "medium", "auto_published" if confidence >= 95.0 else "pending"
            except ValueError:
                return "high", "pending"

        # 4. Low: Website URLs, Spelling / Acronyms
        if field_name in ("official_website", "admissions_url", "short_name", "established_since"):
            if confidence >= 95.0:
                return "low", "auto_published"
            return "low", "pending"

        # 5. Default Medium Risk
        if confidence >= 95.0:
            return "medium", "auto_published"
        return "medium", "pending"
