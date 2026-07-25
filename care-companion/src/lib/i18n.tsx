import { createContext, useContext, useEffect, useState, type ReactNode } from "react";

export type Lang = "en" | "ar" | "ur";

type Dict = Record<string, string>;

const en: Dict = {
  // Nav
  "nav.features": "Features",
  "nav.howItWorks": "How it works",
  "nav.pricing": "Pricing",
  "nav.clinics": "For Clinics",
  "nav.blog": "Blog",
  "nav.contact": "Contact",
  "nav.download": "Download",
  "nav.startFree": "Start Free",
  "nav.toggleMenu": "Toggle menu",
  "nav.language": "Language",

  // Hero
  "hero.badge": "Available worldwide",
  "hero.title.a": "Never miss a medicine, meal, or moment",
  "hero.title.b": "again.",
  "hero.subtitle":
    "CareTrackAI is an AI-powered daily health assistant for patients, elderly, and caregivers — turning prescriptions into a calm, simple routine.",
  "hero.cta.start": "Start Free",
  "hero.cta.how": "See how it works",
  "hero.social": "12,000+ families",

  // Trust
  "trust.heading": "Trusted by families, caregivers & clinics around the world",

  // Problem
  "problem.kicker": "The reality",
  "problem.title": "Daily care is harder than it should be.",

  // Solution
  "solution.kicker": "The solution",
  "solution.title": "Your daily health brain.",
  "solution.body":
    "CareTrackAI reads your prescription, builds your day, reminds you gently, and quietly looks after the people you love.",
  "solution.b1": "Designed for low tech literacy",
  "solution.b2": "Multilingual & accessible",
  "solution.b3": "Enterprise-grade privacy",

  // Features section
  "features.kicker": "Features",
  "features.title": "Everything care needs. Nothing it doesn't.",
  "features.explore": "Explore all features",

  // How
  "how.kicker": "How it works",
  "how.title": "From prescription to peace of mind in 5 minutes.",

  // Emotional
  "fam.kicker": "For families",
  "fam.title": "Peace of mind, even from miles away.",
  "fam.body":
    "Whether your parents live next door or across the world, CareTrackAI keeps you quietly informed when it matters — and stays out of the way when it doesn't.",

  // CTA
  "cta.title": "Start caring smarter today.",
  "cta.body": "Join thousands of families gaining peace of mind with CareTrackAI. Your first 14 days are on us.",
  "cta.start": "Start Free",
  "cta.demo": "Book a Demo",

  // Footer
  "footer.tagline":
    "AI-powered daily health assistant for patients, elderly, and caregivers. Trusted by families and clinics around the world.",
  "footer.product": "Product",
  "footer.company": "Company",
  "footer.legal": "Legal",
  "footer.downloadApp": "Download app",
  "footer.trust": "Trust & Privacy",
  "footer.privacy": "Privacy Policy",
  "footer.terms": "Terms of Service",
  "footer.compliance": "Compliance",
  "footer.rights": "All rights reserved.",
  "footer.madeWith": "Made with care for families everywhere",
};

const ar: Dict = {
  "nav.features": "المزايا",
  "nav.howItWorks": "كيف يعمل",
  "nav.pricing": "الأسعار",
  "nav.clinics": "للعيادات",
  "nav.blog": "المدونة",
  "nav.contact": "تواصل معنا",
  "nav.download": "تحميل",
  "nav.startFree": "ابدأ مجاناً",
  "nav.toggleMenu": "القائمة",
  "nav.language": "اللغة",

  "hero.badge": "متوفر حول العالم",
  "hero.title.a": "لا تفوّت دواءً أو وجبة أو لحظة",
  "hero.title.b": "مرة أخرى.",
  "hero.subtitle":
    "كير تراك AI مساعد صحي يومي مدعوم بالذكاء الاصطناعي للمرضى وكبار السن ومقدمي الرعاية — يحوّل الوصفات الطبية إلى روتين بسيط وهادئ.",
  "hero.cta.start": "ابدأ مجاناً",
  "hero.cta.how": "اكتشف كيف يعمل",
  "hero.social": "أكثر من 12,000 عائلة",

  "trust.heading": "موثوق من العائلات ومقدمي الرعاية والعيادات حول العالم",

  "problem.kicker": "الواقع",
  "problem.title": "الرعاية اليومية أصعب مما يجب أن تكون.",

  "solution.kicker": "الحل",
  "solution.title": "عقلك الصحي اليومي.",
  "solution.body":
    "كير تراك AI يقرأ وصفتك الطبية، يبني يومك، يذكّرك بلطف، ويعتني بهدوء بمن تحب.",
  "solution.b1": "مصمّم لمن لديهم خبرة تقنية محدودة",
  "solution.b2": "متعدد اللغات وسهل الوصول",
  "solution.b3": "خصوصية على مستوى المؤسسات",

  "features.kicker": "المزايا",
  "features.title": "كل ما تحتاجه الرعاية. ولا شيء زائد.",
  "features.explore": "استكشف جميع المزايا",

  "how.kicker": "كيف يعمل",
  "how.title": "من الوصفة الطبية إلى راحة البال في 5 دقائق.",

  "fam.kicker": "للعائلات",
  "fam.title": "راحة البال، حتى من بعيد.",
  "fam.body":
    "سواء كان والداك بجوارك أو على الجانب الآخر من العالم، يبقيك كير تراك AI على اطلاع بهدوء عند الحاجة — ويبتعد عن طريقك حين لا تحتاج إليه.",

  "cta.title": "ابدأ رعاية أذكى اليوم.",
  "cta.body": "انضم إلى آلاف العائلات الذين يحصلون على راحة البال مع كير تراك AI. أول 14 يوماً علينا.",
  "cta.start": "ابدأ مجاناً",
  "cta.demo": "احجز عرضاً توضيحياً",

  "footer.tagline":
    "مساعد صحي يومي مدعوم بالذكاء الاصطناعي للمرضى وكبار السن ومقدمي الرعاية. موثوق من العائلات والعيادات حول العالم.",
  "footer.product": "المنتج",
  "footer.company": "الشركة",
  "footer.legal": "قانوني",
  "footer.downloadApp": "تحميل التطبيق",
  "footer.trust": "الثقة والخصوصية",
  "footer.privacy": "سياسة الخصوصية",
  "footer.terms": "شروط الاستخدام",
  "footer.compliance": "الامتثال",
  "footer.rights": "جميع الحقوق محفوظة.",
  "footer.madeWith": "صُنع بعناية للعائلات في كل مكان",
};

const ur: Dict = {
  "nav.features": "خصوصیات",
  "nav.howItWorks": "یہ کیسے کام کرتا ہے",
  "nav.pricing": "قیمتیں",
  "nav.clinics": "کلینکس کے لیے",
  "nav.blog": "بلاگ",
  "nav.contact": "رابطہ",
  "nav.download": "ڈاؤن لوڈ",
  "nav.startFree": "مفت شروع کریں",
  "nav.toggleMenu": "مینو",
  "nav.language": "زبان",

  "hero.badge": "دنیا بھر میں دستیاب",
  "hero.title.a": "دوبارہ کبھی دوا، کھانا یا لمحہ",
  "hero.title.b": "مت بھولیں۔",
  "hero.subtitle":
    "کیئر ٹریک AI مریضوں، بزرگوں اور دیکھ بھال کرنے والوں کے لیے ایک اے آئی پر مبنی روزمرہ کا صحت معاون ہے — جو نسخوں کو ایک پرسکون، آسان معمول میں بدل دیتا ہے۔",
  "hero.cta.start": "مفت شروع کریں",
  "hero.cta.how": "دیکھیں یہ کیسے کام کرتا ہے",
  "hero.social": "12,000+ خاندان",

  "trust.heading": "دنیا بھر کے خاندانوں، نگہداشت کرنے والوں اور کلینکس کا اعتماد",

  "problem.kicker": "حقیقت",
  "problem.title": "روزمرہ کی دیکھ بھال جتنی ہونی چاہیے اس سے کہیں زیادہ مشکل ہے۔",

  "solution.kicker": "حل",
  "solution.title": "آپ کا روزانہ کا صحت دماغ۔",
  "solution.body":
    "کیئر ٹریک AI آپ کا نسخہ پڑھتا ہے، آپ کا دن ترتیب دیتا ہے، نرمی سے یاد دلاتا ہے، اور خاموشی سے آپ کے پیاروں کا خیال رکھتا ہے۔",
  "solution.b1": "کم ٹیکنالوجی واقفیت کے لیے ڈیزائن کیا گیا",
  "solution.b2": "کثیر لسانی اور قابلِ رسائی",
  "solution.b3": "اداروں کے درجے کی پرائیویسی",

  "features.kicker": "خصوصیات",
  "features.title": "ہر وہ چیز جو دیکھ بھال کے لیے درکار ہے۔ کچھ اضافی نہیں۔",
  "features.explore": "تمام خصوصیات دیکھیں",

  "how.kicker": "یہ کیسے کام کرتا ہے",
  "how.title": "نسخے سے سکونِ قلب تک، صرف 5 منٹ میں۔",

  "fam.kicker": "خاندانوں کے لیے",
  "fam.title": "سکونِ قلب، چاہے میلوں دور ہی کیوں نہ ہوں۔",
  "fam.body":
    "آپ کے والدین چاہے ساتھ والے گھر میں ہوں یا دنیا کے دوسرے کونے میں، کیئر ٹریک AI ضرورت کے وقت آپ کو خاموشی سے باخبر رکھتا ہے۔",

  "cta.title": "آج ہی ہوشیار دیکھ بھال شروع کریں۔",
  "cta.body": "ہزاروں خاندانوں کے ساتھ شامل ہوں جو کیئر ٹریک AI کے ساتھ سکون پا رہے ہیں۔ پہلے 14 دن مفت۔",
  "cta.start": "مفت شروع کریں",
  "cta.demo": "ڈیمو بک کریں",

  "footer.tagline":
    "مریضوں، بزرگوں اور دیکھ بھال کرنے والوں کے لیے اے آئی پر مبنی روزانہ صحت معاون۔ دنیا بھر کے خاندانوں اور کلینکس کا اعتماد۔",
  "footer.product": "پروڈکٹ",
  "footer.company": "کمپنی",
  "footer.legal": "قانونی",
  "footer.downloadApp": "ایپ ڈاؤن لوڈ کریں",
  "footer.trust": "اعتماد و پرائیویسی",
  "footer.privacy": "پرائیویسی پالیسی",
  "footer.terms": "شرائط و ضوابط",
  "footer.compliance": "تعمیل",
  "footer.rights": "جملہ حقوق محفوظ ہیں۔",
  "footer.madeWith": "ہر جگہ کے خاندانوں کے لیے محبت سے بنایا گیا",
};

const dictionaries: Record<Lang, Dict> = { en, ar, ur };

export const LANGUAGES: { code: Lang; label: string; native: string; dir: "ltr" | "rtl" }[] = [
  { code: "en", label: "English", native: "English", dir: "ltr" },
  { code: "ar", label: "Arabic", native: "العربية", dir: "rtl" },
  { code: "ur", label: "Urdu", native: "اردو", dir: "rtl" },
];

interface Ctx {
  lang: Lang;
  dir: "ltr" | "rtl";
  setLang: (l: Lang) => void;
  t: (key: string) => string;
}

const I18nContext = createContext<Ctx | null>(null);

export function I18nProvider({ children }: { children: ReactNode }) {
  const [lang, setLangState] = useState<Lang>("en");

  useEffect(() => {
    if (typeof window === "undefined") return;
    const stored = window.localStorage.getItem("ct-lang") as Lang | null;
    if (stored && dictionaries[stored]) setLangState(stored);
  }, []);

  useEffect(() => {
    if (typeof document === "undefined") return;
    const meta = LANGUAGES.find((l) => l.code === lang)!;
    document.documentElement.lang = lang;
    document.documentElement.dir = meta.dir;
  }, [lang]);

  const setLang = (l: Lang) => {
    setLangState(l);
    if (typeof window !== "undefined") window.localStorage.setItem("ct-lang", l);
  };

  const t = (key: string) => dictionaries[lang][key] ?? dictionaries.en[key] ?? key;
  const dir = LANGUAGES.find((l) => l.code === lang)!.dir;

  return <I18nContext.Provider value={{ lang, dir, setLang, t }}>{children}</I18nContext.Provider>;
}

export function useI18n() {
  const ctx = useContext(I18nContext);
  if (!ctx) throw new Error("useI18n must be used within I18nProvider");
  return ctx;
}
