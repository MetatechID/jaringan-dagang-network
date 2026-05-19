"""Task A3 — ``subscribers.yaml`` carries canonical ``*.jaringan-dagang.id``
ids + ONDC sub-domain codes + ``std:021`` Jakarta city code.

This is the registry-seed source of truth. Every entry must:
  - have a canonical subscriber_id (no .metatech.id, no .local)
  - declare type BAP / BPP
  - use an ONDC:RET* domain code (per network-extension/domains/retail.yaml)
  - use city std:021 (per network-extension/cities.yaml — Jakarta)
  - have a non-empty subscriber_url
  - reference a public_key file that exists on disk

We also check that the expected canonical roster is present.
"""

from __future__ import annotations

import re
from pathlib import Path

import yaml

REPO_ROOT = Path(__file__).resolve().parent.parent
SUBSCRIBERS_YAML = REPO_ROOT / "subscribers.yaml"


CANONICAL_RE = re.compile(
    r"^(?:"
    r"beli-aman\.bap\.jaringan-dagang\.id"
    r"|bpp\.jaringan-dagang\.id"
    r"|gateway\.jaringan-dagang\.id"
    r"|registry\.jaringan-dagang\.id"
    r"|[a-z][a-z0-9-]*\.jaringan-dagang\.id"
    r")$"
)

ONDC_DOMAIN_RE = re.compile(r"^ONDC:RET(?:1[0-9])?$")


def _load() -> list[dict]:
    cfg = yaml.safe_load(SUBSCRIBERS_YAML.read_text())
    return cfg["subscribers"]


def test_yaml_parses():
    cfg = yaml.safe_load(SUBSCRIBERS_YAML.read_text())
    assert "subscribers" in cfg
    assert isinstance(cfg["subscribers"], list)
    assert len(cfg["subscribers"]) >= 6


def test_all_subscriber_ids_are_canonical():
    for sub in _load():
        sid = sub["subscriber_id"]
        assert CANONICAL_RE.match(sid), (
            f"subscriber_id {sid!r} is not canonical "
            f"(expected *.jaringan-dagang.id)"
        )
        assert "metatech.id" not in sid, f"{sid!r} still uses legacy .metatech.id"
        assert ".local" not in sid, f"{sid!r} still uses legacy .local"


def test_all_domains_use_ondc_ret_codes():
    for sub in _load():
        d = sub.get("domain", "")
        assert ONDC_DOMAIN_RE.match(d), (
            f"subscriber {sub['subscriber_id']!r} has domain {d!r}; "
            f"expected an ONDC:RET / ONDC:RET1[0-9] code"
        )


def test_all_cities_are_std_021():
    for sub in _load():
        c = sub.get("city")
        assert c == "std:021", (
            f"subscriber {sub['subscriber_id']!r} has city {c!r}; "
            f"expected 'std:021' (Jakarta, per network-extension/cities.yaml)"
        )


def test_all_have_non_empty_subscriber_url():
    for sub in _load():
        url = sub.get("subscriber_url")
        assert url, f"subscriber {sub['subscriber_id']!r} has empty subscriber_url"
        assert url.startswith("http"), (
            f"subscriber_url {url!r} for {sub['subscriber_id']!r} must be a URL"
        )


def test_all_have_valid_type():
    for sub in _load():
        t = sub.get("type")
        assert t in ("BAP", "BPP"), (
            f"subscriber {sub['subscriber_id']!r} has type {t!r}; "
            f"expected BAP or BPP"
        )


def test_pubkey_files_exist():
    for sub in _load():
        pk_path = REPO_ROOT / sub["public_key_path"]
        # Resolve through any ../ prefixes.
        pk_path = pk_path.resolve()
        assert pk_path.exists(), (
            f"public_key_path for {sub['subscriber_id']!r} -> "
            f"{sub['public_key_path']!r} does not exist on disk "
            f"(resolved to {pk_path})"
        )


def test_canonical_roster_present():
    """The canonical roster MUST include every onboarded store + the BAP +
    the single-tenant fallback BPP."""
    ids = {s["subscriber_id"] for s in _load()}
    must_have = {
        "beli-aman.bap.jaringan-dagang.id",
        "safiyafood.jaringan-dagang.id",
        "antarestar.jaringan-dagang.id",
        "gendes.jaringan-dagang.id",
        "yourbrand.jaringan-dagang.id",
        "bpp.jaringan-dagang.id",
    }
    missing = must_have - ids
    assert not missing, f"missing canonical subscribers: {sorted(missing)}"


def test_safiya_uses_packaged_fnb_subdomain():
    """Safiya is packaged F&B -> ONDC:RET11."""
    safiya = next(
        s for s in _load() if s["subscriber_id"] == "safiyafood.jaringan-dagang.id"
    )
    assert safiya["domain"] == "ONDC:RET11"


def test_no_legacy_identifiers_in_subscriber_ids():
    """No subscriber_id value may use legacy .metatech.id or .local
    suffixes. (Comments are allowed to mention them for documentation.)"""
    for sub in _load():
        sid = sub["subscriber_id"]
        assert "metatech.id" not in sid, (
            f"subscriber_id {sid!r} still uses legacy .metatech.id"
        )
        assert ".local" not in sid, (
            f"subscriber_id {sid!r} still uses legacy .local"
        )
