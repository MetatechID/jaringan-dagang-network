"""Register all subscribers from subscribers.yaml into the running network registry.

Reads each entry's public_key_path (a base64 ed25519 pubkey file), then POSTs
to /subscribe. Idempotent — re-registering an existing subscriber is a 409
which we treat as success.

Usage:
    # boot the network registry first (e.g. uvicorn registry.main:app --port 3030)
    python scripts/register-subscribers.py [subscribers.yaml] [registry_url]
"""

from __future__ import annotations

import asyncio
import sys
from pathlib import Path

import httpx
import yaml


async def register_one(client: httpx.AsyncClient, base: str, sub: dict) -> None:
    pub_path = (Path(__file__).parent.parent / sub["public_key_path"]).resolve()
    if not pub_path.exists():
        print(f"  SKIP {sub['subscriber_id']} — pubkey not found at {pub_path}")
        return
    pub_b64 = pub_path.read_text().strip()
    payload = {
        "subscriber_id": sub["subscriber_id"],
        "subscriber_url": sub["subscriber_url"],
        "type": sub["type"],
        "domain": sub["domain"],
        "city": sub["city"],
        "signing_public_key": pub_b64,
        # registry requires encryption pubkey but for now reuse the signing key
        "encryption_public_key": pub_b64,
    }
    r = await client.post(f"{base}/subscribe", json=payload)
    if r.status_code in (200, 201):
        print(f"  OK   {sub['subscriber_id']} ({sub['type']}) — {r.status_code}")
    elif r.status_code == 400 and "already registered" in r.text.lower():
        print(f"  IDEMPOTENT {sub['subscriber_id']} — already registered")
    elif r.status_code == 400:
        print(f"  FAIL {sub['subscriber_id']} — 400: {r.text[:200]}")
    else:
        print(f"  ERR  {sub['subscriber_id']} — {r.status_code}: {r.text[:200]}")


async def main() -> None:
    yaml_path = Path(sys.argv[1] if len(sys.argv) > 1 else "subscribers.yaml")
    base = sys.argv[2] if len(sys.argv) > 2 else "http://localhost:3030"
    cfg = yaml.safe_load(yaml_path.read_text())
    print(f"registering {len(cfg['subscribers'])} subscribers to {base}")
    async with httpx.AsyncClient(timeout=10.0) as client:
        for sub in cfg["subscribers"]:
            await register_one(client, base, sub)
    print("done.")


if __name__ == "__main__":
    asyncio.run(main())
