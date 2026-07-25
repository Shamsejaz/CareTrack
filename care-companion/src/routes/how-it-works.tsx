import { createFileRoute } from "@tanstack/react-router";
import { Upload, Brain, Bell, Camera, TrendingUp } from "lucide-react";
import { Header } from "@/components/site/Header";
import { Footer } from "@/components/site/Footer";
import { Reveal } from "@/components/site/Reveal";
import { CTASection } from "@/components/site/CTASection";

export const Route = createFileRoute("/how-it-works")({
  head: () => ({
    meta: [
      { title: "How CareTrackAI Works — From Prescription to Peace of Mind" },
      { name: "description", content: "Upload a prescription, let AI build your daily plan, and stay on track with gentle reminders and photo confirmations." },
      { property: "og:title", content: "How CareTrackAI Works" },
      { property: "og:description", content: "Five simple steps from prescription to peace of mind." },
    ],
  }),
  component: HowItWorksPage,
});

const steps = [
  { i: Upload, t: "Upload your prescription", d: "Snap a photo or upload a PDF. CareTrackAI reads doses, timings, and warnings automatically.", ex: "A handwritten prescription becomes 4 reminders, perfectly timed around your meals." },
  { i: Brain, t: "AI understands everything", d: "Our medical AI checks for interactions and builds a personal daily plan — in your language.", ex: "Translated into your language, simplified for any user, reviewed in seconds." },
  { i: Bell, t: "Daily reminders begin", d: "Gentle alerts arrive when you need them — and escalate to caregivers if missed.", ex: "Mom hasn't confirmed her 9am dose. You get a quiet ping at 9:15." },
  { i: Camera, t: "Confirm with a photo", d: "A quick snap of the pill keeps everyone honest — and reassured.", ex: "One tap, one photo, full peace of mind for the family." },
  { i: TrendingUp, t: "AI improves your routine", d: "CareTrackAI learns from your data and quietly nudges you toward better days.", ex: "Sugar trending up? CareTrackAI suggests a meal swap before it spikes." },
];

function HowItWorksPage() {
  return (
    <div className="min-h-screen bg-background">
      <Header />

      <section className="gradient-hero">
        <div className="mx-auto max-w-7xl px-5 lg:px-8 pt-20 pb-16 text-center">
          <h1 className="font-display text-4xl sm:text-6xl font-semibold max-w-3xl mx-auto leading-tight">
            How CareTrackAI <span className="italic text-deep-green">works.</span>
          </h1>
          <p className="mt-5 text-lg text-muted-foreground max-w-2xl mx-auto">
            Five gentle steps. Built for real people, real prescriptions, and real life.
          </p>
        </div>
      </section>

      <section className="mx-auto max-w-4xl px-5 lg:px-8 mt-20 relative">
        <div className="absolute left-[2.25rem] top-0 bottom-0 w-px bg-border hidden sm:block" />
        <div className="space-y-12">
          {steps.map((s, i) => (
            <Reveal key={s.t} delay={i * 80}>
              <div className="relative flex gap-6">
                <div className="relative flex-shrink-0">
                  <div className="size-[72px] rounded-2xl gradient-cta flex items-center justify-center shadow-soft text-primary-foreground">
                    <s.i className="size-7" />
                  </div>
                </div>
                <div className="flex-1 pt-1">
                  <p className="text-sm font-medium text-deep-green">Step {i + 1}</p>
                  <h2 className="mt-1 font-display text-2xl sm:text-3xl font-semibold">{s.t}</h2>
                  <p className="mt-3 text-lg text-muted-foreground">{s.d}</p>
                  <div className="mt-4 rounded-2xl bg-cream border border-border p-5">
                    <p className="text-xs uppercase tracking-widest text-deep-green font-medium">Real example</p>
                    <p className="mt-2 text-foreground">{s.ex}</p>
                  </div>
                </div>
              </div>
            </Reveal>
          ))}
        </div>
      </section>

      <CTASection />
      <Footer />
    </div>
  );
}
