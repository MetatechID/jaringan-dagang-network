import { Subscriber, NetworkStats } from "./types";

const REGISTRY_URL = "/api/registry";
const BAP_URL = "/api/bap";

export async function fetchSubscribers(): Promise<Subscriber[]> {
  try {
    const res = await fetch(`${REGISTRY_URL}/subscribers`, {
      cache: "no-store",
    });
    if (!res.ok) throw new Error(`Registry responded ${res.status}`);
    return res.json();
  } catch {
    return getMockSubscribers();
  }
}

export async function fetchHealth(
  service: "registry" | "gateway" | "bap" | "bpp"
): Promise<boolean> {
  const urls: Record<string, string> = {
    registry: `${REGISTRY_URL}/health`,
    gateway: "/api/gateway/health",
    bap: `${BAP_URL}/health`,
    bpp: "/api/bpp/health",
  };
  try {
    const res = await fetch(urls[service], { cache: "no-store" });
    return res.ok;
  } catch {
    return false;
  }
}

export async function registerSubscriber(data: {
  subscriber_id: string;
  subscriber_url: string;
  type: string;
  domain: string;
  city: string;
  signing_public_key: string;
  encr_public_key: string;
}): Promise<{ success: boolean; data?: Subscriber; error?: string }> {
  try {
    const res = await fetch(`${REGISTRY_URL}/subscribe`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        ...data,
        country: "IDN",
        valid_from: new Date().toISOString(),
        valid_until: new Date(
          Date.now() + 365 * 24 * 60 * 60 * 1000
        ).toISOString(),
      }),
    });
    if (!res.ok) {
      const err = await res.text();
      return { success: false, error: err };
    }
    const result = await res.json();
    return { success: true, data: result };
  } catch (e: unknown) {
    const msg = e instanceof Error ? e.message : "Unknown error";
    return { success: false, error: msg };
  }
}

export async function searchProducts(
  query: string
): Promise<{ searchId: string } | null> {
  try {
    const res = await fetch(`${BAP_URL}/api/search`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        query,
        domain: "retail",
        city: "std:062",
      }),
    });
    if (!res.ok) return null;
    return res.json();
  } catch {
    return null;
  }
}

export async function pollSearchResults(
  searchId: string
): Promise<{ results: unknown[]; complete: boolean }> {
  try {
    const res = await fetch(`${BAP_URL}/api/search/${searchId}/results`);
    if (!res.ok) return { results: [], complete: false };
    return res.json();
  } catch {
    return { results: [], complete: false };
  }
}

export function computeStats(subscribers: Subscriber[]): NetworkStats {
  const cities = Array.from(new Set(subscribers.map((s) => s.city)));
  const domains = Array.from(new Set(subscribers.map((s) => s.domain)));
  return {
    total: subscribers.length,
    baps: subscribers.filter((s) => s.type === "BAP").length,
    bpps: subscribers.filter((s) => s.type === "BPP").length,
    gateways: subscribers.filter((s) => s.type === "BG").length,
    cities,
    domains,
  };
}

function getMockSubscribers(): Subscriber[] {
  return [
    {
      subscriber_id: "toko-online.example.com",
      subscriber_url: "http://localhost:8002",
      type: "BAP",
      domain: "retail",
      city: "std:062",
      country: "IDN",
      signing_public_key: "MCowBQYDK2VwAyEA...",
      encr_public_key: "MCowBQYDK2VuAyEA...",
      status: "SUBSCRIBED",
      created: "2026-03-01T10:00:00Z",
      updated: "2026-03-01T10:00:00Z",
      valid_from: "2026-03-01T10:00:00Z",
      valid_until: "2027-03-01T10:00:00Z",
    },
    {
      subscriber_id: "warung-pintar.example.com",
      subscriber_url: "http://localhost:8001",
      type: "BPP",
      domain: "retail",
      city: "std:062",
      country: "IDN",
      signing_public_key: "MCowBQYDK2VwAyEA...",
      encr_public_key: "MCowBQYDK2VuAyEA...",
      status: "SUBSCRIBED",
      created: "2026-03-01T10:00:00Z",
      updated: "2026-03-01T10:00:00Z",
      valid_from: "2026-03-01T10:00:00Z",
      valid_until: "2027-03-01T10:00:00Z",
    },
    {
      subscriber_id: "grabmart-id.example.com",
      subscriber_url: "http://grabmart.local:8001",
      type: "BPP",
      domain: "food-beverage",
      city: "std:021",
      country: "IDN",
      signing_public_key: "MCowBQYDK2VwAyEA...",
      encr_public_key: "MCowBQYDK2VuAyEA...",
      status: "SUBSCRIBED",
      created: "2026-03-15T08:30:00Z",
      updated: "2026-03-15T08:30:00Z",
      valid_from: "2026-03-15T08:30:00Z",
      valid_until: "2027-03-15T08:30:00Z",
    },
    {
      subscriber_id: "tokopedia-bap.example.com",
      subscriber_url: "http://tokopedia-bap.local:8002",
      type: "BAP",
      domain: "retail",
      city: "std:021",
      country: "IDN",
      signing_public_key: "MCowBQYDK2VwAyEA...",
      encr_public_key: "MCowBQYDK2VuAyEA...",
      status: "SUBSCRIBED",
      created: "2026-03-20T14:00:00Z",
      updated: "2026-03-20T14:00:00Z",
      valid_from: "2026-03-20T14:00:00Z",
      valid_until: "2027-03-20T14:00:00Z",
    },
    {
      subscriber_id: "jne-logistics.example.com",
      subscriber_url: "http://jne.local:8003",
      type: "BPP",
      domain: "logistics",
      city: "std:021",
      country: "IDN",
      signing_public_key: "MCowBQYDK2VwAyEA...",
      encr_public_key: "MCowBQYDK2VuAyEA...",
      status: "SUBSCRIBED",
      created: "2026-04-01T09:00:00Z",
      updated: "2026-04-01T09:00:00Z",
      valid_from: "2026-04-01T09:00:00Z",
      valid_until: "2027-04-01T09:00:00Z",
    },
    {
      subscriber_id: "new-merchant.example.com",
      subscriber_url: "http://new-merchant.local:8005",
      type: "BPP",
      domain: "retail",
      city: "std:031",
      country: "IDN",
      signing_public_key: "MCowBQYDK2VwAyEA...",
      encr_public_key: "MCowBQYDK2VuAyEA...",
      status: "INITIATED",
      created: "2026-04-04T16:00:00Z",
      updated: "2026-04-04T16:00:00Z",
      valid_from: "2026-04-04T16:00:00Z",
      valid_until: "2027-04-04T16:00:00Z",
    },
  ];
}
