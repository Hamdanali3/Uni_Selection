"""
UniSelection — Normalization Pipeline
Normalizes strings, Unicode, acronyms, country codes, regions,
currencies, degree levels, and URLs across all ingestion connectors.
"""

import re
import unicodedata
import urllib.parse

# ISO 3166-1 Alpha-3 Mapping
COUNTRY_MAP = {
    "pakistan": "PAK",
    "pak": "PAK",
    "pk": "PAK",
    "united kingdom": "GBR",
    "uk": "GBR",
    "great britain": "GBR",
    "gbr": "GBR",
    "united states": "USA",
    "united states of america": "USA",
    "usa": "USA",
    "us": "USA",
    "canada": "CAN",
    "can": "CAN",
    "australia": "AUS",
    "aus": "AUS",
    "turkey": "TUR",
    "türkiye": "TUR",
    "tur": "TUR",
    "malaysia": "MYS",
    "mys": "MYS",
    "switzerland": "CHE",
    "che": "CHE",
    "saudi arabia": "SAU",
    "sau": "SAU",
    "germany": "DEU",
    "deu": "DEU",
    "china": "CHN",
    "chn": "CHN",
    "france": "FRA",
    "fra": "FRA"
}

PAKISTAN_PROVINCES = {
    "punjab": "Punjab",
    "sindh": "Sindh",
    "khyber pakhtunkhwa": "Khyber Pakhtunkhwa",
    "kpk": "Khyber Pakhtunkhwa",
    "balochistan": "Balochistan",
    "baluchistan": "Balochistan",
    "islamabad": "Islamabad Capital Territory",
    "islamabad capital territory": "Islamabad Capital Territory",
    "ict": "Islamabad Capital Territory",
    "federal": "Islamabad Capital Territory",
    "azad jammu & kashmir": "Azad Jammu & Kashmir",
    "azad kashmir": "Azad Jammu & Kashmir",
    "ajk": "Azad Jammu & Kashmir",
    "gilgit-baltistan": "Gilgit-Baltistan",
    "gilgit baltistan": "Gilgit-Baltistan",
    "gb": "Gilgit-Baltistan"
}

CURRENCY_MAP = {
    "rs": "PKR",
    "rs.": "PKR",
    "pkr": "PKR",
    "$": "USD",
    "usd": "USD",
    "£": "GBP",
    "gbp": "GBP",
    "€": "EUR",
    "eur": "EUR",
    "a$": "AUD",
    "aud": "AUD",
    "c$": "CAD",
    "cad": "CAD",
    "chf": "CHF",
    "tl": "TRY",
    "try": "TRY"
}

DEGREE_LEVEL_MAP = {
    "undergraduate": "Undergraduate",
    "bachelor": "Undergraduate",
    "bachelors": "Undergraduate",
    "bs": "Undergraduate",
    "bsc": "Undergraduate",
    "ba": "Undergraduate",
    "bba": "Undergraduate",
    "postgraduate": "Postgraduate",
    "graduate": "Postgraduate",
    "master": "Postgraduate",
    "masters": "Postgraduate",
    "ms": "Postgraduate",
    "msc": "Postgraduate",
    "mphil": "Postgraduate",
    "mba": "Postgraduate",
    "doctorate": "Doctorate",
    "doctoral": "Doctorate",
    "phd": "Doctorate",
    "dphil": "Doctorate"
}

def clean_unicode(text: str) -> str:
    """Normalizes Unicode to NFKC and cleans unusual whitespace."""
    if not text:
        return ""
    normalized = unicodedata.normalize("NFKC", str(text))
    # Remove control characters except standard whitespace
    normalized = re.sub(r"[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]", "", normalized)
    # Collapse multiple whitespaces
    return " ".join(normalized.split()).strip()

def normalize_slug_id(name: str) -> str:
    """Generates a stable, lowercase alphanumeric slug ID."""
    cleaned = clean_unicode(name).lower()
    # Replace non-alphanumeric with hyphen
    slug = re.sub(r"[^a-z0-9]+", "-", cleaned)
    return slug.strip("-")

def extract_acronym_and_name(raw_name: str) -> tuple[str, str]:
    """
    Extracts acronym and canonical name from raw name.
    e.g. 'National University of Sciences & Technology (NUST)' -> ('National University of Sciences & Technology', 'NUST')
    """
    cleaned = clean_unicode(raw_name)
    # Pattern: Name (ACRONYM)
    m = re.search(r"^(.*?)\s*\(([A-Z0-9\-\.]{2,12})\)\s*$", cleaned)
    if m:
        return clean_unicode(m.group(1)), clean_unicode(m.group(2))

    # Pattern: Name, Location e.g. "Air University, Islamabad" -> check if acronym exists
    return cleaned, ""

def normalize_country_code(country_str: str) -> str:
    """Converts country name or partial string to ISO 3166-1 alpha-3 code."""
    cleaned = clean_unicode(country_str).lower()
    return COUNTRY_MAP.get(cleaned, "PAK")

def normalize_province(province_str: str) -> str:
    """Normalizes Pakistan province names."""
    cleaned = clean_unicode(province_str).lower()
    return PAKISTAN_PROVINCES.get(cleaned, clean_unicode(province_str))

def normalize_currency(currency_str: str) -> str:
    """Normalizes currency representation to ISO 4217 code."""
    cleaned = clean_unicode(currency_str).lower()
    return CURRENCY_MAP.get(cleaned, "PKR")

def normalize_degree_level(level_str: str) -> str:
    """Normalizes academic qualification level."""
    cleaned = clean_unicode(level_str).lower()
    return DEGREE_LEVEL_MAP.get(cleaned, "Undergraduate")

def normalize_url(url_str: str) -> str:
    """Canonicalizes URLs ensuring protocol and removing trailing slashes."""
    if not url_str:
        return ""
    cleaned = clean_unicode(url_str).strip()
    # Fix double protocol prefixes
    while cleaned.startswith("http://http://") or cleaned.startswith("https://http://"):
        cleaned = cleaned.replace("http://http://", "http://").replace("https://http://", "https://")
    while cleaned.startswith("http://https://") or cleaned.startswith("https://https://"):
        cleaned = cleaned.replace("http://https://", "https://").replace("https://https://", "https://")

    # Handle placeholders like 'under process', 'under construction'
    lower = cleaned.lower()
    if "under process" in lower or "under construction" in lower or "under development" in lower:
        return ""

    if not cleaned.startswith("http://") and not cleaned.startswith("https://"):
        cleaned = "https://" + cleaned

    try:
        parsed = urllib.parse.urlparse(cleaned)
        netloc = parsed.netloc.lower()
        if not netloc or "." not in netloc or " " in netloc:
            return ""
        path = parsed.path.rstrip("/")
        return urllib.parse.urlunparse((parsed.scheme, netloc, path, parsed.params, parsed.query, parsed.fragment))
    except Exception:
        return ""
