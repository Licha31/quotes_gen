# Adrytentaciones Interface Design System

This file records the visual system already implemented in the quote creation
interface. It is the reference for future UI work. Extend these patterns only
when a real product need requires it; do not invent parallel styles.

## Visual concept

The interface is a bakery quote and order sheet, not a SaaS dashboard. It should
feel like a carefully prepared working document from a warm, handmade pastry
business: clear enough for fast data entry and polished enough to support a
customer-facing quote.

The brand signature is the prominent coral Adrytentaciones wordmark and its
restrained icing-line detail. Functional areas remain flat, document-like, and
highly readable. Decoration must never compete with quote creation.

## Color system

Use the existing CSS tokens and roles. Do not introduce arbitrary colors.

| Token | Current value | Role |
| --- | --- | --- |
| `--meringue` | `#fffaf3` | Warm header and light brand surface |
| `--paper-cream` | `#fffdf9` | Main quote-sheet surface and focused controls |
| `--blush-canvas` | `#f8e9e5` | Application canvas |
| `--blush-soft` | `#fcefeb` | Integrated summary surface and subtle emphasis |
| `--coral-icing` | `#e96f61` | Primary action, focus, rules, and brand detail |
| `--coral-deep` | `#bd4e45` | Wordmark, emphasized text, and final total |
| `--coral-wash` | `#f9d9d2` | Quiet monetary and subtotal underline |
| `--cocoa-ink` | `#342824` | Primary readable text |
| `--cocoa-soft` | `#6f5d57` | Supporting text and secondary controls |
| `--cocoa-muted` | `#9a8580` | Placeholders, optional labels, and availability text |
| `--icing-text` | `#fffaf8` | Text on coral primary actions |
| `--control-fill` | `#fbf6f1` | Inset control background |
| `--line-soft` | `rgb(83 55 48 / 12%)` | Quiet outer borders and separators |
| `--line-section` | `rgb(83 55 48 / 19%)` | Section and product-row dividers |
| `--line-emphasis` | `rgb(189 78 69 / 34%)` | Emphasized total divider |
| `--control-border` | `rgb(83 55 48 / 18%)` | Default form-control border |
| `--focus-ring` | `rgb(233 111 97 / 28%)` | Accessible focus halo |

Coral communicates brand, focus, action, and important monetary emphasis. Keep
main reading and form surfaces cream rather than making every surface pink.

## Typography

### Functional typeface

Use the locally hosted **Nunito Sans** variable font for all functional UI text.
The current fallback is `"Segoe UI", sans-serif`. Functional typography should
feel warm, rounded, friendly, substantial, and easy to read.

- Body and input text: weight `500`.
- Labels and normal metadata: weight `600`.
- Section headings, buttons, and strong controls: weight `700`.
- Primary page heading and final total: weight `800`.
- Do not use thin functional weights.
- Do not make every element bold; hierarchy comes from deliberate use of these
  four levels.

### Brand typeface

Script typography is reserved exclusively for the **Adrytentaciones wordmark**.
The current stack is `"Segoe Script", "Brush Script MT", cursive`, weight `800`,
with a responsive size of `clamp(2.5rem, 6vw, 4.25rem)`.

Never use script typography for headings, labels, body text, prices, totals,
buttons, navigation, tables, or other functional UI.

### Accessible type scale

- Body and functional base: `17px`, weight `500`, line height `1.5`.
- Input and button text: `1rem`.
- Field labels: `1rem`, weight `600`.
- Helper and optional text: `0.88rem`, weight `500`.
- Page heading: `clamp(1.8rem, 4vw, 2.6rem)`, weight `800`, line height `1.08`.
- Section heading: `1.35rem`, weight `700`.
- Summary heading: `1.55rem`, weight `700`.
- Final total: `1.7rem`, weight `800`.

Do not use eyebrow text anywhere in the product. Do not place small uppercase
pre-headings above titles. Use the real heading, normal metadata, field labels,
or simple status text instead.

## Layout and viewport usage

- Header and main content use `min(1760px, 94vw)`.
- The desktop quote sheet uses `minmax(0, 1fr) 360px`: the form receives the
  flexible space and the summary remains prominent.
- The page shell uses `36px 0 56px` vertical padding.
- The quote sheet is one integrated surface. The form and summary are not
  separate floating panels.
- The introduction remains compact and task-oriented. It is not an editorial
  hero section.
- Preserve a minimum supported viewport width of `320px`.

Use the available desktop canvas. Do not artificially narrow forms or create
large empty side margins.

## Spacing

The spacing base is `4px`. Reuse the current rhythm rather than introducing
arbitrary values:

- Micro relationships: `4px`, `7px`, `8px`, and `12px`.
- Control and grid gaps: `16px` and `20px`.
- Major component gaps: `24px`, `28px`, and `32px`.
- Desktop form sections: `28px 32px 32px`.
- Mobile form sections and summary: `24px 20px`.

Spacing should support quick scanning and comfortable targets without turning
the application into an overly spacious dashboard.

## Shape and depth

- Functional control radius: `5px` (`--radius-small`).
- Quote-sheet radius: `6px` (`--radius-medium`).
- Large organic curves are reserved for intentional brand details such as the
  icing line; they are not a general component treatment.
- The only sheet shadow is `0 3px 12px rgb(93 51 43 / 5%)`.
- Do not give nested sections, product rows, or the summary separate shadows.

Depth comes primarily from warm surface shifts and restrained borders, with one
quiet shadow supporting the complete quote sheet.

## Borders and dividers

- Use low-opacity cocoa borders rather than harsh solid outlines.
- The quote sheet uses a `1px` soft border and a `3px` coral top rule.
- Form sections and product rows use `1px solid var(--line-section)` dividers.
- The form and desktop summary are separated by a single section divider.
- The final total uses `var(--line-emphasis)` for stronger hierarchy.
- Coral rules identify brand, section indexes, status, and total emphasis; they
  should remain sparse.

## Form controls

- Keep native, accessible HTML controls.
- Inputs and textareas inherit the `17px` functional type and weight `500`.
- Inputs have a minimum height of `52px` and padding `12px 14px`.
- Textareas have a minimum height of `120px` and remain vertically resizable.
- Buttons have a minimum height of `50px`, padding `12px 18px`, and weight `700`.
- Controls use `--control-fill`, `--control-border`, and a `5px` radius.
- Hover strengthens the border quietly.
- Focus uses a coral border and a visible `4px` `--focus-ring` halo.
- Placeholders use `--cocoa-muted` but remain readable.
- Money inputs keep the currency symbol visually attached to the native input.

Do not replace native controls with custom widgets solely for visual reasons.

## Section hierarchy

Sections are document divisions, not cards.

- Each section has a two-column heading grid: a `38px` index column and flexible
  heading content.
- Section indexes use coral text, tabular numbers, weight `700`, and a short
  `2px` coral rule. They are not circular badges.
- Section headings use `1.35rem`, weight `700`.
- Supporting descriptions use normal `1rem` text in `--cocoa-soft`.
- Sections are separated by horizontal lines and spacing, not nested surfaces.

## Product row

The product row is a flat portion of the order sheet:

- No card background, radius, or shadow.
- `16px 0` vertical padding with section-color dividers above and below.
- Full desktop grid:
  `minmax(320px, 2.4fr) 104px minmax(190px, 1fr) 140px`.
- Description receives substantially more width than quantity.
- Quantity remains compact; price and subtotal stay aligned and scannable.
- Item subtotal uses tabular numbers, `1.05rem`, weight `700`, right alignment,
  and a quiet coral-wash underline.

## Summary panel

The summary is part of the quote sheet, not a floating card.

- Desktop width: `360px`.
- Background: `--blush-soft`.
- Padding: `28px`.
- Sticky position on desktop with `top: 24px`.
- A straight `3px` coral top rule provides emphasis without extra decoration.
- The header uses a soft bottom divider.
- The explanatory note uses a `2px` coral left rule rather than a nested box.
- The summary has no independent radius, border, or shadow.

## Monetary values

- Use Nunito Sans with `font-variant-numeric: tabular-nums` for aligned amounts.
- Regular summary amounts: `1.05rem`, weight `600`.
- Item subtotal: `1.05rem`, weight `700`.
- Final total: `1.7rem`, weight `800`, color `--coral-deep`.
- Keep subtotal, discount, and total visible as separate rows.

## Responsive behavior

- Above `1320px`, the product description, quantity, price, and subtotal share
  the full product grid.
- At `1320px` and below, product description moves to a full-width first row;
  quantity, price, and subtotal remain aligned beneath it.
- At `1080px` and below, the quote summary moves below the form and stops being
  sticky. A horizontal divider preserves the integrated-sheet relationship.
- At `640px` and below, content width becomes `calc(100% - 28px)`, field grids
  stack into one column, the subtotal becomes a horizontal row, and secondary
  actions expand to full width.
- Do not hide important quote information to make mobile layouts fit.

## Accessibility and readability

- Design for comfortable reading without browser zoom.
- Maintain the current `17px` functional base and large control targets.
- Preserve strong dark-on-light contrast and the primary, supporting, muted,
  and coral-emphasis text roles.
- Never communicate meaning through color alone.
- Keep labels programmatically associated with native controls.
- Preserve clearly visible keyboard focus states.
- Use tabular numbers for amounts that must scan vertically.
- Keep important status, helper, price, and total information visible.
- Respect reduced-motion preferences; the current system reduces transition
  duration under `prefers-reduced-motion`.
- Decorative details must never reduce readability or compete with form entry.

## Anti-patterns

These are permanent rules:

- No eyebrow text.
- No decorative pills.
- No excessive rounded cards.
- No floating SaaS panels.
- No excessive soft shadows.
- No generic editorial hero composition.
- No thin functional typography.
- No script typography in functional UI.
- No decorative elements that reduce readability.
- No all-pink surfaces, glassmorphism, gradients, or generic dashboard styling.
- No custom controls created only for visual novelty.

Visual polish must not introduce unnecessary frontend complexity. Prefer native
HTML, focused CSS, and the existing server-rendered architecture. Do not add a
frontend framework, UI library, JavaScript abstraction, or new dependency solely
to achieve visual polish.
