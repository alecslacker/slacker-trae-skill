---
name: marketing-tools
description: Reference library 100+ integrasi marketing (GA4, Semrush, Ahrefs, HubSpot, Klaviyo, Meta Ads, dst) via API/MCP/CLI/SDK. Gunakan saat task menyentuh analytics, SEO tools, CRM, email marketing, advertising, atau data enrichment.
---

# Marketing Tools Registry

Pustaka referensi integrasi tool marketing untuk agent. **Bukan skill yang dieksekusi** — ini knowledge base untuk dicari saat butuh.

## Cara Pakai

1. **Cari tool berdasarkan kategori** — buka [REGISTRY.md](REGISTRY.md): kolom menunjukkan ketersediaan API / MCP / CLI / SDK + link guide.
2. **Baca guide detail** — setiap tool punya dokumen di `integrations/<tool>.md` (setup, operasi umum, contoh).
3. **Mapping Composio toolkit** — untuk akses via Composio, lihat [composio/marketing-tools.md](composio/marketing-tools.md).
4. **CLI siap pakai** — script Node.js di `clis/` (lihat `clis/README.md`).

## Kategori Utama

Analytics (ga4, mixpanel, amplitude, posthog, plausible) · SEO (search-console, semrush, ahrefs, dataforseo, keywords-everywhere, rankparse) · Data Enrichment (clearbit, clay, zoominfo) · CRM (hubspot, salesforce, close) · Email/SMS (klaviyo, mailchimp, customer-io, resend, twilio) · Advertising (meta-ads, google-ads, linkedin-ads, tiktok-ads) · dan 70+ lainnya.

## Kapan Dipakai

- Task menyebut tool marketing spesifik ("tarik data GA4", "setup webhook Klaviyo").
- Riset pilihan tool ("tool SEO apa yang punya API?").
- Implementasi integrasi — selalu mulai dari guide di `integrations/`, jangan mengarang endpoint dari ingatan.
