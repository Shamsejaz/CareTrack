import { Link } from "@tanstack/react-router";
import { Heart } from "lucide-react";
import { useI18n } from "@/lib/i18n";

export function Footer() {
  const { t } = useI18n();
  return (
    <footer className="mt-32 border-t border-border bg-card">
      <div className="mx-auto max-w-7xl px-5 lg:px-8 py-16 grid gap-12 lg:grid-cols-5">
        <div className="lg:col-span-2">
          <Link to="/" className="flex items-center gap-2">
            <div className="size-9 rounded-xl gradient-cta flex items-center justify-center">
              <Heart className="size-4 text-primary-foreground" fill="currentColor" />
            </div>
            <span className="font-display text-xl font-semibold">CareTrackAI</span>
          </Link>
          <p className="mt-4 text-muted-foreground max-w-sm">{t("footer.tagline")}</p>
        </div>
        <div>
          <h4 className="font-semibold mb-4 text-foreground">{t("footer.product")}</h4>
          <ul className="space-y-3 text-sm text-muted-foreground">
            <li><Link to="/features" className="hover:text-foreground">{t("nav.features")}</Link></li>
            <li><Link to="/how-it-works" className="hover:text-foreground">{t("nav.howItWorks")}</Link></li>
            <li><Link to="/pricing" className="hover:text-foreground">{t("nav.pricing")}</Link></li>
            <li><Link to="/download" className="hover:text-foreground">{t("footer.downloadApp")}</Link></li>
          </ul>
        </div>
        <div>
          <h4 className="font-semibold mb-4 text-foreground">{t("footer.company")}</h4>
          <ul className="space-y-3 text-sm text-muted-foreground">
            <li><Link to="/clinics" className="hover:text-foreground">{t("nav.clinics")}</Link></li>
            <li><Link to="/blog" className="hover:text-foreground">{t("nav.blog")}</Link></li>
            <li><Link to="/contact" className="hover:text-foreground">{t("nav.contact")}</Link></li>
            <li><Link to="/trust" className="hover:text-foreground">{t("footer.trust")}</Link></li>
          </ul>
        </div>
        <div>
          <h4 className="font-semibold mb-4 text-foreground">{t("footer.legal")}</h4>
          <ul className="space-y-3 text-sm text-muted-foreground">
            <li><Link to="/trust" className="hover:text-foreground">{t("footer.privacy")}</Link></li>
            <li><Link to="/trust" className="hover:text-foreground">{t("footer.terms")}</Link></li>
            <li><Link to="/trust" className="hover:text-foreground">{t("footer.compliance")}</Link></li>
          </ul>
        </div>
      </div>
      <div className="border-t border-border">
        <div className="mx-auto max-w-7xl px-5 lg:px-8 py-6 flex flex-col sm:flex-row justify-between items-center gap-3 text-sm text-muted-foreground">
          <p>© {new Date().getFullYear()} CareTrackAI Health. {t("footer.rights")}</p>
          <p>{t("footer.madeWith")}</p>
        </div>
      </div>
    </footer>
  );
}
