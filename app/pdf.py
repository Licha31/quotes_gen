import re
import unicodedata
from base64 import b64encode
from functools import lru_cache
from pathlib import Path

from playwright.async_api import async_playwright


@lru_cache
def load_pdf_assets(static_dir: Path) -> tuple[str, str]:
    css = (static_dir / "pdf.css").read_text(encoding="utf-8")
    font = b64encode((static_dir / "fonts" / "NunitoSans-Variable.ttf").read_bytes())
    return css, font.decode("ascii")


async def generate_pdf(html: str) -> bytes:
    async with async_playwright() as playwright:
        browser = await playwright.chromium.launch()
        try:
            page = await browser.new_page()
            await page.set_content(html, wait_until="load")
            await page.emulate_media(media="print")
            await page.evaluate("() => document.fonts.ready")
            return await page.pdf(
                format="A4",
                prefer_css_page_size=True,
                print_background=True,
                tagged=True,
            )
        finally:
            await browser.close()


def build_pdf_filename(quote_number: str | None, customer_name: str) -> str:
    identifying_value = quote_number or customer_name
    normalized = unicodedata.normalize("NFKD", identifying_value)
    ascii_value = normalized.encode("ascii", "ignore").decode("ascii")
    safe_value = re.sub(r"[^a-zA-Z0-9]+", "-", ascii_value).strip("-").lower()
    safe_value = safe_value[:60].rstrip("-") or "cliente"
    return f"presupuesto-{safe_value}.pdf"
