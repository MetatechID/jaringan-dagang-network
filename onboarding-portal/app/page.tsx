"use client";

import { useState, useEffect } from "react";
import { Subscriber } from "@/lib/types";
import { fetchSubscribers, computeStats } from "@/lib/api";
import { StatsBar } from "@/components/StatsBar";
import { NetworkTopology } from "@/components/NetworkTopology";
import { ParticipantTable } from "@/components/ParticipantTable";
import { LiveSearchDemo } from "@/components/LiveSearchDemo";

export default function NetworkDashboard() {
  const [subscribers, setSubscribers] = useState<Subscriber[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function load() {
      const data = await fetchSubscribers();
      setSubscribers(data);
      setLoading(false);
    }
    load();
    // Refresh every 30s
    const interval = setInterval(async () => {
      const data = await fetchSubscribers();
      setSubscribers(data);
    }, 30000);
    return () => clearInterval(interval);
  }, []);

  const stats = computeStats(subscribers);

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="w-12 h-12 rounded-full border-2 border-cyan-400 border-t-transparent animate-spin mx-auto mb-4" />
          <p className="text-sm text-slate-500">
            Connecting to network...
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className="grid-bg min-h-screen">
      {/* Hero section */}
      <div className="relative overflow-hidden border-b border-cyan-900/20">
        <div className="absolute inset-0 bg-gradient-to-b from-cyan-500/5 to-transparent" />
        <div className="relative mx-auto max-w-7xl px-4 sm:px-6 py-8">
          <div className="flex items-start justify-between mb-6">
            <div>
              <h1 className="text-2xl font-bold text-white tracking-tight">
                Network Control Center
              </h1>
              <p className="text-sm text-slate-400 mt-1">
                Real-time view of Indonesia&apos;s Beckn open commerce network
              </p>
            </div>
            <div className="flex items-center gap-3">
              <div className="text-right">
                <div className="text-[10px] text-slate-600 uppercase tracking-wider">
                  Last Updated
                </div>
                <div className="text-xs text-slate-400 font-mono">
                  {new Date().toLocaleTimeString()}
                </div>
              </div>
              <button
                onClick={async () => {
                  setLoading(true);
                  const data = await fetchSubscribers();
                  setSubscribers(data);
                  setLoading(false);
                }}
                className="p-2 rounded-lg border border-cyan-900/30 hover:bg-cyan-400/5 transition-colors"
                title="Refresh"
              >
                <svg
                  className="w-4 h-4 text-cyan-400"
                  viewBox="0 0 16 16"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="1.5"
                >
                  <path d="M2 8 A6 6 0 0 1 14 8" />
                  <path d="M14 8 A6 6 0 0 1 2 8" />
                  <path d="M14 4 L14 8 L10 8" />
                </svg>
              </button>
            </div>
          </div>

          <StatsBar stats={stats} />
        </div>
      </div>

      <div className="mx-auto max-w-7xl px-4 sm:px-6 py-8 space-y-8">
        {/* Network Topology */}
        <section>
          <div className="flex items-center gap-2 mb-4">
            <h2 className="text-lg font-semibold text-white">
              Network Topology
            </h2>
            <span className="text-xs text-slate-600 font-mono">
              LIVE
            </span>
            <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
          </div>
          <NetworkTopology subscribers={subscribers} />
        </section>

        {/* Live Search Demo */}
        <section>
          <LiveSearchDemo />
        </section>

        {/* Participants Table */}
        <section>
          <ParticipantTable subscribers={subscribers} />
        </section>
      </div>
    </div>
  );
}
