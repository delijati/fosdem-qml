import configparser
import json
from pathlib import Path

import backend

ROOT = Path(__file__).parent.parent


def test_versions_match():
    manifest = json.loads((ROOT / "manifest.json.in").read_text())
    bump = configparser.ConfigParser()
    bump.read(ROOT / ".bumpversion.cfg")

    assert manifest["version"] == backend.__version__
    assert bump["bumpversion"]["current_version"] == backend.__version__
