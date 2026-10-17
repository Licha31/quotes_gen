# Presupuestador Adrytentaciones

## Product

Adrytentaciones is a small handmade pastry and bakery business based in
San Juan, Argentina.

The application exists to make customer quote creation fast and simple.

The primary user is the business owner, who frequently needs to prepare a quote
while communicating directly with a customer.

## Main problem

Creating quotes manually takes unnecessary time and requires repeatedly
formatting product descriptions, quantities, prices, totals, and business
information.

The approved replacement is a Flutter Android app that works entirely offline.
It should create a professional quote in a few minutes and generate a PDF only
when requested, ready to share or save through Android. Quote data is held in
memory for the current session only: no database, persistent draft, history,
account, backend, or synchronization. The existing FastAPI app remains as a
reference until Android acceptance.

## Main workflow

1. Create a new quote.
2. Enter customer information.
3. Add products or services.
4. Enter quantities and unit prices.
5. Automatically calculate subtotals.
6. Apply an optional discount.
7. Add optional notes.
8. Preview the finished quote.
9. Generate a PDF.
10. Share the PDF with the customer.

## MVP data

### Customer

- Name
- Phone number (optional)

### Quote

- Quote number (optional, trimmed, at most 32 characters)
- Date
- Valid-until date
- Notes (optional)

### Items

Each item contains:

- Description
- Quantity
- Unit price
- Subtotal

### Totals

- Subtotal
- Optional discount
- Final total

## PDF

The generated PDF should include:

- Adrytentaciones branding
- Quote number
- Date
- Customer information
- Itemized products or services
- Quantities
- Unit prices
- Subtotals
- Final total
- Notes
- Quote validity
- Contact information

## Visual identity

The application's visual direction should be based on the existing
Adrytentaciones brand.

### Brand personality

The product should feel:

- warm;
- handmade;
- friendly;
- sweet;
- welcoming;
- feminine without becoming childish;
- modern while preserving the artisanal identity.

It should communicate a small bakery made with care rather than corporate
software.

### Main visual references

The existing Adrytentaciones identity prominently uses:

- soft pink backgrounds;
- pale blush and cream surfaces;
- coral / salmon branding;
- white;
- strong black text where readability is needed;
- occasional warm golden details;
- soft cloud-like decorative shapes;
- rounded organic forms;
- pastry and baking imagery.

### Color direction

The main interface palette should derive from:

- soft blush pink as a background or secondary surface;
- warm cream / off-white for content areas;
- coral or salmon as the primary brand accent;
- darker warm coral for emphasis;
- dark neutral text for strong readability;
- optional muted gold accents used sparingly.

Avoid making every surface pink.

The main content and form areas should remain calm and highly readable.

### Typography

The existing brand uses expressive script lettering for the Adrytentaciones
name.

Use expressive or script typography only for the Adrytentaciones wordmark.

Do not use script typography for:

- form labels;
- prices;
- tables;
- buttons;
- navigation;
- body text.

Use Nunito Sans for functional interface typography. It should feel warm,
friendly, substantial, and highly legible. Avoid thin font weights. Use weight
500 for body and input text, 600 for labels, 700 for section headings, and 700
or 800 for page headings, totals, and important monetary values.

Do not use eyebrow-style labels anywhere in the product. Do not add small
uppercase pre-headings above titles. Express important information through the
actual heading, normal metadata, field labels, or simple status text.

### Shape language

Prefer:

- rounded corners;
- soft surfaces;
- subtle borders;
- gentle shadows;
- organic curves;
- occasional cloud-inspired details.

Avoid:

- harsh geometric layouts;
- excessive glassmorphism;
- neon colors;
- overly corporate dashboards;
- dense enterprise-style interfaces.

### Decorative elements

Decorative baking references can be used to give the application character,
but they should be subtle.

Possible motifs include:

- icing-like curves;
- small sparkles;
- baking-inspired line illustrations;
- soft cloud or cream shapes.

Decoration must never compete with quote creation.

### UI character

The application should not look like a generic admin template.

A user opening it should immediately recognize it as an Adrytentaciones tool.

At the same time, forms and quote information should feel professional enough
that the generated document can be sent directly to a customer.

## UX priorities

The primary workflow should be usable quickly and with minimal learning.

Important actions should be visually obvious.

The quote total should always be easy to identify.

Adding another item should require minimal effort.

The Android app should remain usable at 320 logical pixels without hiding quote
details. The existing web app remains a desktop and mobile reference.

## Non-goals for the MVP

The first version does not require:

- artificial intelligence;
- WhatsApp automation;
- user accounts;
- online payments;
- inventory management;
- advanced customer management;
- advanced analytics;
- React or another JavaScript frontend framework;
- cloud deployment.
- persistent quote or draft storage;
- network access or analytics.

The Android app uses integer centavos for all prices and totals. Validation,
preview, and PDF must use the same quote model. Railway retirement requires
real-device acceptance and separate approval of the identified resources.
