import { createFileRoute, Link } from "@tanstack/react-router";
import { Brain, Bell, Activity, Utensils, Pill, Users, Smartphone, Sparkles, ArrowRight, Mic, Bot } from "lucide-react";
import { Header } from "@/components/site/Header";
import { Footer } from "@/components/site/Footer";
import { Reveal } from "@/components/site/Reveal";
import { CTASection } from "@/components/site/CTASection";
import { Button } from "@/components/ui/button";
import foodImg from "@/assets/food-ai.jpg";

export const Route = createFileRoute("/features")({
  head: () => ({
    meta: [
      { title: "Features — CareTrackAI AI Health Assistant" },
      { name: "description", content: "Prescription OCR, smart reminders, food intelligence, caregiver alerts, health tracking and device integration — all in CareTrackAI." },
      { property: "og:title", content: "CareTrackAI Features" },
      { property: "og:description", content: "Everything care needs in one calm, beautiful app." },
    ],
  }),
  component: FeaturesPage,
});

const sections = [
  { i: Brain, t: "AI Brain", d: "Prescription OCR, personalized daily plan, and a smart intervention engine that learns your routine." , bullets: ["Prescription OCR", "Personalized daily plan", "Smart interventions"] },
  { i: Bell, t: "Smart Reminders", d: "Mandatory confirmation, escalation alerts, and adaptive timing that fits real life — not the other way around.", bullets: ["Mandatory confirmation", "Escalation to caregivers", "Adaptive timing"] },
  { i: Activity, t: "Health Tracking", d: "Track sugar, blood pressure and vitals with beautiful trends and AI insights.", bullets: ["Glucose & BP", "Weight & vitals", "Insightful graphs"] },
  { i: Utensils, t: "Food Intelligence", d: "Snap your meal. Get carbs, sugar impact, and friendlier alternatives.", bullets: ["Photo-based analysis", "Carb & sugar impact", "Smart suggestions"] },
  { i: Pill, t: "Medicine Management", d: "Auto-scheduled doses, missed-dose tracking, and refills before you run out.", bullets: ["Auto schedule", "Missed dose tracking", "Refill reminders"] },
  { i: Users, t: "Caregiver Support", d: "Real-time alerts and remote monitoring keep families connected and informed.", bullets: ["Real-time alerts", "Remote monitoring", "Multi-user access"] },
  { i: Smartphone, t: "Device Integration", d: "Pairs beautifully with wearables and smart health devices you already trust.", bullets: ["Wearables", "Smart glucometers", "BP monitors"] },
  { i: Mic, t: "Conversational Voice", d: "Push-to-Talk voice assistant that understands natural language to log health events.", bullets: ["Push-to-Talk", "Natural language", "Effortless logging"] },
  { i: Bot, t: "Home Robotics", d: "Dispatch physical tasks to home assistive robots directly from your app.", bullets: ["Task dispatch", "Real-time tracking", "Caregiver dashboard sync"] },
];

function FeaturesPage() {
  return (
    <div className="min-h-screen bg-background">
      <Header />

      <section className="gradient-hero">
        <div className="mx-auto max-w-7xl px-5 lg:px-8 pt-20 pb-16 text-center">
          <div className="inline-flex items-center gap-2 rounded-full border border-border bg-card px-3 py-1 text-xs text-muted-foreground shadow-soft">
            <Sparkles className="size-3 text-deep-green" /> All features
          </div>
          <h1 className="mt-5 font-display text-4xl sm:text-6xl font-semibold max-w-3xl mx-auto leading-tight">
            A full care system. <span className="italic text-deep-green">Beautifully simple.</span>
          </h1>
          <p className="mt-5 text-lg text-muted-foreground max-w-2xl mx-auto">
            Every CareTrackAI feature is built around one promise: less worry, more wellbeing.
          </p>
        </div>
      </section>

      <section className="mx-auto max-w-7xl px-5 lg:px-8 mt-16 space-y-6">
        {sections.map((s, i) => (
          <Reveal key={s.t} delay={i * 50}>
            <div className={`rounded-3xl bg-card border border-border p-8 lg:p-12 grid lg:grid-cols-2 gap-8 items-center shadow-soft ${i % 2 === 1 ? "lg:[&>*:first-child]:order-2" : ""}`}>
              <div>
                <div className="size-14 rounded-2xl gradient-cta flex items-center justify-center shadow-soft">
                  <s.i className="size-6 text-primary-foreground" />
                </div>
                <h2 className="mt-5 font-display text-3xl sm:text-4xl font-semibold">{s.t}</h2>
                <p className="mt-3 text-lg text-muted-foreground">{s.d}</p>
                <ul className="mt-6 space-y-2">
                  {s.bullets.map((b) => (
                    <li key={b} className="flex items-center gap-2 text-foreground">
                      <span className="size-1.5 rounded-full bg-deep-green" /> {b}
                    </li>
                  ))}
                </ul>
              </div>
              <div className="rounded-2xl bg-cream border border-border aspect-[4/3] flex items-center justify-center overflow-hidden">
                {s.t === "Food Intelligence" ? (
                  <img src={foodImg} alt="Food analyzed by CareTrackAI AI" loading="lazy" className="w-full h-full object-cover" />
                ) : (
                  <s.i className="size-24 text-deep-green/30" strokeWidth={1.2} />
                )}
              </div>
            </div>
          </Reveal>
        ))}
      </section>

      <div className="mt-16 text-center">
        <Button asChild size="lg" className="rounded-full px-7">
          <Link to="/pricing">See pricing <ArrowRight className="ml-1 size-4" /></Link>
        </Button>
      </div>

      <CTASection />
      <Footer />
    </div>
  );
}
