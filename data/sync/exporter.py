"""
UniSelection — Standardized Data Exporter
Exports validated institutions, campuses, programmes, admissions, fees,
and scholarships to backend SQL, mobile JSON bundles, and CSV exports.
"""

import json
import csv
from pathlib import Path

class DataExporter:
    REPO_ROOT = Path(__file__).resolve().parent.parent.parent

    @classmethod
    def export_all(cls, dataset: dict):
        """Exports dataset to mobile bundle, backend seed, and CSV directory."""
        export_dir = cls.REPO_ROOT / "data" / "exports"
        export_dir.mkdir(parents=True, exist_ok=True)

        backend_json = cls.REPO_ROOT / "backend" / "seed" / "starter_dataset.json"
        mobile_json = cls.REPO_ROOT / "mobile" / "assets" / "data" / "starter_dataset.json"

        # 1. Export JSON Bundles
        json_str = json.dumps(dataset, indent=2, ensure_ascii=False)
        with open(backend_json, "w", encoding="utf-8") as f:
            f.write(json_str)

        with open(mobile_json, "w", encoding="utf-8") as f:
            f.write(json_str)

        # 2. Export Institutions CSV
        inst_csv = export_dir / "institutions_export.csv"
        institutions = dataset.get("institutions", [])
        if institutions:
            keys = list(institutions[0].keys())
            with open(inst_csv, "w", encoding="utf-8", newline="") as f:
                writer = csv.DictWriter(f, fieldnames=keys)
                writer.writeheader()
                for inst in institutions:
                    writer.writerow({k: inst.get(k, "") for k in keys})

        # 3. Export Campuses CSV
        camp_csv = export_dir / "campuses_export.csv"
        campuses = dataset.get("campuses", [])
        if campuses:
            keys = list(campuses[0].keys())
            with open(camp_csv, "w", encoding="utf-8", newline="") as f:
                writer = csv.DictWriter(f, fieldnames=keys)
                writer.writeheader()
                for camp in campuses:
                    writer.writerow({k: camp.get(k, "") for k in keys})

        # 4. Export Programmes CSV
        prog_csv = export_dir / "programmes_export.csv"
        programmes = dataset.get("programmes", [])
        if programmes:
            keys = list(programmes[0].keys())
            with open(prog_csv, "w", encoding="utf-8", newline="") as f:
                writer = csv.DictWriter(f, fieldnames=keys)
                writer.writeheader()
                for prog in programmes:
                    writer.writerow({k: prog.get(k, "") for k in keys})

        # 5. Export Scholarships CSV
        schol_csv = export_dir / "scholarships_export.csv"
        scholarships = dataset.get("scholarships", [])
        if scholarships:
            keys = list(scholarships[0].keys())
            with open(schol_csv, "w", encoding="utf-8", newline="") as f:
                writer = csv.DictWriter(f, fieldnames=keys)
                writer.writeheader()
                for s in scholarships:
                    writer.writerow({k: s.get(k, "") for k in keys})

        print(f"[V] Export complete: {len(institutions)} institutions, {len(campuses)} campuses exported to JSON & CSV.")
