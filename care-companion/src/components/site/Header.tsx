import { Link } from "@tanstack/react-router";
import { useState } from "react";
import { Menu, X, Heart } from "lucide-react";
import { Button } from "@/components/ui/button";
import { LanguageSelector } from "@/components/site/LanguageSelector";
import { useI18n } from "@/lib/i18n";

export function Header() {
  const [open, setOpen] = useState(false);
  const { t } = useI18n();

  const links = [
    { to: "/features", label: t("nav.features") },
    { to: "/how-it-works", label: t("nav.howItWorks") },
    { to: "/pricing", label: t("nav.pricing") },
    { to: "/clinics", label: t("nav.clinics") },
    { to: "/blog", label: t("nav.blog") },
    { to: "/contact", label: t("nav.contact") },
  ] as const;

  return (
    <header className="sticky top-0 z-50 backdrop-blur-xl bg-background/75 border-b border-border/60">
      <div className="mx-auto max-w-7xl px-5 lg:px-8 h-16 flex items-center justify-between">
        <Link to="/" className="flex items-center gap-2 group">
          <div className="size-9 rounded-xl gradient-cta flex items-center justify-center shadow-soft">
            <Heart className="size-4 text-primary-foreground" fill="currentColor" />
          </div>
          <span className="font-display text-xl font-semibold text-foreground">CareTrackAI</span>
        </Link>

        <nav className="hidden lg:flex items-center gap-8">
          {links.map((l) => (
            <Link
              key={l.to}
              to={l.to}
              className="text-sm text-muted-foreground hover:text-foreground transition-colors"
              activeProps={{ className: "text-foreground font-medium" }}
            >
              {l.label}
            </Link>
          ))}
        </nav>

        <div className="hidden lg:flex items-center gap-3">
          <LanguageSelector />
          <Button asChild size="sm" className="rounded-full px-5">
            <Link to="/contact">{t("nav.startFree")}</Link>
          </Button>
        </div>

        <div className="lg:hidden flex items-center gap-2">
          <LanguageSelector />
          <button
            aria-label={t("nav.toggleMenu")}
            className="size-10 rounded-xl border border-border flex items-center justify-center"
            onClick={() => setOpen((o) => !o)}
          >
            {open ? <X className="size-5" /> : <Menu className="size-5" />}
          </button>
        </div>
      </div>

      {open && (
        <div className="lg:hidden border-t border-border bg-background">
          <div className="px-5 py-4 flex flex-col gap-1">
            {links.map((l) => (
              <Link
                key={l.to}
                to={l.to}
                onClick={() => setOpen(false)}
                className="py-3 text-base text-foreground"
              >
                {l.label}
              </Link>
            ))}
            <Button asChild className="mt-3 rounded-full">
              <Link to="/contact" onClick={() => setOpen(false)}>{t("nav.startFree")}</Link>
            </Button>
          </div>
        </div>
      )}
    </header>
  );
}
