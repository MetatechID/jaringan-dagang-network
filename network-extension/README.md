# Indonesia Network Extension Layer

This directory defines Indonesia-specific standards, taxonomies, and configurations for the Beckn commerce network operating under the **Jaringan Dagang** project.

## Purpose

The Beckn protocol is domain-agnostic and country-agnostic by design. This extension layer localizes the protocol for the Indonesian market by providing:

- **Domain definitions** with sub-domains tailored to Indonesian commerce patterns
- **City codes** using the Indonesian telephone area code standard (`std:XXX`)
- **Payment methods** covering QRIS, virtual accounts, e-wallets, cards, and retail counters
- **Logistics providers** mapping Indonesian couriers to the Beckn Fulfillment schema
- **Category taxonomies** with Bahasa Indonesia labels and local product classifications

## Directory Structure

```
infra/network-extension/
├── README.md                    # This file
├── cities.yaml                  # 30 major Indonesian cities with Beckn city codes
├── payment-methods.yaml         # All payment methods mapped to Beckn Payment schema
├── logistics-providers.yaml     # Courier services mapped to Beckn Fulfillment schema
├── domains/
│   ├── retail.yaml              # Retail domain (ONDC:RET) with sub-domains
│   ├── food-beverage.yaml       # F&B domain (ONDC:FNB) with fulfillment types
│   └── logistics.yaml           # Logistics domain (ONDC:LOG) with shipping zones
└── categories/
    ├── food.yaml                # Food & grocery taxonomy (bumbu, minuman, mie, etc.)
    ├── fashion.yaml             # Fashion taxonomy (batik, hijab, tenun, etc.)
    └── electronics.yaml         # Electronics taxonomy (HP, komputer, TV, etc.)
```

## Schema Conventions

Every entry in the YAML files follows a consistent structure:

| Field | Description |
|---|---|
| `code` | Unique machine-readable identifier |
| `name` | English display name |
| `name_id` | Bahasa Indonesia display name |
| `description` | Human-readable explanation of the entry |
| `beckn_*` | Mapping fields to Beckn protocol schemas (e.g., `beckn_domain`, `beckn_category_id`, `beckn_payment_type`) |

## How to Use

### 1. City Codes in Beckn Context

When constructing a Beckn `Context` object, use the city code from `cities.yaml`:

```json
{
  "context": {
    "domain": "ONDC:RET10",
    "country": "IND",
    "city": "std:031",
    "action": "search"
  }
}
```

### 2. Payment Methods in Beckn Order

Reference payment method codes from `payment-methods.yaml` when building a Beckn `Payment` object:

```json
{
  "payment": {
    "type": "ON-ORDER",
    "collected_by": "BAP",
    "params": {
      "payment_method": "QRIS",
      "currency": "IDR"
    }
  }
}
```

### 3. Fulfillment with Logistics Providers

Map logistics service codes from `logistics-providers.yaml` to Beckn `Fulfillment`:

```json
{
  "fulfillment": {
    "type": "Delivery",
    "provider_id": "jne.co.id",
    "category": "Express Delivery",
    "tags": {
      "service_code": "JNE_YES"
    }
  }
}
```

### 4. Category Taxonomy in Catalog

Use category codes from the `categories/` files when publishing items to a Beckn catalog:

```json
{
  "item": {
    "category_id": "FOOD_BUMBU_SAMBAL",
    "descriptor": {
      "name": "Sambal Terasi Bu Rudy",
      "short_desc": "Sambal terasi khas Surabaya"
    }
  }
}
```

## Data Sources

- City area codes: Indonesian telecommunications numbering plan
- Payment methods: Bank Indonesia QRIS standard, major payment gateway integrations
- Logistics providers: Active Indonesian courier and delivery services
- Categories: Common product taxonomy used by Indonesian e-commerce platforms

## Updating

When adding new entries:

1. Follow the existing YAML structure and field naming conventions
2. Always include both `name` (English) and `name_id` (Bahasa Indonesia) fields
3. Provide a `code` that is unique within its file
4. Include relevant `beckn_*` mapping fields for protocol interoperability
5. Add `description` to clarify scope and purpose
