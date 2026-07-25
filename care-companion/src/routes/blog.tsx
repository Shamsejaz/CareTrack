import { createFileRoute, Link } from "@tanstack/react-router";
import { ArrowRight } from "lucide-react";
import { Header } from "@/components/site/Header";
import { Footer } from "@/components/site/Footer";
import { Reveal } from "@/components/site/Reveal";

export const Route = createFileRoute("/blog")({
  head: () => ({
    meta: [
      { title: "Blog — CareTrackAI Health Insights" },
      { name: "description", content: "Practical guides on diabetes management, elderly care, medication adherence and the future of health tech." },
      { property: "og:title", content: "CareTrackAI Blog" },
      { property: "og:description", content: "Diabetes, elderly care, medication adherence and health tech insights." },
    ],
  }),
  component: BlogPage,
});

const posts = [
  { cat: "Diabetes", t: "How to manage diabetes daily", d: "A simple, sustainable framework — meals, meds, movement and mindset.", read: "6 min" },
  { cat: "Elderly Care", t: "Why patients forget medicines (and how to fix it)", d: "The science of forgetting — and the gentle nudges that actually work.", read: "5 min" },
  { cat: "Health Tech", t: "Best apps for elderly care in 2025", d: "An honest look at what's worth installing on your parents' phones.", read: "8 min" },
  { cat: "Medication", t: "Building a medication routine that sticks", d: "Five tiny habits that make adherence almost automatic.", read: "4 min" },
  { cat: "Diabetes", t: "What your glucose trends are really telling you", d: "Read between the spikes and dips like a clinician.", read: "7 min" },
  { cat: "Elderly Care", t: "Caring from a distance: a family playbook", d: "How modern families coordinate care across cities and continents.", read: "9 min" },
];

const cats = ["All", "Diabetes", "Elderly Care", "Medication", "Health Tech"];

function BlogPage() {
  return (
    <div className="min-h-screen bg-background">
      <Header />

      <section className="gradient-hero">
        <div className="mx-auto max-w-7xl px-5 lg:px-8 pt-20 pb-16 text-center">
          <h1 className="font-display text-4xl sm:text-6xl font-semibold max-w-3xl mx-auto leading-tight">
            Insights for <span className="italic text-deep-green">better days.</span>
          </h1>
          <p className="mt-5 text-lg text-muted-foreground max-w-xl mx-auto">
            Practical, evidence-based writing on diabetes, elderly care, and the future of personal health.
          </p>
        </div>
      </section>

      <div className="mx-auto max-w-7xl px-5 lg:px-8 mt-10 flex flex-wrap gap-2 justify-center">
        {cats.map((c, i) => (
          <button key={c} className={`px-4 py-2 rounded-full text-sm border ${i === 0 ? "bg-primary text-primary-foreground border-primary" : "bg-card border-border text-muted-foreground hover:text-foreground"}`}>{c}</button>
        ))}
      </div>

      <section className="mx-auto max-w-7xl px-5 lg:px-8 mt-12 grid md:grid-cols-2 lg:grid-cols-3 gap-6">
        {posts.map((p, i) => (
          <Reveal key={p.t} delay={i * 50}>
            <article className="group rounded-3xl bg-card border border-border overflow-hidden hover:shadow-elevated transition-shadow h-full flex flex-col">
              <div className="aspect-[16/10] bg-gradient-to-br from-amber-soft/60 to-deep-green/20 flex items-center justify-center">
                <span className="font-display text-5xl font-semibold text-deep-green/30">{p.cat[0]}</span>
              </div>
              <div className="p-6 flex-1 flex flex-col">
                <p className="text-xs font-medium uppercase tracking-widest text-deep-green">{p.cat}</p>
                <h2 className="mt-2 font-display text-xl font-semibold group-hover:text-deep-green transition-colors">{p.t}</h2>
                <p className="mt-2 text-muted-foreground flex-1">{p.d}</p>
                <div className="mt-5 flex items-center justify-between text-sm text-muted-foreground">
                  <span>{p.read} read</span>
                  <Link to="/blog" className="inline-flex items-center gap-1 text-foreground font-medium">Read <ArrowRight className="size-4" /></Link>
                </div>
              </div>
            </article>
          </Reveal>
        ))}
      </section>

      <Footer />
    </div>
  );
}
