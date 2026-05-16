# Jaringan Dagang — Technical Architecture (Network)

> This is the canonical **whole-system** doc. The seller and buyer repos carry
> their own `TECHNICAL.md` focused on their service; the "System Overview",
> "Beckn Protocol", "Identity & ACL", and "Production Databases" sections below
> are mirrored across all three and should be kept in sync.

## System Overview

Jaringan Dagang is an Indonesian open-commerce network built on the **Beckn
protocol**. Three independently-deployed apps, one shared Firebase identity,
one Neon Postgres project (two logical databases).

```
                         Firebase project: beli-aman-prod
                          (one Google sign-in for everyone)
                                       │
        ┌──────────────────────────────┼───────────────────────────────┐
        ▼                              ▼                               ▼
┌───────────────────┐   signed   ┌───────────────────┐         ┌───────────────────┐
│ jaringan-dagang-  │   Beckn    │ jaringan-dagang-  │ registry│ jaringan-dagang-  │
│      buyer        │◀──HTTP────▶│      seller       │◀──lookup│     network       │
│  "Beli Aman" BAP  │  Ed25519   │   BPP / catalog   │         │ registry+gateway  │
│                   │            │                   │         │  (this repo)      │
│ • storefronts     │            │ • seller dashboard│         │ • subscriber dir  │
│ • Vibe admin      │            │ • Beckn /search…  │         │ • /lookup /subscribe
│ • IDENTITY PROVIDER            │ • orders/refunds  │         │ • Beckn gateway   │
│   (profiles+ACL)  │            │ • catalog source  │         │   search multicast│
└─────────┬─────────┘            └─────────┬─────────┘         └─────────┬─────────┘
          │                                │                             │
          ▼ Neon db `beli_aman`            ▼ Neon db `neondb`            ▼ Neon (own)
     identity, ACL, escrow,           stores, products, skus,       subscribers
     disputes, mirror catalog         orders, refunds, beckn logs
          └──────────── one Neon project: ep-shy-heart-a1atpe0m (ap-southeast-1) ─┘
```

| App | Repo | Prod URLs | Vercel project |
|---|---|---|---|
| Buyer / BAP / **IdP** | `jaringan-dagang-buyer` | storefronts `*.beliaman.com`, `beli-aman.metatech.id`; API `api.beli-aman.metatech.id` | `beli-aman-bap`, `beli-aman-storefronts` |
| Seller / BPP | `jaringan-dagang-seller` | dashboard `jaringan-dagang-seller.metatech.id`; API `jaringan-dagang-seller-api.metatech.id` | `jaringan-dagang-seller`, `seller-dashboard` |
| Network | `jaringan-dagang-network` | dashboard `jaringan-dagang.metatech.id` | (this repo) |

**Stack everywhere:** Python 3.13 · FastAPI · SQLAlchemy 2 async · asyncpg ·
Neon Postgres · Next.js 14 (dashboards/storefronts) · Vercel (serverless) ·
Firebase Auth (Google) · Ed25519 (pynacl) for Beckn signing.

## Jaringan Dagang vs Beli Aman (two things, deliberately separate)

These are **not the same product** and the codebase keeps them apart on purpose:

- **Jaringan Dagang** is the *network* — neutral open-commerce rails built on
  Beckn. Brand-agnostic infrastructure: the registry, the gateway, the
  signed-message protocol, and the seller-side BPP/catalog/dashboard tooling.
  Many participants can join; nothing here is consumer-facing.
  ("Jaringan Dagang" ≈ "trade network".)
- **Beli Aman** is a *participant brand* on that network — the consumer-facing
  buyer app (a Beckn BAP), buyer-protection/escrow, the `*.beliaman.com`
  storefronts and their Vibe editor, **and** the network Identity Provider.
  ("Beli Aman" ≈ "buy safely".)

Why it matters in the code:
- The network repo never imports identity, catalog, or storefront code — it
  stays a thin trust+discovery layer so other (non-Beli-Aman) BAPs/BPPs can
  join later without touching it.
- Beli Aman is just one BAP from Beckn's point of view; its role as Identity
  Provider is an *additional hat*, not a protocol feature. Auth tokens, ACL,
  and `profiles` live in the `beli_aman` DB — never in the network, never in
  the seller catalog DB.
- The seller dashboard is Jaringan Dagang-branded (operator tooling); the
  buyer storefronts are Beli Aman-branded (shopper-facing). One person uses
  both via a single "Sign in with Beli Aman" identity — that federation is the
  *only* thing that crosses the brand line, and it crosses it intentionally.

## Vibe — the no-code storefront editor

"Vibe" is the Beli Aman storefront builder. Each toko gets a hosted storefront
at `<slug>.beliaman.com`; its owner/staff customize it (theme, copy, layout,
featured products) through the **Vibe admin** at `<slug>.beliaman.com/admin`
(`jaringan-dagang-buyer` → `sites/partner-demos`, `AdminApp.tsx`).

Vibe is **not** the seller dashboard. The seller dashboard (Jaringan Dagang)
manages catalog / orders / refunds; Vibe (Beli Aman) manages how the storefront
*looks*. Both gate on the **same** Beli Aman identity + `store_memberships`
ACL, so one invite grants both. The products a Vibe storefront shows come from
the buyer-side Beckn mirror (refreshed via `/on_search`) — Vibe never writes
catalog, it only themes presentation.

## Beckn Protocol

Beckn is a **discovery + transaction** protocol — NOT a sync or ACL protocol.
It carries signed messages between a BAP (buyer app) and BPP (seller backend);
it has no concept of "who can administer a store" (that's the Identity layer).

**Trust model:** every Beckn message is Ed25519-signed. The signer's public key
is registered in the network registry under a `subscriber_id`. The receiver
looks up the key (Redis-cached 1h, with a bundled static fallback) and verifies.
Replay-protected via a 5-minute signature freshness window + `message_id`
idempotency log.

**Per-toko identity:** each toko is its own Beckn subscriber
(`<slug>.jaringan-dagang.id`) with its own keypair. The seller process holds
each toko's private key (in `stores.signing_private_key`, the seller DB) and
signs that toko's `/on_*` callbacks with it. `/on_search` fans out one message
per provider, each signed by that toko. A toko without its own key falls back
to the process key `bpp.jaringan-dagang.local` (and the message's `bpp_id` is
rebranded so signature verification still matches).

**Catalog sync model (eventual + strong at the boundary):**
- Seller Postgres (`neondb`) is the **system of record** for catalog.
- Buyer keeps a hint-only **mirror** (`mirror_*` tables in `beli_aman`).
- Push: seller emits `/on_search` on every product write (<1s typical).
- Pull: buyer worker calls `/search` every 5 min as a safety net.
- Strong consistency only at money-moving steps: `/select`+`/init` re-quote
  live price/stock; `/confirm` decrements inventory inside a
  `SELECT … FOR UPDATE` txn so concurrent last-unit buys can't both win.

**Order + refund flow** (replaces the legacy `seller_bridge` HTTP shortcut):
`/select → /init → /confirm` for orders; `/update {refund_request}` →
seller `RefundRequest` → seller approves → Xendit refund → `/on_update` chain.

## Identity & ACL — "Sign in with Beli Aman"

**Beli Aman BAP is the network Identity Provider.** One Google sign-in
(Firebase `beli-aman-prod`) is the identity for buyers AND seller-dashboard
operators AND Vibe-admin editors.

- Canonical user table: `beli_aman.profiles` (+ `is_super_admin`).
- Canonical ACL: `beli_aman.store_memberships` — `(email → store_id/store_slug → role)`,
  roles `owner` | `staff`. Pending invites have `profile_id NULL` and
  auto-claim on the invitee's first sign-in.
- Super admins (`hallucinogenplus@gmail.com`, `lwastuargo@gmail.com`) bypass
  all membership checks.

**IdP API** (`https://api.beli-aman.metatech.id/api/v1/…`):
`GET /me`, `GET /me/stores`, `GET /me/can-admin?slug=`,
`GET|POST|DELETE /stores/{id}/members`, `POST /identity/seed-membership`
(admin-token), `POST /identity/ensure-tables`, `GET /identity/overview`
(admin-token — full identity+ACL dump for observability).

**Who consults the IdP:**
- Seller dashboard: identity + `/me/stores` from IdP, joins store details from
  the seller catalog API.
- Buyer Vibe admin (`*.beliaman.com/admin`): gates on `/me/can-admin?slug=`;
  legacy email allowlist remains only as a fallback.

One invite via the seller dashboard `/settings/team` ⇒ access on both the
seller dashboard and the Vibe editor. No second ACL.

## Production Databases

One **Neon** project (serverless Postgres, AWS `ap-southeast-1`), host
`ep-shy-heart-a1atpe0m.ap-southeast-1.aws.neon.tech`, role `neondb_owner`,
**two logical databases**:

| DB | App | Tables (key) |
|---|---|---|
| `beli_aman` | Beli Aman BAP (IdP) | `profiles`, `store_memberships`, escrow ledger, disputes, `mirror_*` catalog cache, beckn logs |
| `neondb` | Seller BPP | `stores`, `products`, `skus`, `orders`, `refund_requests`, `beckn_*_logs`, vestigial seller-side `users`/`store_memberships` |

The network app has its own subscriber store. **Local `.env` files point at
`localhost:5432` — dev only; Vercel `DATABASE_URL` env overrides to Neon in
prod.** Connection string: `postgresql+asyncpg://neondb_owner:<pw>@ep-shy-heart-a1atpe0m.ap-southeast-1.aws.neon.tech/<db>?ssl=require`.
Schema is auto-applied via `Base.metadata.create_all` on cold start (idempotent).

## This Repo: Network (Registry + Gateway)

The network app is a **stateless Beckn router** + participant directory. It does
NOT own catalog, orders, or identity.

- **Registry** (port 3030 local): `POST /subscribe`, `POST /lookup`,
  `GET /subscribers`, `DELETE /subscribers/{id}`. Backed by a `subscribers`
  table + Redis read-cache. Holds each subscriber's signing public key.
- **Gateway** (port 4030 local): `POST /search` — receives a BAP search,
  multicasts to matching BPPs discovered from the registry.
- **Dashboard** (`jaringan-dagang.metatech.id`): Next.js, proxies
  `/api/registry/*` to the registry via `NEXT_PUBLIC_REGISTRY_URL`. Tabs:
  Network topology, Registry explorer, Register, Protocol, Specs.

**Subscriber onboarding:** `subscribers.yaml` + `scripts/register-subscribers.py`
(idempotent). Each of the 4 tokos (`safiyafood`, `antarestar`, `gendes`,
`yourbrand`) registered as a BPP; `beli-aman` as a BAP. Production registry is
reachable via the dashboard's `/api/registry/*` proxy (the bare
`registry.metatech.id` host does not resolve — use the proxy or the configured
`NEXT_PUBLIC_REGISTRY_URL`).

### Key Files
- `registry/main.py` — subscribe/lookup/admin endpoints
- `gateway/main.py` — search multicast
- `subscribers.yaml`, `scripts/register-subscribers.py` — onboarding
- `packages/beckn-protocol/python/` — shared signer/envelope/registry-client
  (vendored per-repo; `signer.py` uses pynacl Ed25519, Beckn 1.1 sig scheme)
- `onboarding-portal/` — the Next.js network dashboard

### Key Design Decisions
- **Network stays stateless.** Catalog/orders/identity deliberately do NOT live
  here — keeps the network a thin trust+discovery layer (ONDC-style).
- **Registry caching is mandatory** — without the Redis/static cache, every
  Beckn verify would hit the registry. After warm-up it's ~1 lookup/subscriber/hour.
- **`beckn-protocol` is vendored, not a shared package** — each repo has its
  own copy under `packages/beckn-protocol/python/` (Vercel rootDirectory
  isolation makes a shared path-dep impractical). Keep the three copies in sync.

## Known Caveats / TODO
- Vercel bot-challenge ("Security Checkpoint") intermittently blocks automated
  curl of the *frontend* domains; backend APIs are unaffected.
- Per-toko signing live for Safiya only; other 3 tokos still sign with the
  process key until rotated via seller `POST /api/admin/rotate-store-key`.
- Beckn `/on_search` push is awaited inline on Vercel and can hit function
  timeouts on large catalogs — the buyer still completes the upsert (data is
  correct); only the seller's success flag is unreliable. Move to a queue /
  `waitUntil` when it matters.
- Seller-side `users`/`store_memberships` tables are vestigial; Beli Aman is
  the ACL source of truth now.
