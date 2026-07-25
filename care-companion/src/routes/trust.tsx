import { createFileRoute } from "@tanstack/react-router";
import { ShieldCheck, Lock, FileCheck, Globe } from "lucide-react";
import { Header } from "@/components/site/Header";
import { Footer } from "@/components/site/Footer";
import { Reveal } from "@/components/site/Reveal";

export const Route = createFileRoute("/trust")({
  head: () => ({
    meta: [
      { title: "Trust & Privacy — CareTrackAI" },
      { name: "description", content: "How CareTrackAI protects your health data. Global privacy standards, encrypted end-to-end, and built on principles you can trust." },
      { property: "og:title", content: "Trust & Privacy at CareTrackAI" },
      { property: "og:description", content: "Your health data, safely yours." },
    ],
  }),
  component: TrustPage,
});

function TrustPage() {
  return (
    <div className="min-h-screen bg-background">
      <Header />
      <section className="gradient-hero">
        <div className="mx-auto max-w-7xl px-5 lg:px-8 pt-20 pb-16 text-center">
          <div className="inline-flex items-center gap-2 rounded-full border border-border bg-card px-3 py-1 text-xs text-muted-foreground shadow-soft">
            <ShieldCheck className="size-3 text-deep-green" /> Trust & Privacy
          </div>
          <h1 className="mt-5 font-display text-4xl sm:text-6xl font-semibold max-w-3xl mx-auto leading-tight">
            Your data is <span className="italic text-deep-green">safe.</span>
          </h1>
          <p className="mt-5 text-lg text-muted-foreground max-w-xl mx-auto">
            Built from day one for the world's strictest health data standards, including HIPAA, GDPR and PDPL.
          </p>
        </div>
      </section>

      <section className="mx-auto max-w-7xl px-5 lg:px-8 mt-16 grid md:grid-cols-2 lg:grid-cols-4 gap-5">
        {[
          { i: Lock, t: "End-to-end encryption", d: "All health data encrypted in transit and at rest with industry-leading standards." },
          { i: FileCheck, t: "Global compliance", d: "Designed for HIPAA, GDPR, PDPL and other major data protection laws." },
          { i: ShieldCheck, t: "Audit & access logs", d: "Every access is logged. You always see who saw what, and when." },
          { i: Globe, t: "Regional data residency", d: "Choose where your data lives — across global regions." },
        ].map((b) => (
          <Reveal key={b.t}>
            <div className="rounded-3xl bg-card border border-border p-7 h-full">
              <div className="size-12 rounded-2xl gradient-cta flex items-center justify-center"><b.i className="size-5 text-primary-foreground" /></div>
              <h3 className="mt-4 font-display text-xl font-semibold">{b.t}</h3>
              <p className="mt-2 text-muted-foreground">{b.d}</p>
            </div>
          </Reveal>
        ))}
      </section>

      <section className="mx-auto max-w-3xl px-5 lg:px-8 mt-20 prose prose-neutral">
        <h2 className="font-display text-3xl font-semibold">Our promises</h2>
        <ul className="mt-6 space-y-4 text-muted-foreground">
          <li>• We never sell your health data. Ever.</li>
          <li>• Your data is yours — export or delete it any time.</li>
          <li>• We minimize what we collect and store only what's needed.</li>
          <li>• Caregiver access is always granted by you, and revocable in one tap.</li>
          <li>• Independent security audits run on a regular cadence.</li>
        </ul>
      </section>

      <Footer />
    </div>
  );
}
