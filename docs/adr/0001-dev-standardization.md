# ADR 0001: Standardization of Development Workflow (ADR & Traceability)

*   **Status:** Accepted
*   **Date:** 2026-03-17
*   **Deciders:** Gemini CLI, User

## Context and Problem Statement

As the project grows and transitions from the legacy `sphere` codebase to the modern `rizu` architecture, the gap between specifications and actual implementation is widening. We need a way to ensure that architectural decisions are recorded and that features defined in specifications are actually verified by tests.

## Decision Drivers

*   **Maintainability:** Long-term project health depends on knowing *why* decisions were made.
*   **Reliability:** High confidence that the code implements 100% of the designed behavior.
*   **Agent Alignment:** Ensuring AI agents follow project-specific engineering standards autonomously.

## Considered Options

1.  **Manual Documentation:** Rely on developers to keep docs updated (too error-prone).
2.  **External Jira/Tracking:** Use external tools for requirements (adds friction and breaks the "everything in git" philosophy).
3.  **In-repo ADRs & Traceability Tags:** Use Markdown ADRs and custom `@spec` tags in Lua tests, verified by local scripts.

## Decision Outcome

**Option 3** was chosen. We will use:
1.  **MADR (Markdown ADR) structure** in `docs/adr/`.
2.  **Living Specifications** where `spec.md` files are linked to `_test.lua` files via `@spec` tags.
3.  **Automated Verification** via `scripts/check_spec_coverage.lua`.

### Positive Consequences

*   Documentation stays close to the code (in the same repo).
*   Traceability is machine-verifiable.
*   Agents can now "read" the project's history via ADRs to avoid repeating past mistakes.

### Negative Consequences

*   Slightly more overhead when writing tests (adding tags).
*   Requires discipline to update `spec.md` before/during implementation.

## Implementation Notes

*   Rules are encoded in `GEMINI.md` to ensure agent compliance.
*   The coverage script uses LuaJIT for fast execution during CI or local validation.
