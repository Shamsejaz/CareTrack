import { Globe, Check } from "lucide-react";
import { LANGUAGES, useI18n, type Lang } from "@/lib/i18n";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";

export function LanguageSelector({ className }: { className?: string }) {
  const { lang, setLang, t } = useI18n();
  const current = LANGUAGES.find((l) => l.code === lang)!;

  return (
    <DropdownMenu>
      <DropdownMenuTrigger
        aria-label={t("nav.language")}
        className={
          "inline-flex items-center gap-2 rounded-full border border-border bg-card px-3 h-9 text-sm text-foreground hover:bg-accent/30 transition-colors " +
          (className ?? "")
        }
      >
        <Globe className="size-4 text-muted-foreground" />
        <span className="font-medium">{current.native}</span>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end" className="min-w-[10rem]">
        {LANGUAGES.map((l) => (
          <DropdownMenuItem
            key={l.code}
            onClick={() => setLang(l.code as Lang)}
            className="flex items-center justify-between gap-3 cursor-pointer"
          >
            <span>{l.native}</span>
            {l.code === lang && <Check className="size-4 text-deep-green" />}
          </DropdownMenuItem>
        ))}
      </DropdownMenuContent>
    </DropdownMenu>
  );
}
