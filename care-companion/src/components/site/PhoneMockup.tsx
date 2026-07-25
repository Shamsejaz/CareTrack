import { Bell, Check, Pill, Activity, Footprints, Droplet } from "lucide-react";

export function PhoneMockup() {
  return (
    <div className="relative mx-auto w-[280px] sm:w-[320px]">
      {/* Glow */}
      <div className="absolute -inset-10 bg-deep-green/20 blur-3xl rounded-full -z-10" />

      <div className="relative rounded-[2.5rem] bg-foreground p-2 shadow-elevated">
        <div className="rounded-[2rem] bg-card overflow-hidden aspect-[9/19] flex flex-col">
          {/* Status bar */}
          <div className="px-6 pt-3 pb-2 flex justify-between text-[10px] font-medium text-foreground/80">
            <span>9:41</span>
            <span>•••</span>
          </div>

          {/* Header */}
          <div className="px-5 pb-3">
            <p className="text-xs text-muted-foreground">Good morning,</p>
            <p className="font-display text-lg font-bold text-foreground tracking-tight">Martha 👋</p>
            <p className="text-[10px] text-muted-foreground mt-0.5">Here's your health snapshot.</p>
          </div>

          {/* Status pill */}
          <div className="mx-4 rounded-2xl bg-card border border-border p-3.5">
            <p className="text-[9px] uppercase tracking-wider text-muted-foreground font-semibold">Sugar Status</p>
            <div className="flex items-baseline gap-1 mt-1">
              <span className="font-display text-2xl font-bold" style={{ color: "var(--deep-green)" }}>Normal</span>
              <span className="text-[10px] text-muted-foreground">112 mg/dL</span>
            </div>
            <div className="mt-2 h-1.5 rounded-full bg-muted overflow-hidden">
              <div className="h-full w-2/3 rounded-full" style={{ background: "var(--deep-green)" }} />
            </div>
          </div>

          {/* Stats */}
          <div className="mx-4 mt-2.5 grid grid-cols-2 gap-2">
            <div className="rounded-xl p-3" style={{ background: "color-mix(in oklab, var(--mint) 55%, white)" }}>
              <div className="flex items-center gap-1 text-[10px] text-foreground/70">
                <Pill className="size-3" /> Doses
              </div>
              <p className="font-display font-bold text-foreground mt-0.5">2/5</p>
              <p className="text-[9px] text-foreground/60">taken today</p>
            </div>
            <div className="rounded-xl p-3" style={{ background: "color-mix(in oklab, var(--peach) 55%, white)" }}>
              <div className="flex items-center gap-1 text-[10px] text-foreground/70">
                <Footprints className="size-3" /> Steps
              </div>
              <p className="font-display font-bold text-foreground mt-0.5">3,240</p>
              <p className="text-[9px] text-foreground/60">goal 5,000</p>
            </div>
          </div>

          {/* Reminder card */}
          <div className="mx-4 mt-2.5 rounded-2xl bg-primary text-primary-foreground p-3.5 shadow-soft">
            <div className="flex items-center gap-1.5 text-[10px] opacity-80">
              <Bell className="size-3" /> Next dose · 1:00 PM
            </div>
            <p className="mt-1 font-semibold text-sm">Metformin 500mg</p>
            <button className="mt-2.5 w-full bg-primary-foreground/15 backdrop-blur text-primary-foreground text-[11px] font-semibold rounded-lg py-1.5 flex items-center justify-center gap-1.5 border border-primary-foreground/20">
              <Check className="size-3" /> Confirm with photo
            </button>
          </div>

          <div className="flex-1" />

          {/* Bottom nav */}
          <div className="mx-4 mb-3 mt-3 flex justify-around items-center bg-muted/60 rounded-full py-2">
            <Activity className="size-4 text-primary" />
            <Pill className="size-4 text-muted-foreground" />
            <Droplet className="size-4 text-muted-foreground" />
            <div className="size-5 rounded-full bg-primary/15" />
          </div>
        </div>
      </div>

      {/* Floating notification */}
      <div className="absolute -left-6 top-32 hidden sm:flex items-center gap-2 bg-card border border-border rounded-2xl shadow-soft px-3 py-2 animate-fade-in">
        <div className="size-8 rounded-full flex items-center justify-center" style={{ background: "color-mix(in oklab, var(--mint) 60%, white)" }}>
          <Check className="size-4" style={{ color: "var(--deep-green)" }} />
        </div>
        <div className="text-xs">
          <p className="font-semibold text-foreground">Mom took her dose</p>
          <p className="text-muted-foreground">2 minutes ago</p>
        </div>
      </div>
    </div>
  );
}
