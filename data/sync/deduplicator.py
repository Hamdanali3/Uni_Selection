"""
UniSelection — Deduplication & Entity Resolution Engine
Resolves entity identities using exact persistent IDs (ROR, HEC, OpenAlex),
domain matching, and fuzzy string similarity scoring with human review triggers.
"""

import urllib.parse
from difflib import SequenceMatcher
from .normalizer import clean_unicode

class Deduplicator:
    SIMILARITY_EXACT = 1.0
    SIMILARITY_AUTO_MERGE = 0.95
    SIMILARITY_CANDIDATE_REVIEW = 0.85

    GENERIC_DOMAINS = {
        "facebook.com", "google.com", "twitter.com", "linkedin.com", "instagram.com",
        "edu.pk", "gov.pk", "org.pk", "com.pk", "net.pk", "hec.gov.pk",
        "ac.uk", "edu", "gov", "org", "com"
    }

    STOPWORDS = {
        "university", "universities", "of", "the", "institute", "institutes",
        "college", "colleges", "technology", "technologies", "science", "sciences",
        "and", "&", "for", "in", "at", "campus", "sub-campus", "subcampus"
    }

    @classmethod
    def extract_domain(cls, url: str) -> str:
        """Extracts cleaned hostname from URL."""
        if not url:
            return ""
        parsed = urllib.parse.urlparse(url if "://" in url else f"https://{url}")
        host = parsed.netloc.lower()
        if host.startswith("www."):
            host = host[4:]
        return host.strip()

    @classmethod
    def strip_stopwords(cls, name: str) -> str:
        """Strips common institutional stop words for high-precision comparison."""
        cleaned = clean_unicode(name).lower()
        for char in (",", ".", "-", "(", ")", "/", "\\", "'", '"'):
            cleaned = cleaned.replace(char, " ")
        tokens = [t for t in cleaned.split() if t not in cls.STOPWORDS]
        return " ".join(sorted(tokens))

    @classmethod
    def calculate_string_similarity(cls, str1: str, str2: str) -> float:
        """Computes token sort ratio similarity between two strings with stop words stripped."""
        s1 = cls.strip_stopwords(str1)
        s2 = cls.strip_stopwords(str2)
        if not s1 or not s2:
            return 0.0
        if s1 == s2:
            return 1.0

        return SequenceMatcher(None, s1, s2).ratio()

    def resolve_institution_match(
        self,
        candidate: dict,
        existing_institutions: list[dict]
    ) -> tuple[dict | None, str, float]:
        """
        Attempts to match candidate against existing institutions.
        Returns:
        (matched_inst, match_method, confidence_score)
        match_method can be: 'exact_id', 'exact_ror', 'domain_match', 'exact_name', 'fuzzy_name', 'candidate_review', 'no_match'
        """
        candidate_id = candidate.get("id")
        candidate_name = candidate.get("name", "")
        candidate_ror = candidate.get("ror_id")
        candidate_domain = self.extract_domain(candidate.get("official_website", ""))
        candidate_country = candidate.get("country_id", "PAK")
        candidate_city = candidate.get("city", "").strip().lower()

        # 1. Exact System ID Match
        if candidate_id:
            for inst in existing_institutions:
                if inst.get("id") == candidate_id:
                    return inst, "exact_id", 100.0

        # 2. Exact Persistent Identifier Match (ROR)
        if candidate_ror:
            for inst in existing_institutions:
                if inst.get("ror_id") and inst["ror_id"].lower() == candidate_ror.lower():
                    return inst, "exact_ror", 100.0

        # 3. Exact Canonical Name & Country Match
        norm_candidate_name = clean_unicode(candidate_name).strip().lower()
        for inst in existing_institutions:
            if inst.get("country_id", "PAK") == candidate_country:
                if clean_unicode(inst.get("name", "")).strip().lower() == norm_candidate_name:
                    return inst, "exact_name", 100.0

        # 4. Normalized Domain Match (High confidence if non-generic domain and city/name check passes)
        if candidate_domain and candidate_domain not in self.GENERIC_DOMAINS:
            for inst in existing_institutions:
                inst_domain = self.extract_domain(inst.get("official_website", ""))
                if inst_domain and inst_domain == candidate_domain:
                    inst_city = inst.get("city", "").strip().lower()
                    # If cities are specified and differ, check if it's a multi-city distinct institution
                    if candidate_city and inst_city and candidate_city != inst_city:
                        continue
                    # Check gender/scope modifier (e.g., "women" vs non-women)
                    cand_lower = candidate_name.lower()
                    inst_lower = inst.get("name", "").lower()
                    if ("women" in cand_lower) != ("women" in inst_lower):
                        continue
                    return inst, "domain_match", 98.0

        # 5. Fuzzy Name Match
        best_match = None
        best_score = 0.0

        for inst in existing_institutions:
            # Country must match to avoid false cross-country merges
            if inst.get("country_id", "PAK") != candidate_country:
                continue

            # Check gender/scope modifier
            cand_lower = candidate_name.lower()
            inst_lower = inst.get("name", "").lower()
            if ("women" in cand_lower) != ("women" in inst_lower):
                continue

            score = self.calculate_string_similarity(candidate_name, inst.get("name", ""))
            if score > best_score:
                best_score = score
                best_match = inst

        if best_score >= self.SIMILARITY_AUTO_MERGE:
            return best_match, "fuzzy_name", round(best_score * 100.0, 1)

        if best_score >= self.SIMILARITY_CANDIDATE_REVIEW:
            return best_match, "candidate_review", round(best_score * 100.0, 1)

        return None, "no_match", 0.0

