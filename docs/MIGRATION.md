# Android migration status

The checked-out implementation repository is `Licha31/quotes_gen`. The web
behavior baseline was commit `27a6aed812ca0d8aa4dc7e19215ef7feea9f9d23`.
The FastAPI/Jinja source remains in place as the behavior and visual reference.

## Implemented

- Offline Flutter form, field validation, centavo calculations, and preview.
  The Dart parser follows the Python server rules rather than the looser web
  live-estimate parser. No database, draft store, backend call, or network
  permission is used by the release app.
- On-demand A4 PDF generation from validated quote data and Android sharing
  through `printing`. The share plugin uses a temporary PDF in app cache; the
  Android activity clears prior share files at the next fresh launch.
- Android package `com.adrytentaciones.presupuestos`, app name and icon, and a
  local acceptance APK build. See `docs/ANDROID.md` for signing and installation.

The Android layout puts the summary below the form and shows each product as a
vertical entry, matching the web design system's narrow-screen behavior. Dates
start at today and seven days later to make entry faster. The wordmark uses a
bundled OFL script font because the web's `Segoe Script` fallback is not
available consistently on Android. The PDF uses static weights derived from
the repository's OFL Nunito Sans variable font for readable headings and totals.

## Verification

- Flutter tests cover money parsing, validation, totals, form recovery, product
  editing, fresh-launch state, PDF generation, and 320/390 logical pixel layouts.
- A 45-item PDF with long descriptions and notes rendered as six A4 pages.
  Visual review found readable text, complete totals, and no clipped rows;
  notes now begin with their heading on the final page.
- Flutter analysis, Ruff, and the 34 existing Python tests pass.
- The release APK installed and launched on a Motorola edge 70 pro (Android 16).
  With airplane mode enabled, a two-item quote showed `$ 63.000,00` subtotal,
  `$ 5.000,00` discount, and `$ 58.000,00` total in the form and preview. Android
  saved the generated PDF as `presupuesto-carolina-perez.pdf` in Downloads; the
  phone's PDF viewer opened it and showed the same amounts and dates. The PDF
  was also parsed successfully after copying it to the local QA folder.
- A fresh app launch showed an empty form. The layout was reviewed on the phone
  and on an emulator set to 320 logical pixels. Airplane mode was disabled again
  after the test.

## Required acceptance before retirement

The technical phone check passed. Owner review and acceptance of the APK and PDF
remain necessary before retiring Railway. The local acceptance APK uses debug
signing; an owner-held key is required for durable updates. Railway resources
have not been identified or changed. Ticket 4 requires owner acceptance and
separate approval for the exact retirement action.
