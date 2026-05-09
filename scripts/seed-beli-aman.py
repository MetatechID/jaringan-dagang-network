"""Register Beli Aman as a BAP on the local Beckn registry.

This is a one-shot seed for local-dev / staging — it makes the registry aware
of `bap.beli-aman.local` so a future `/lookup` returns it. v1 of Beli Aman
does NOT actually speak Beckn on the network (the BAP exposes REST only),
but registering early keeps the door open for v2 round-trips.

Usage:
    python scripts/seed-beli-aman.py                       # local registry
    REGISTRY_URL=https://registry.metatech.id python scripts/seed-beli-aman.py
"""

from __future__ import annotations

import base64
import json
import os
import sys
import urllib.error
import urllib.request

REGISTRY_URL = os.environ.get("REGISTRY_URL", "http://localhost:3030")
SUBSCRIBER_ID = os.environ.get("BELI_AMAN_SUBSCRIBER_ID", "bap.beli-aman.local")
SUBSCRIBER_URL = os.environ.get("BELI_AMAN_SUBSCRIBER_URL", "http://localhost:8003/beckn")
DOMAIN = os.environ.get("BELI_AMAN_DOMAIN", "retail")
CITY = os.environ.get("BELI_AMAN_CITY", "ID:JKT")


def _generate_keypair() -> tuple[str, str, str]:
    """Generate Ed25519 + X25519 keypairs.

    Returns (signing_pub_b64, encryption_pub_b64, signing_priv_b64).
    Falls back to placeholder strings if pynacl isn't installed (the local
    registry auto-approves any subscribe payload anyway in dev mode).
    """
    try:
        from nacl.signing import SigningKey  # type: ignore
        from nacl.public import PrivateKey  # type: ignore

        sk = SigningKey.generate()
        signing_priv = base64.b64encode(bytes(sk)).decode()
        signing_pub = base64.b64encode(bytes(sk.verify_key)).decode()
        x = PrivateKey.generate()
        encryption_pub = base64.b64encode(bytes(x.public_key)).decode()
        return signing_pub, encryption_pub, signing_priv
    except ImportError:
        print("[warn] pynacl not installed — using placeholder keys (dev only).")
        return ("dev-placeholder-signing-pub", "dev-placeholder-encryption-pub", "")


def main() -> int:
    signing_pub, encryption_pub, signing_priv = _generate_keypair()

    payload = {
        "subscriber_id": SUBSCRIBER_ID,
        "subscriber_url": SUBSCRIBER_URL,
        "type": "BAP",
        "domain": DOMAIN,
        "city": CITY,
        "country": "IDN",
        "signing_public_key": signing_pub,
        "encryption_public_key": encryption_pub,
        "valid_from": "2026-01-01T00:00:00Z",
        "valid_until": "2027-01-01T00:00:00Z",
        "status": "SUBSCRIBED",
    }

    url = f"{REGISTRY_URL.rstrip('/')}/subscribe"
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        url, data=data, headers={"Content-Type": "application/json"}, method="POST"
    )

    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            body = resp.read().decode("utf-8")
            print(f"[ok] {resp.status} {body}")
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8")
        print(f"[error] {e.code} {body}")
        return 1
    except Exception as e:
        print(f"[error] {e}")
        return 1

    if signing_priv:
        print()
        print("=" * 72)
        print("BELI AMAN BAP signing private key (KEEP SECRET — paste to Vercel env):")
        print()
        print(f"  BELI_AMAN_SIGNING_KEY_BASE64={signing_priv}")
        print()
        print("This is shown ONCE. Copy it now.")
        print("=" * 72)

    return 0


if __name__ == "__main__":
    sys.exit(main())
