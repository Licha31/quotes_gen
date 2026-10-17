# AGENTS.md

## Project

This repository contains the quote creation application for Adrytentaciones.

The application allows the business owner to quickly create professional
customer quotes and export them as PDF files that can be shared with customers.

The product should prioritize speed, simplicity, and usability.

## Approved direction

- Build the Android replacement with Flutter and Dart.
- Keep all quote data in memory during the current session. Do not add a
  database, saved drafts, quote history, accounts, backend calls, or network
  requirements.
- Generate the PDF only at the owner's request and share or save it through
  Android.
- Use integer centavos for money and one validated model for preview and PDF.
- Preserve the existing FastAPI/Jinja app as a behavior and visual reference
  until the Android replacement passes real-device acceptance.
- Use Flutter's built-in widgets and local state unless a dependency has a
  concrete purpose. Use Flutter analysis and tests for Android changes.
- For changes to the existing web app, continue using uv, Ruff, and pytest.

## Product priorities

The primary user is the owner of a small bakery business.

Creating a quote should be fast and require as little friction as possible.

Prioritize:

1. Fast quote creation.
2. Clear product and price entry.
3. Automatic calculations.
4. Easy preview.
5. Reliable PDF generation.
6. Simple sharing workflow.

## MVP boundaries

Do not add unless explicitly requested:

- AI features;
- WhatsApp integration;
- authentication;
- online payments;
- inventory management;
- advanced CRM features;
- cloud infrastructure;
- unnecessary frontend frameworks.
- persistence, synchronization, analytics, and a network requirement.

## Interface design

Use the interface-design skill for meaningful UI creation and redesign work.

The interface should follow `.interface-design/system.md` and
`docs/PROJECT.md`, including a usable 320 logical pixel layout.

The design should feel custom to the business rather than like a generic SaaS
dashboard.

However:

- usability is more important than decoration;
- avoid unnecessary frontend complexity;
- prefer accessible native controls when appropriate;
- preserve fast workflows;
- decorative elements must not interfere with forms or readability.

## Development workflow

Keep changes small and reviewable.

Before implementing a feature:

1. Read the relevant files.
2. Understand the current implementation.
3. Confirm the requested scope.
4. Avoid implementing future features prematurely.

After implementing:

1. Run relevant tests.
2. Run Ruff.
3. Verify the requested behavior.
4. Review the diff.
5. Summarize what changed.
6. Mention important tradeoffs or decisions.

Do not retire Railway until the Android APK has passed acceptance on the
intended phone and the user has approved the specific retirement action.

## Definition of done

A task is complete when:

- the requested behavior works;
- existing relevant tests pass;
- new behavior is tested when appropriate;
- linting passes;
- the UI remains usable when relevant;
- no unrelated changes were introduced.
