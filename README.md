# Jaringan Dagang - Network Infrastructure

Beckn network infrastructure for Indonesia's open commerce network.

## Components

- **Registry** (`registry/`) - Beckn Registry service (participant directory + public key management)
- **Gateway** (`gateway/`) - Beckn Gateway (search multicast to BPPs)
- **Network Extension** (`network-extension/`) - Indonesia-specific domain taxonomy, city codes, payment methods, logistics providers
- **Beckn Protocol Library** (`packages/beckn-protocol/`) - Shared Pydantic v2 models + Ed25519 signing

## Quick Start

```bash
docker compose up -d postgres redis
pip install -r registry/requirements.txt
cd registry && uvicorn main:app --port 3030
cd ../gateway && uvicorn main:app --port 4030
```

## Related Repos

- [jaringan-dagang-seller](https://github.com/MetatechID/jaringan-dagang-seller) - BPP (Seller platform)
- [jaringan-dagang-buyer](https://github.com/MetatechID/jaringan-dagang-buyer) - BAP (Buyer platform)
