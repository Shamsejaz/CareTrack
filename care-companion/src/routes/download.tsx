import { createFileRoute } from "@tanstack/react-router";
import { Apple, Smartphone, Star } from "lucide-react";
import { Header } from "@/components/site/Header";
import { Footer } from "@/components/site/Footer";
import { Reveal } from "@/components/site/Reveal";
import { PhoneMockup } from "@/components/site/PhoneMockup";

export const Route = createFileRoute("/download")({
  head: () => ({
    meta: [
      { title: "Download CareTrackAI — iOS & Android" },
      { name: "description", content: "Download CareTrackAI for iPhone and Android. Free to start, beautifully designed, available in multiple languages." },
      { property: "og:title", content: "Get CareTrackAI" },
      { property: "og:description", content: "Available on iOS and Android." },
    ],
  }),
  component: DownloadPage,
});

function DownloadPage() {
  return (
    <div className="min-h-screen bg-background">
      <Header />
      <section className="gradient-hero">
        <div className="mx-auto max-w-7xl px-5 lg:px-8 pt-20 pb-20 grid lg:grid-cols-2 gap-12 items-center">
          <div>
            <h1 className="font-display text-4xl sm:text-6xl font-semibold leading-tight">
              CareTrackAI, in <span className="italic text-deep-green">your pocket.</span>
            </h1>
            <p className="mt-5 text-lg text-muted-foreground max-w-xl">
              Download the app and turn your phone into a calm, intelligent care companion — for you or someone you love.
            </p>
            <div className="mt-8 flex flex-col sm:flex-row gap-3">
              <a href="#" className="flex items-center gap-3 bg-foreground text-background rounded-2xl px-6 py-3.5 hover:opacity-90 transition">
                <Apple className="size-7" />
                <div className="text-left">
                  <p className="text-[10px] opacity-70 uppercase">Download on</p>
                  <p className="font-semibold">App Store</p>
                </div>
              </a>
              <a href="#" className="flex items-center gap-3 bg-foreground text-background rounded-2xl px-6 py-3.5 hover:opacity-90 transition">
                <Smartphone className="size-7" />
                <div className="text-left">
                  <p className="text-[10px] opacity-70 uppercase">Get it on</p>
                  <p className="font-semibold">Google Play</p>
                </div>
              </a>
            </div>
            <div className="mt-8 flex items-center gap-2 text-sm text-muted-foreground">
              <div className="flex">
                {[1,2,3,4,5].map((i) => <Star key={i} className="size-4 fill-amber-soft text-amber-soft" />)}
              </div>
              <span>4.9 average · 12,000+ reviews</span>
            </div>
          </div>
          <Reveal>
            <PhoneMockup />
          </Reveal>
        </div>
      </section>

      <section className="mx-auto max-w-7xl px-5 lg:px-8 mt-20 grid md:grid-cols-3 gap-5">
        {[
          { t: "Set up in 5 minutes", d: "Snap your prescription, choose your language, and you're done." },
          { t: "Works offline", d: "Reminders run reliably even when the network doesn't." },
          { t: "Family friendly", d: "Invite up to 5 caregivers per account on the Family plan." },
        ].map((b) => (
          <div key={b.t} className="rounded-3xl bg-card border border-border p-7">
            <h3 className="font-display text-xl font-semibold">{b.t}</h3>
            <p className="mt-2 text-muted-foreground">{b.d}</p>
          </div>
        ))}
      </section>

      <Footer />
    </div>
  );
}
