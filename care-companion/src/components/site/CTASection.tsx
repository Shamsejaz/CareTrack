import { Link } from "@tanstack/react-router";
import { ArrowRight } from "lucide-react";
import { Button } from "@/components/ui/button";
import { useI18n } from "@/lib/i18n";

export function CTASection() {
  const { t } = useI18n();
  return (
    <section className="mx-auto max-w-7xl px-5 lg:px-8 mt-24">
      <div className="relative overflow-hidden rounded-3xl gradient-cta p-10 sm:p-16 text-center shadow-elevated">
        <div className="absolute inset-0 opacity-30 bg-[radial-gradient(circle_at_30%_20%,_var(--amber-soft),_transparent_50%)]" />
        <div className="relative">
          <h2 className="font-display text-3xl sm:text-5xl font-semibold text-primary-foreground max-w-2xl mx-auto">
            {t("cta.title")}
          </h2>
          <p className="mt-4 text-primary-foreground/80 max-w-xl mx-auto">{t("cta.body")}</p>
          <div className="mt-8 flex flex-col sm:flex-row gap-3 justify-center">
            <Button asChild size="lg" className="rounded-full bg-amber-soft text-deep-green hover:bg-amber-soft/90 px-7">
              <Link to="/contact">{t("cta.start")} <ArrowRight className="ml-1 size-4" /></Link>
            </Button>
            <Button asChild size="lg" variant="outline" className="rounded-full bg-transparent border-primary-foreground/30 text-primary-foreground hover:bg-primary-foreground/10 hover:text-primary-foreground px-7">
              <Link to="/clinics">{t("cta.demo")}</Link>
            </Button>
          </div>
        </div>
      </div>
    </section>
  );
}
