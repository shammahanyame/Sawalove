#!/usr/bin/env python3
"""Export SawaLove's legal documents to print-ready PDFs.

Reads the canonical markdown constants from
lib/core/utils/legal_documents.dart (the in-app source of truth),
converts them to styled HTML, and prints each to a PDF with headless
Chrome. Output: legal_exports/{privacy-policy,terms-of-service}-{en,fr}.pdf

Usage:  python scripts/export_legal_pdfs.py
"""

from __future__ import annotations

import html
import os
import re
import subprocess
import sys
import tempfile
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "lib" / "core" / "utils" / "legal_documents.dart"
OUT_DIR = ROOT / "legal_exports"

# const name -> (output file stem, document language)
DOCUMENTS = {
    "kPrivacyPolicyMarkdown": ("privacy-policy-en", "en"),
    "kTermsOfServiceMarkdown": ("terms-of-service-en", "en"),
    "kPrivacyPolicyMarkdownFr": ("privacy-policy-fr", "fr"),
    "kTermsOfServiceMarkdownFr": ("terms-of-service-fr", "fr"),
}

CHROME_CANDIDATES = [
    os.environ.get("CHROME_PATH"),
    r"C:\Program Files\Google\Chrome\Application\chrome.exe",
    r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
    r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
    r"C:\Program Files\Microsoft\Edge\Application\msedge.exe",
]

PAGE_CSS = """
@page { size: A4; margin: 20mm 18mm; }
* { box-sizing: border-box; }
body {
  font-family: Georgia, "Times New Roman", serif;
  color: #141414; font-size: 10.5pt; line-height: 1.55; margin: 0;
}
h1 { font-size: 19pt; line-height: 1.25; margin: 0 0 6pt; color: #111; }
h2 { font-size: 12.5pt; margin: 16pt 0 5pt; color: #1a1a1a; page-break-after: avoid; }
p { margin: 0 0 7pt; text-align: justify; }
p.effective { color: #555; font-size: 9.5pt; margin-bottom: 14pt; text-align: left; }
ul { margin: 0 0 8pt; padding-left: 16pt; }
li { margin-bottom: 4pt; }
.footer {
  margin-top: 18pt; padding-top: 6pt; border-top: 1px solid #ccc;
  color: #666; font-size: 8.5pt; text-align: left;
}
"""


def extract_consts(source: str) -> dict[str, str]:
    consts: dict[str, str] = {}
    for m in re.finditer(r"const String (\w+) = '''(.*?)''';", source, re.S):
        consts[m.group(1)] = m.group(2)
    for m in re.finditer(r"const String (\w+) = '([^']*)';", source):
        consts.setdefault(m.group(1), m.group(2))
    return consts


def inline(text: str) -> str:
    escaped = html.escape(text, quote=False)
    return re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", escaped)


def md_to_html(md: str) -> str:
    """Convert the markdown subset used by legal_documents.dart:
    # / ## headings, **bold**, - bullets, hard-wrapped paragraphs."""
    out: list[str] = []
    para: list[str] = []
    items: list[str] = []

    def flush_para() -> None:
        if not para:
            return
        text = inline(" ".join(para))
        cls = (
            ' class="effective"'
            if text.startswith("<strong>Effective date")
            or text.startswith("<strong>Date d")
            else ""
        )
        out.append(f"<p{cls}>{text}</p>")
        para.clear()

    def flush_items() -> None:
        if not items:
            return
        lis = "".join(f"<li>{inline(item)}</li>" for item in items)
        out.append(f"<ul>{lis}</ul>")
        items.clear()

    for raw in md.splitlines():
        line = raw.rstrip()
        if not line.strip():
            flush_para()
            flush_items()
        elif line.startswith("# "):
            flush_para()
            flush_items()
            out.append(f"<h1>{inline(line[2:])}</h1>")
        elif line.startswith("## "):
            flush_para()
            flush_items()
            out.append(f"<h2>{inline(line[3:])}</h2>")
        elif line.startswith("- "):
            flush_para()
            items.append(line[2:].strip())
        elif items and line[:1].isspace():
            # hard-wrapped continuation of the previous bullet
            items[-1] += " " + line.strip()
        else:
            flush_items()
            para.append(line.strip())

    flush_para()
    flush_items()
    return "\n".join(out)


def render_document(body_html: str, lang: str, title: str) -> str:
    return f"""<!DOCTYPE html>
<html lang="{lang}"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{html.escape(title)}</title>
<style>{PAGE_CSS}</style>
</head><body>
{body_html}
<p class="footer">SawaLove · support@sawalove.cm · Exported from
lib/core/utils/legal_documents.dart (the in-app source of truth — regenerate
this PDF with scripts/export_legal_pdfs.py whenever that file changes).</p>
</body></html>"""


def find_chrome() -> str:
    for candidate in CHROME_CANDIDATES:
        if candidate and Path(candidate).is_file():
            return candidate
    sys.exit(
        "Chrome/Edge not found. Set CHROME_PATH to a Chromium-based browser "
        "executable and re-run."
    )


def main() -> None:
    if not SRC.is_file():
        sys.exit(f"Missing source file: {SRC}")

    consts = extract_consts(SRC.read_text(encoding="utf-8"))
    missing = [name for name in DOCUMENTS if name not in consts]
    if missing:
        sys.exit(f"Could not extract from {SRC.name}: {', '.join(missing)}")

    chrome = find_chrome()
    OUT_DIR.mkdir(exist_ok=True)
    profile_dir = Path(tempfile.mkdtemp(prefix="sawalove-pdf-"))
    exported: list[Path] = []

    for name, (stem, lang) in DOCUMENTS.items():
        md = re.sub(r"\$(\w+)", lambda m: consts.get(m.group(1), m.group(0)), consts[name])
        title = re.sub(r"^#+\s*", "", md.strip().splitlines()[0])
        page = render_document(md_to_html(md), lang, title)

        html_path = OUT_DIR / f"{stem}.html"
        pdf_path = OUT_DIR / f"{stem}.pdf"
        html_path.write_text(page, encoding="utf-8")

        cmd = [
            chrome,
            "--headless",
            "--disable-gpu",
            "--no-pdf-header-footer",
            f"--user-data-dir={profile_dir}",
            f"--print-to-pdf={pdf_path}",
            html_path.as_uri(),
        ]
        if pdf_path.exists():
            pdf_path.unlink()
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
        if result.returncode != 0:
            sys.exit(
                f"Chrome failed for {stem} (exit {result.returncode}):\n"
                f"{result.stderr.strip()[:800]}"
            )
        # Chrome can exit before the PDF is flushed to disk (the launching
        # process hands off to the browser process), so wait for the file to
        # appear and its size to settle before validating it.
        deadline = time.time() + 90
        last_size = -1
        while time.time() < deadline:
            if pdf_path.is_file():
                size = pdf_path.stat().st_size
                if size > 0 and size == last_size:
                    break
                last_size = size
            time.sleep(0.5)
        else:
            sys.exit(f"Timed out waiting for {pdf_path.name} — Chrome wrote no PDF.")
        head = pdf_path.read_bytes()[:5]
        if head != b"%PDF-":
            sys.exit(f"{pdf_path.name} is not a valid PDF (header: {head!r})")
        exported.append(pdf_path)
        print(f"  ok  {pdf_path.relative_to(ROOT)}  ({pdf_path.stat().st_size:,} bytes)")

    print(f"\nExported {len(exported)} PDFs to {OUT_DIR.relative_to(ROOT)}/")
    print("Upload these as privacy.pdf / tos.pdf (see PLAY_STORE_CHECKLIST.md 0.3).")


if __name__ == "__main__":
    main()
