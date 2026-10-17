"""
UniSelection — Base Ingestion Connector
Provides rate limiting, polite user-agent, robots.txt verification,
conditional requests (ETag/Last-Modified), SHA-256 fingerprinting,
and resilient backoff retry mechanics.
"""

import time
import hashlib
import urllib.parse
import urllib.robotparser
from datetime import datetime, timezone
import requests

class BaseConnector:
    DEFAULT_USER_AGENT = (
        "UniSelection-DataBot/1.0 "
        "(+https://github.com/Hamdanali3/Uni_Selection; "
        "educational research & student guidance; contact: data-transparency@uniselection.pk)"
    )

    def __init__(
        self,
        source_id: str,
        base_url: str,
        rate_limit_rps: float = 1.0,
        timeout_seconds: int = 15,
        max_retries: int = 3,
        user_agent: str = None
    ):
        self.source_id = source_id
        self.base_url = base_url
        self.rate_limit_interval = 1.0 / max(rate_limit_rps, 0.1)
        self.timeout_seconds = timeout_seconds
        self.max_retries = max_retries
        self.user_agent = user_agent or self.DEFAULT_USER_AGENT
        self.last_request_time = 0.0
        self.session = requests.Session()
        self.session.headers.update({"User-Agent": self.user_agent})
        self._robot_parser = None
        self._robots_checked = False

    def check_robots_txt(self, target_url: str) -> bool:
        """Verifies if robots.txt permits crawling the target URL."""
        if self._robots_checked and self._robot_parser:
            return self._robot_parser.can_fetch(self.user_agent, target_url)

        parsed = urllib.parse.urlparse(target_url)
        robots_url = f"{parsed.scheme}://{parsed.netloc}/robots.txt"

        self._robot_parser = urllib.robotparser.RobotFileParser()
        try:
            resp = self.session.get(robots_url, timeout=6)
            if resp.status_code == 200:
                self._robot_parser.parse(resp.text.splitlines())
            elif resp.status_code in (401, 403):
                # Access denied to robots.txt indicates strict anti-bot
                self._robot_parser.parse(["User-agent: *", "Disallow: /"])
            else:
                self._robot_parser.parse(["User-agent: *", "Allow: /"])
        except Exception:
            # Default to polite allowance if robots.txt unreachable
            self._robot_parser.parse(["User-agent: *", "Allow: /"])

        self._robots_checked = True
        return self._robot_parser.can_fetch(self.user_agent, target_url)

    def _apply_rate_limit(self):
        """Enforces polite rate limiting with token-bucket spacing."""
        elapsed = time.time() - self.last_request_time
        if elapsed < self.rate_limit_interval:
            time.sleep(self.rate_limit_interval - elapsed)
        self.last_request_time = time.time()

    def fetch(
        self,
        url: str,
        etag: str = None,
        last_modified: str = None,
        params: dict = None
    ) -> dict:
        """
        Executes a polite conditional HTTP request.
        Returns a dict with:
        - status_code: int
        - content: bytes / text
        - is_modified: bool
        - etag: str
        - last_modified: str
        - content_hash: str (SHA-256)
        """
        if not self.check_robots_txt(url):
            raise PermissionError(f"Robots.txt disallows fetching {url}")

        headers = {}
        if etag:
            headers["If-None-Match"] = etag
        if last_modified:
            headers["If-Modified-Since"] = last_modified

        last_error = None
        for attempt in range(1, self.max_retries + 1):
            self._apply_rate_limit()
            try:
                resp = self.session.get(
                    url,
                    headers=headers,
                    params=params,
                    timeout=self.timeout_seconds
                )

                if resp.status_code == 304:
                    return {
                        "status_code": 304,
                        "is_modified": False,
                        "content": None,
                        "etag": etag,
                        "last_modified": last_modified,
                        "content_hash": None,
                        "fetched_at": datetime.now(timezone.utc).isoformat()
                    }

                if resp.status_code == 429:
                    retry_after = int(resp.headers.get("Retry-After", 10))
                    time.sleep(min(retry_after, 60))
                    continue

                if 200 <= resp.status_code < 300:
                    content_hash = hashlib.sha256(resp.content).hexdigest()
                    return {
                        "status_code": resp.status_code,
                        "is_modified": True,
                        "content": resp.content,
                        "text": resp.text,
                        "headers": dict(resp.headers),
                        "etag": resp.headers.get("ETag"),
                        "last_modified": resp.headers.get("Last-Modified"),
                        "content_hash": content_hash,
                        "fetched_at": datetime.now(timezone.utc).isoformat()
                    }

                if resp.status_code >= 500:
                    time.sleep(2 ** attempt)
                    continue

                # Client error (404, 403, etc.)
                return {
                    "status_code": resp.status_code,
                    "is_modified": False,
                    "content": None,
                    "text": resp.text,
                    "error": f"HTTP {resp.status_code}",
                    "fetched_at": datetime.now(timezone.utc).isoformat()
                }

            except Exception as e:
                last_error = e
                time.sleep(2 ** attempt)

        raise ConnectionError(f"Failed to fetch {url} after {self.max_retries} attempts: {last_error}")
