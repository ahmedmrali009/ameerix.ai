#!/usr/bin/env python3
"""Regenerates web/sitemap.xml with hreflang alternates for every route.

Usage:  python3 tool/generate_sitemap.py [https://your-domain.com]
Keep ROUTES in sync with lib/config/routes.dart and LANGS with
lib/localization/supported_languages.dart.
"""
import sys
from datetime import date
from pathlib import Path

BASE = (sys.argv[1] if len(sys.argv) > 1 else "https://www.ameerix.com").rstrip("/")
ROUTES = [
    ("/", "1.0", "weekly"),
    ("/platform", "0.9", "monthly"),
    ("/solutions", "0.8", "monthly"),
    ("/industries", "0.8", "monthly"),
    ("/how-it-works", "0.8", "monthly"),
    ("/technology", "0.7", "monthly"),
    ("/about", "0.7", "monthly"),
    ("/insights", "0.6", "weekly"),
    ("/contact", "0.7", "yearly"),
]
LANGS = ["en", "ar", "zh", "es", "it", "fr", "de", "pt"]

today = date.today().isoformat()
out = [
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"',
    '        xmlns:xhtml="http://www.w3.org/1999/xhtml">',
]
for path, prio, freq in ROUTES:
    url = BASE + path
    out.append("  <url>")
    out.append(f"    <loc>{url}</loc>")
    out.append(f"    <lastmod>{today}</lastmod>")
    out.append(f"    <changefreq>{freq}</changefreq>")
    out.append(f"    <priority>{prio}</priority>")
    for lang in LANGS:
        out.append(f'    <xhtml:link rel="alternate" hreflang="{lang}" href="{url}?lang={lang}"/>')
    out.append(f'    <xhtml:link rel="alternate" hreflang="x-default" href="{url}"/>')
    out.append("  </url>")
out.append("</urlset>")

target = Path(__file__).resolve().parent.parent / "web" / "sitemap.xml"
target.write_text("\n".join(out) + "\n", encoding="utf-8")
print(f"Wrote {target} ({len(ROUTES)} routes x {len(LANGS)} languages)")
