"""Centralized configuration for democracy project."""
import os
from pathlib import Path
from dotenv import load_dotenv, find_dotenv

# find_dotenv() searches up the directory tree for .env
load_dotenv(find_dotenv())

# Required paths
ROOT_PATH = Path(os.environ["ROOT_PATH"])
DATASTORE_PATH = Path(os.environ.get("DATASTORE_PATH", ROOT_PATH / "datastore"))

# Convenience paths (commonly used)
RAW_DATA = DATASTORE_PATH / "raw"
DERIVED_DATA = DATASTORE_PATH / "derived"
