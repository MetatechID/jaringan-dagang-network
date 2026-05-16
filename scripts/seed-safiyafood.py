"""Register Safiya Food as a BPP on the Beckn registry.

Safiya Food (safiyafood.jaringan-dagang.id) is a tenant of the JD seller BPP
(https://jaringan-dagang-seller-api.metatech.id). After this script runs, the
gateway will multicast `/search` calls to Safiyafood and the BAP will see its
catalog in `on_search` responses.

Usage:
    python scripts/seed-safiyafood.py
    REGISTRY_URL=https://registry.metatech.id python scripts/seed-safiyafood.py
"""

from __future__ import annotations

import base64
import json
import os
import sys
import urllib.error
import urllib.request

REGISTRY_URL = os.environ.get("REGISTRY_URL", "http://localhost:3030")
SUBSCRIBER_ID = os.environ.get(
    "SAFIYAFOOD_SUBSCRIBER_ID", "safiya-food.jaringan-dagang.id"
)
SUBSCRIBER_URL = os.environ.get(
    "SAFIYAFOOD_SUBSCRIBER_URL",
    "https://jaringan-dagang-seller-api.metatech.id/beckn",
)
DOMAIN = os.environ.get("SAFIYAFOOD_DOMAIN", "retail")
# std:021 = Jakarta DKI / Jakarta Barat. Safiya HQ is Tanah Abang, Jakarta Pusat.
CITY = os.environ.get("SAFIYAFOOD_CITY", "std:021")


def _generate_keypair() -> tuple[str, str, str]:
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
        "type": "BPP",
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
        with urllib.request.urlopen(req, timeout=15) as resp:
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
        print("SAFIYAFOOD BPP signing private key (KEEP SECRET — paste to Vercel env):")
        print()
        print(f"  SAFIYAFOOD_SIGNING_KEY_BASE64={signing_priv}")
        print()
        print("This is shown ONCE. Copy it now.")
        print("=" * 72)

    return 0


if __name__ == "__main__":
    sys.exit(main())
