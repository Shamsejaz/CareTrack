import { createFileRoute, Link } from "@tanstack/react-router";
import { Check, Sparkles } from "lucide-react";
import { Header } from "@/components/site/Header";
import { Footer } from "@/components/site/Footer";
import { Reveal } from "@/components/site/Reveal";
import { Button } from "@/components/ui/button";

const FAQ_ITEMS = [
  { q: "Is there a free trial?", a: "Yes — Premium and Family both come with a 14-day free trial. No card required to start." },
  { q: "Which languages do you support?", a: "English, Arabic, Urdu, Spanish and more — with new languages added regularly." },
  { q: "How is my health data protected?", a: "All data is encrypted in transit and at rest. We're built to HIPAA, GDPR and PDPL standards." },
  { q: "Can I cancel anytime?", a: "Of course. Cancel in one tap from the app — no fees, no questions." },
];

export const Route = createFileRoute("/pricing")({
  head: () => ({
    meta: [
      { title: "Pricing — CareTrackAI" },
      { name: "description", content: "Simple, transparent pricing. Start free. Upgrade for AI features and family caregiver plans." },
      { property: "og:title", content: "CareTrackAI Pricing" },
      { property: "og:description", content: "Free, Premium and Family plans for every kind of care." },
    ],
    links: [{ rel: "canonical", href: "https://mindful-health-routines.lovable.app/pricing" }],
    scripts: [
      {
        type: "application/ld+json",
        children: JSON.stringify({
          "@context": "https://schema.org",
          "@type": "FAQPage",
          mainEntity: FAQ_ITEMS.map((f) => ({
            "@type": "Question",
            name: f.q,
            acceptedAnswer: { "@type": "Answer", text: f.a },
          })),
        }),
      },
    ],
  }),
  component: PricingPage,
});

const plans = [
  {
    name: "Free",
    price: "0",
    sub: "forever",
    desc: "Manual tracking for individuals getting started.",
    cta: "Get Started",
    features: ["Manual medicine tracking", "Basic reminders", "1 user", "Health log"],
    featured: false,
  },
  {
    name: "Premium",
    price: "9",
    sub: "/month",
    desc: "AI-powered care for one person.",
    cta: "Start 14-day Trial",
    features: ["Everything in Free", "Prescription AI & OCR", "Smart adaptive reminders", "Food photo analysis", "Health insights & reports"],
    featured: true,
  },
  {
    name: "Family",
    price: "19",
    sub: "/month",
    desc: "For caregivers looking after loved ones.",
    cta: "Start Family Plan",
    features: ["Everything in Premium", "Up to 5 users", "Real-time caregiver alerts", "Remote monitoring dashboard", "Priority support"],
    featured: false,
  },
];

function PricingPage() {
  return (
    <div className="min-h-screen bg-background">
      <Header />

      <section className="gradient-hero">
        <div className="mx-auto max-w-7xl px-5 lg:px-8 pt-20 pb-16 text-center">
          <h1 className="font-display text-4xl sm:text-6xl font-semibold max-w-3xl mx-auto leading-tight">
            Simple pricing. <span className="italic text-deep-green">Real care.</span>
          </h1>
          <p className="mt-5 text-lg text-muted-foreground max-w-xl mx-auto">
            Start free. Upgrade when you're ready for AI superpowers and family-level care.
          </p>
        </div>
      </section>

      <section className="mx-auto max-w-7xl px-5 lg:px-8 mt-12">
        <h2 className="sr-only">Plans</h2>
        <div className="grid md:grid-cols-3 gap-5">
        {plans.map((p, i) => (
          <Reveal key={p.name} delay={i * 80}>
            <div className={`relative rounded-3xl p-8 h-full border ${p.featured ? "bg-primary text-primary-foreground border-primary shadow-elevated" : "bg-card border-border shadow-soft"}`}>
              {p.featured && (
                <div className="absolute -top-3 left-1/2 -translate-x-1/2 inline-flex items-center gap-1 rounded-full bg-amber-soft px-3 py-1 text-xs font-semibold text-deep-green">
                  <Sparkles className="size-3" /> Most Popular
                </div>
              )}
              <h3 className="font-display text-2xl font-semibold">{p.name}</h3>
              <p className={`mt-1 text-sm ${p.featured ? "text-primary-foreground/70" : "text-muted-foreground"}`}>{p.desc}</p>
              <div className="mt-6 flex items-baseline gap-1">
                <span className="font-display text-5xl font-semibold">${p.price}</span>
                <span className={`text-sm ${p.featured ? "text-primary-foreground/70" : "text-muted-foreground"}`}>{p.sub}</span>
              </div>
              <Button asChild className={`mt-6 w-full rounded-full ${p.featured ? "bg-amber-soft text-deep-green hover:bg-amber-soft/90" : ""}`} variant={p.featured ? "default" : "outline"}>
                <Link to="/contact">{p.cta}</Link>
              </Button>
              <ul className="mt-8 space-y-3">
                {p.features.map((f) => (
                  <li key={f} className="flex items-start gap-3 text-sm">
                    <Check className={`size-5 shrink-0 ${p.featured ? "text-amber-soft" : "text-deep-green"}`} />
                    <span>{f}</span>
                  </li>
                ))}
              </ul>
            </div>
          </Reveal>
        ))}
        </div>
      </section>

      <section className="mx-auto max-w-4xl px-5 lg:px-8 mt-24">
        <h2 className="font-display text-3xl sm:text-4xl font-semibold text-center">Frequently asked</h2>
        <div className="mt-10 space-y-4">
          {FAQ_ITEMS.map((f) => (
            <div key={f.q} className="rounded-2xl border border-border bg-card p-6">
              <h3 className="font-semibold text-foreground">{f.q}</h3>
              <p className="mt-2 text-muted-foreground">{f.a}</p>
            </div>
          ))}
        </div>
      </section>

      <Footer />
    </div>
  );
}
