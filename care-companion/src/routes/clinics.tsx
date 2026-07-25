import { createFileRoute, Link } from "@tanstack/react-router";
import { TrendingUp, Stethoscope, Database, ShieldCheck, ArrowRight } from "lucide-react";
import { Header } from "@/components/site/Header";
import { Footer } from "@/components/site/Footer";
import { Reveal } from "@/components/site/Reveal";
import { Button } from "@/components/ui/button";
import clinicImg from "@/assets/clinic.jpg";

export const Route = createFileRoute("/clinics")({
  head: () => ({
    meta: [
      { title: "CareTrackAI for Clinics — Improve Patient Compliance" },
      { name: "description", content: "Help your patients stay on track. Remote monitoring, data-driven care, and better adherence — all in one clinical dashboard." },
      { property: "og:title", content: "CareTrackAI for Clinics" },
      { property: "og:description", content: "AI-powered remote monitoring and patient compliance for clinics and hospitals." },
      { property: "og:image", content: clinicImg },
    ],
  }),
  component: ClinicsPage,
});

function ClinicsPage() {
  return (
    <div className="min-h-screen bg-background">
      <Header />

      <section className="gradient-hero">
        <div className="mx-auto max-w-7xl px-5 lg:px-8 pt-20 pb-20 grid lg:grid-cols-2 gap-12 items-center">
          <div>
            <p className="text-sm font-medium text-deep-green uppercase tracking-widest">For clinics & hospitals</p>
            <h1 className="mt-3 font-display text-4xl sm:text-6xl font-semibold leading-tight">
              Patients who actually <span className="italic text-deep-green">follow through.</span>
            </h1>
            <p className="mt-5 text-lg text-muted-foreground max-w-xl">
              CareTrackAI extends your care between visits — improving adherence, reducing readmissions, and giving you a real-time pulse on every chronic patient.
            </p>
            <div className="mt-8 flex flex-col sm:flex-row gap-3">
              <Button asChild size="lg" className="rounded-full px-7 h-12">
                <Link to="/contact">Book a Demo <ArrowRight className="ml-1 size-4" /></Link>
              </Button>
              <Button asChild variant="outline" size="lg" className="rounded-full px-7 h-12 bg-card">
                <Link to="/features">See features</Link>
              </Button>
            </div>
          </div>
          <Reveal>
            <img src={clinicImg} alt="Clinician using CareTrackAI dashboard" loading="lazy" className="rounded-3xl shadow-elevated w-full aspect-[4/3] object-cover" />
          </Reveal>
        </div>
      </section>

      <section className="mx-auto max-w-7xl px-5 lg:px-8 mt-20 grid md:grid-cols-3 gap-5">
        {[
          { v: "+47%", l: "patient adherence" },
          { v: "-32%", l: "missed follow-ups" },
          { v: "5★", l: "patient satisfaction" },
        ].map((s) => (
          <div key={s.l} className="rounded-3xl bg-card border border-border p-8 text-center shadow-soft">
            <p className="font-display text-5xl font-semibold text-deep-green">{s.v}</p>
            <p className="mt-2 text-muted-foreground">{s.l}</p>
          </div>
        ))}
      </section>

      <section className="mx-auto max-w-7xl px-5 lg:px-8 mt-20 grid md:grid-cols-2 lg:grid-cols-4 gap-5">
        {[
          { i: TrendingUp, t: "Patient compliance", d: "Verified daily medication confirmations and adherence trends." },
          { i: Stethoscope, t: "Remote monitoring", d: "Track chronic patients between visits with real-time vitals." },
          { i: Database, t: "Data-driven care", d: "Beautiful clinical dashboards and exportable patient reports." },
          { i: ShieldCheck, t: "Compliant by design", d: "HIPAA, GDPR & PDPL ready, with full audit trails and access controls." },
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

      <section className="mx-auto max-w-7xl px-5 lg:px-8 mt-24">
        <div className="rounded-3xl gradient-cta p-10 sm:p-16 text-center shadow-elevated">
          <h2 className="font-display text-3xl sm:text-5xl font-semibold text-primary-foreground max-w-2xl mx-auto">Better outcomes. Less work.</h2>
          <p className="mt-4 text-primary-foreground/80 max-w-xl mx-auto">Book a 20-minute demo and see how leading clinics are using CareTrackAI.</p>
          <Button asChild size="lg" className="mt-8 rounded-full bg-amber-soft text-deep-green hover:bg-amber-soft/90 px-7">
            <Link to="/contact">Book a Demo</Link>
          </Button>
        </div>
      </section>

      <Footer />
    </div>
  );
}
