import { createFileRoute, Link } from "@tanstack/react-router";
import { ArrowRight, Sparkles, ShieldCheck, Camera, Bell, Activity, HeartHandshake, CheckCircle2, Star, Quote } from "lucide-react";
import { Header } from "@/components/site/Header";
import { Footer } from "@/components/site/Footer";
import { PhoneMockup } from "@/components/site/PhoneMockup";
import { Reveal } from "@/components/site/Reveal";
import { CTASection } from "@/components/site/CTASection";
import { Button } from "@/components/ui/button";
import { useI18n } from "@/lib/i18n";
import familyImg from "@/assets/family-care.jpg";
import elderlyImg from "@/assets/hero-elderly.jpg";

export const Route = createFileRoute("/")({
  head: () => ({
    meta: [
      { title: "CareTrackAI — AI Medicine Reminder & Elderly Care App" },
      { name: "description", content: "AI-powered daily health assistant. Smart medicine reminders, diabetes tracking, and caregiver alerts for patients, elderly, and families." },
      { property: "og:title", content: "CareTrackAI — Never Miss a Medicine, Meal, or Moment" },
      { property: "og:description", content: "AI-powered daily health assistant for patients, elderly, and caregivers." },
    ],
  }),
  component: Home,
});

function Home() {
  const { t } = useI18n();
  return (
    <div className="min-h-screen bg-background">
      <Header />

      {/* HERO */}
      <section className="relative gradient-hero overflow-hidden">
        <div className="mx-auto max-w-7xl px-5 lg:px-8 pt-16 pb-24 lg:pt-24 lg:pb-32 grid lg:grid-cols-2 gap-12 lg:gap-8 items-center">
          <div>
            <div className="inline-flex items-center gap-2 rounded-full border border-border bg-card px-3 py-1 text-xs text-muted-foreground shadow-soft">
              <Sparkles className="size-3 text-deep-green" />
              {t("hero.badge")}
            </div>
            <h1 className="mt-6 font-display text-4xl sm:text-5xl lg:text-7xl font-semibold leading-[1.05] text-foreground">
              {t("hero.title.a")} <span className="italic text-deep-green">{t("hero.title.b")}</span>
            </h1>
            <p className="mt-6 text-lg text-muted-foreground max-w-xl">
              {t("hero.subtitle")}
            </p>
            <div className="mt-8 flex flex-col sm:flex-row gap-3">
              <Button asChild size="lg" className="rounded-full px-7 h-12">
                <Link to="/contact">{t("hero.cta.start")} <ArrowRight className="ml-1 size-4" /></Link>
              </Button>
              <Button asChild variant="outline" size="lg" className="rounded-full px-7 h-12 bg-card">
                <Link to="/how-it-works">{t("hero.cta.how")}</Link>
              </Button>
            </div>
            <div className="mt-8 flex items-center gap-4 text-sm text-muted-foreground">
              <div className="flex -space-x-2">
                <div className="size-8 rounded-full bg-amber-soft border-2 border-background" />
                <div className="size-8 rounded-full bg-deep-green border-2 border-background" />
                <div className="size-8 rounded-full bg-foreground border-2 border-background" />
              </div>
              <div className="flex items-center gap-1">
                <Star className="size-4 fill-amber-soft text-amber-soft" />
                <Star className="size-4 fill-amber-soft text-amber-soft" />
                <Star className="size-4 fill-amber-soft text-amber-soft" />
                <Star className="size-4 fill-amber-soft text-amber-soft" />
                <Star className="size-4 fill-amber-soft text-amber-soft" />
                <span className="ml-1">{t("hero.social")}</span>
              </div>
            </div>
          </div>
          <Reveal>
            <PhoneMockup />
          </Reveal>
        </div>
      </section>

      {/* TRUST */}
      <section className="border-y border-border bg-card/50">
        <div className="mx-auto max-w-7xl px-5 lg:px-8 py-10">
          <p className="text-center text-xs uppercase tracking-widest text-muted-foreground">
            {t("trust.heading")}
          </p>
          <div className="mt-6 grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-6 items-center opacity-70">
            {["MediCare", "AlNoor Clinic", "HealthFirst", "DiabetCare", "CareHub", "WellPath"].map((n) => (
              <div key={n} className="text-center font-display font-semibold text-foreground/60">{n}</div>
            ))}
          </div>
        </div>
      </section>

      {/* PROBLEM */}
      <section className="mx-auto max-w-7xl px-5 lg:px-8 mt-24">
        <Reveal>
          <div className="text-center max-w-2xl mx-auto">
            <p className="text-sm font-medium text-deep-green uppercase tracking-widest">{t("problem.kicker")}</p>
            <h2 className="mt-3 font-display text-3xl sm:text-5xl font-semibold">{t("problem.title")}</h2>
          </div>
        </Reveal>
        <div className="mt-12 grid md:grid-cols-3 gap-5">
          {[
            { t: "Forgotten medicines", d: "50% of chronic patients miss doses every week — risking complications." },
            { t: "Uncontrolled sugar", d: "Diabetes spirals when meals, vitals and meds aren't tracked together." },
            { t: "Caregivers in the dark", d: "Family worries because there's no real-time visibility into their loved one's day." },
          ].map((p, i) => (
            <Reveal key={p.t} delay={i * 100}>
              <div className="rounded-3xl bg-card border border-border p-7 h-full shadow-soft">
                <div className="size-10 rounded-2xl bg-amber-soft flex items-center justify-center font-display font-semibold text-deep-green">{i + 1}</div>
                <h3 className="mt-5 font-display text-xl font-semibold">{p.t}</h3>
                <p className="mt-2 text-muted-foreground">{p.d}</p>
              </div>
            </Reveal>
          ))}
        </div>
      </section>

      {/* SOLUTION */}
      <section className="mx-auto max-w-7xl px-5 lg:px-8 mt-24">
        <Reveal>
          <div className="rounded-[2rem] overflow-hidden bg-card border border-border shadow-elevated grid lg:grid-cols-2 items-center">
            <img src={elderlyImg} alt="Elderly woman using CareTrackAI on her phone" loading="lazy" className="w-full h-full object-cover aspect-[4/3] lg:aspect-auto" />
            <div className="p-8 lg:p-14">
              <p className="text-sm font-medium text-deep-green uppercase tracking-widest">{t("solution.kicker")}</p>
              <h2 className="mt-3 font-display text-3xl sm:text-5xl font-semibold">{t("solution.title")}</h2>
              <p className="mt-5 text-lg text-muted-foreground">
                {t("solution.body")}
              </p>
              <ul className="mt-6 space-y-3">
                {[t("solution.b1"), t("solution.b2"), t("solution.b3")].map((b) => (
                  <li key={b} className="flex items-center gap-3 text-foreground">
                    <CheckCircle2 className="size-5 text-deep-green" /> {b}
                  </li>
                ))}
              </ul>
            </div>
          </div>
        </Reveal>
      </section>

      {/* FEATURES */}
      <section className="mx-auto max-w-7xl px-5 lg:px-8 mt-24">
        <Reveal>
          <div className="text-center max-w-2xl mx-auto">
            <p className="text-sm font-medium text-deep-green uppercase tracking-widest">{t("features.kicker")}</p>
            <h2 className="mt-3 font-display text-3xl sm:text-5xl font-semibold">{t("features.title")}</h2>
          </div>
        </Reveal>
        <div className="mt-12 grid md:grid-cols-2 lg:grid-cols-3 gap-5">
          {[
            { i: Bell, t: "Smart reminders", d: "Gentle, adaptive alerts that wait for confirmation — never silent failures." },
            { i: Sparkles, t: "Prescription-aware AI", d: "Snap your prescription. We turn it into a complete personalized plan." },
            { i: Camera, t: "Food photo analysis", d: "Take a photo of your meal. Get carbs, sugar impact and better choices." },
            { i: HeartHandshake, t: "Caregiver alerts", d: "Family is notified the moment something needs attention — not later." },
            { i: Activity, t: "Health dashboard", d: "Sugar, BP, weight and meds — all in one calm, beautiful view." },
            { i: ShieldCheck, t: "Private by design", d: "Your health data stays encrypted and yours. Always." },
          ].map((f, i) => (
            <Reveal key={f.t} delay={i * 60}>
              <div className="group rounded-3xl bg-card border border-border p-7 h-full hover:shadow-elevated transition-shadow">
                <div className="size-12 rounded-2xl gradient-cta flex items-center justify-center shadow-soft group-hover:scale-105 transition-transform">
                  <f.i className="size-5 text-primary-foreground" />
                </div>
                <h3 className="mt-5 font-display text-xl font-semibold">{f.t}</h3>
                <p className="mt-2 text-muted-foreground">{f.d}</p>
              </div>
            </Reveal>
          ))}
        </div>
        <div className="mt-10 text-center">
          <Button asChild variant="outline" className="rounded-full bg-card">
            <Link to="/features">{t("features.explore")} <ArrowRight className="ml-1 size-4" /></Link>
          </Button>
        </div>
      </section>

      {/* HOW IT WORKS */}
      <section className="mx-auto max-w-7xl px-5 lg:px-8 mt-24">
        <Reveal>
          <div className="text-center max-w-2xl mx-auto">
            <p className="text-sm font-medium text-deep-green uppercase tracking-widest">{t("how.kicker")}</p>
            <h2 className="mt-3 font-display text-3xl sm:text-5xl font-semibold">{t("how.title")}</h2>
          </div>
        </Reveal>
        <div className="mt-12 grid md:grid-cols-5 gap-4">
          {[
            "Upload prescription",
            "AI builds your plan",
            "Get gentle reminders",
            "Confirm with a photo",
            "Track & improve",
          ].map((s, i) => (
            <Reveal key={s} delay={i * 80}>
              <div className="rounded-2xl bg-card border border-border p-5 h-full">
                <div className="font-display text-3xl font-semibold text-deep-green">0{i + 1}</div>
                <p className="mt-3 font-medium">{s}</p>
              </div>
            </Reveal>
          ))}
        </div>
      </section>

      {/* EMOTIONAL */}
      <section className="mx-auto max-w-7xl px-5 lg:px-8 mt-24">
        <div className="grid lg:grid-cols-2 gap-10 items-center">
          <Reveal>
            <img src={familyImg} alt="Daughter and elderly father using CareTrackAI together" loading="lazy" className="rounded-3xl shadow-elevated w-full aspect-[4/3] object-cover" />
          </Reveal>
          <Reveal delay={100}>
            <p className="text-sm font-medium text-deep-green uppercase tracking-widest">{t("fam.kicker")}</p>
            <h2 className="mt-3 font-display text-3xl sm:text-5xl font-semibold">{t("fam.title")}</h2>
            <p className="mt-5 text-lg text-muted-foreground">
              {t("fam.body")}
            </p>
            <div className="mt-8 rounded-2xl border border-border bg-card p-6">
              <Quote className="size-6 text-amber-soft" />
              <p className="mt-3 text-lg text-foreground">
                "I sleep better knowing my mother's morning insulin happens — and I'll know if it doesn't."
              </p>
              <p className="mt-3 text-sm text-muted-foreground">— Layla, daughter & caregiver</p>
            </div>
          </Reveal>
        </div>
      </section>

      <CTASection />
      <Footer />
    </div>
  );
}
