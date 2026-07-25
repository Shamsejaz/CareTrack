import { createFileRoute } from "@tanstack/react-router";
import { Mail, MessageCircle, Phone } from "lucide-react";
import { Header } from "@/components/site/Header";
import { Footer } from "@/components/site/Footer";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { useState } from "react";
import { createServerFn } from "@tanstack/react-start";
import { Resend } from "resend";
import { z } from "zod";

const contactSchema = z.object({
  name: z.string().min(2),
  email: z.string().email(),
  role: z.string(),
  message: z.string().min(10),
  consent: z.literal(true)
});

const sendContactEmail = createServerFn({ method: "POST" })
  .validator((data: unknown) => contactSchema.parse(data))
  .handler(async ({ data }) => {
    try {
      // In a real app, you would have a verified domain.
      // For now, Resend's testing domain is used for demonstration.
      const resend = new Resend(process.env.RESEND_API_KEY);
      await resend.emails.send({
        from: 'CareTrackAI <onboarding@resend.dev>',
        to: 'hello@caretrackai.app',
        subject: `New Contact Request from ${data.name}`,
        html: `
          <h3>New Contact Request</h3>
          <p><strong>Name:</strong> ${data.name}</p>
          <p><strong>Email:</strong> ${data.email}</p>
          <p><strong>Role:</strong> ${data.role}</p>
          <p><strong>Message:</strong><br/> ${data.message}</p>
        `,
      });
      return { success: true };
    } catch (error) {
      console.error("Failed to send email:", error);
      return { success: false, error: "Failed to send message" };
    }
  });

export const Route = createFileRoute("/contact")({
  head: () => ({
    meta: [
      { title: "Contact CareTrackAI — Start Free or Book a Demo" },
      { name: "description", content: "Talk to the CareTrackAI team. Start your free trial, request a clinic demo, or get in touch on WhatsApp." },
      { property: "og:title", content: "Contact CareTrackAI" },
      { property: "og:description", content: "We'd love to hear from you." },
    ],
  }),
  component: ContactPage,
});

function ContactPage() {
  const [sent, setSent] = useState(false);
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setLoading(true);
    
    const formData = new FormData(e.currentTarget);
    const data = {
      name: formData.get("name") as string,
      email: formData.get("email") as string,
      role: formData.get("role") as string,
      message: formData.get("message") as string,
      consent: formData.get("consent") === "on",
    };
    
    const res = await sendContactEmail({ data });
    setLoading(false);
    if (res.success) {
      setSent(true);
    } else {
      alert("Something went wrong. Please try again or use WhatsApp.");
    }
  };
  return (
    <div className="min-h-screen bg-background">
      <Header />

      <section className="gradient-hero">
        <div className="mx-auto max-w-7xl px-5 lg:px-8 pt-20 pb-16 text-center">
          <h1 className="font-display text-4xl sm:text-6xl font-semibold max-w-3xl mx-auto leading-tight">
            Let's <span className="italic text-deep-green">talk.</span>
          </h1>
          <p className="mt-5 text-lg text-muted-foreground max-w-xl mx-auto">
            Whether you're a family, caregiver, or clinic — we usually reply within a few hours.
          </p>
        </div>
      </section>

      <section className="mx-auto max-w-6xl px-5 lg:px-8 mt-12 grid lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2 rounded-3xl bg-card border border-border p-8 lg:p-10 shadow-soft">
          {sent ? (
            <div className="text-center py-12">
              <div className="size-16 mx-auto rounded-full bg-amber-soft flex items-center justify-center text-2xl">✓</div>
              <h2 className="mt-4 font-display text-2xl font-semibold">Message sent</h2>
              <p className="mt-2 text-muted-foreground">We'll be in touch shortly.</p>
            </div>
          ) : (
            <form className="space-y-5" onSubmit={handleSubmit}>
              <div className="grid sm:grid-cols-2 gap-4">
                <div>
                  <label htmlFor="contact-name" className="text-sm font-medium">Full name</label>
                  <Input id="contact-name" name="name" required className="mt-1.5 rounded-xl h-11" placeholder="Fatima Al-Saud" />
                </div>
                <div>
                  <label htmlFor="contact-email" className="text-sm font-medium">Email</label>
                  <Input id="contact-email" name="email" required type="email" className="mt-1.5 rounded-xl h-11" placeholder="you@email.com" />
                </div>
              </div>
              <div>
                <label htmlFor="contact-role" className="text-sm font-medium">I'm a…</label>
                <select id="contact-role" name="role" className="mt-1.5 w-full rounded-xl h-11 border border-input bg-background px-3 text-sm">
                  <option>Patient or family member</option>
                  <option>Caregiver</option>
                  <option>Clinic / hospital</option>
                  <option>Press or partner</option>
                </select>
              </div>
              <div>
                <label htmlFor="contact-message" className="text-sm font-medium">How can we help?</label>
                <Textarea id="contact-message" name="message" required className="mt-1.5 rounded-xl min-h-32" placeholder="Tell us a little about what you need…" />
              </div>
              
              <div className="flex items-start gap-3 mt-4">
                <input 
                  type="checkbox" 
                  id="consent" 
                  name="consent" 
                  required 
                  className="mt-1"
                />
                <label htmlFor="consent" className="text-xs text-muted-foreground leading-relaxed">
                  I explicitly consent to the processing of my personal data to receive a response to this inquiry, in accordance with the 
                  <a href="https://app.caretrackai.app/privacy" target="_blank" rel="noopener noreferrer" className="underline"> Privacy Policy</a> 
                  (required for GDPR/PDPL compliance).
                </label>
              </div>
              <Button size="lg" className="rounded-full px-7 w-full sm:w-auto" disabled={loading}>
                {loading ? "Sending..." : "Send message"}
              </Button>
            </form>
          )}
        </div>

        <div className="space-y-4">
          {[
            { i: Mail, t: "Email", d: "hello@caretrackai.app" },
            { i: MessageCircle, t: "WhatsApp", d: "+1 307-533-5472" },
            { i: Phone, t: "Sales", d: "+1 307-533-5472" },
          ].map((c) => (
            <div key={c.t} className="rounded-2xl bg-card border border-border p-6 flex items-start gap-4">
              <div className="size-11 rounded-xl gradient-cta flex items-center justify-center"><c.i className="size-5 text-primary-foreground" /></div>
              <div>
                <p className="font-semibold">{c.t}</p>
                <p className="text-muted-foreground text-sm mt-0.5">{c.d}</p>
              </div>
            </div>
          ))}
          <a href="https://wa.me/13075335472" target="_blank" rel="noreferrer" className="block rounded-2xl bg-amber-soft p-6 text-deep-green hover:opacity-90 transition">
            <p className="font-semibold">Prefer WhatsApp?</p>
            <p className="text-sm mt-1 opacity-80">Tap to chat with our team in seconds.</p>
          </a>
        </div>
      </section>

      <Footer />
    </div>
  );
}
