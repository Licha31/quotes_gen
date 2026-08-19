# AGENTS.md

## Project

This repository contains the quote creation application for Adrytentaciones.

The application allows the business owner to quickly create professional
customer quotes and export them as PDF files that can be shared with customers.

The product should prioritize speed, simplicity, and usability.

## Tech direction

- Python is the main language.
- Use FastAPI for the web application.
- Use Pydantic for validation.
- Use SQLite for initial persistence.
- Use Jinja templates for the initial UI.
- Use uv for Python dependency and environment management.
- Use Ruff for linting and formatting.
- Use pytest for tests.

Do not introduce React, Vue, Angular, or another frontend framework unless
explicitly requested or clearly justified.

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

## Interface design

Use the interface-design skill for meaningful UI creation and redesign work.

The interface should follow the Adrytentaciones visual identity described in
`docs/PROJECT.md`.

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

## Definition of done

A task is complete when:

- the requested behavior works;
- existing relevant tests pass;
- new behavior is tested when appropriate;
- linting passes;
- the UI remains usable when relevant;
- no unrelated changes were introduced.