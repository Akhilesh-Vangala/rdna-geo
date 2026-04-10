"""
Replica of early cells from path_01_full_extractalign_dsub (Workbench screenshot).

On All of Us Jupyter, the notebook uses a manifest of CRAM URIs, e.g.:
  cram_manifest = pd.read_csv("data/manifest.csv")
  cram_manifest.shape   # full v8 ~ 414830 rows mentioned in thread

For SRP126734 locally, use data/run_list.txt + fasterq-dump instead of manifest.csv.
"""
from __future__ import annotations

import os
from datetime import datetime

import pandas as pd

pd.set_option("display.max_colwidth", None)

# Workbench pattern: derive a short user label for bash / dsub logging
_owner = os.environ.get("OWNER_EMAIL", "")
os.environ["USER_NAME"] = _owner.split("@")[0] if _owner else "local_user"
print("env: USER_NAME=", os.environ["USER_NAME"])

# Example only — file not shipped with this repo (AoU controlled tier)
# manifest_path = "data/manifest.csv"
# cram_manifest = pd.read_csv(manifest_path)
# print(datetime.now(), cram_manifest.shape)
