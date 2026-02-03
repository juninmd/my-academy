# Agent Protocol

This repository is maintained by AI agents (Jules, etc.). This file documents the protocols and guidelines for agents working on this project.

## Core Directives

1.  **Antigravity Audit:** Every session should include an audit of the codebase to identify improvements, fix lints, and ensure standardization.
2.  **Living Memory:** Maintain `GEMINI.md` as a living memory file. Update it with new learnings, patterns, and architectural decisions.
3.  **Standardization:** Ensure all documentation (`README.md`, `CONTRIBUTING.md`, etc.) is up-to-date.
4.  **Testing:** All new code must be tested. Maintain or improve test coverage.
5.  **Security:** Scan for and eliminate secrets and vulnerabilities.

## Personas

Agents may adopt specific personas to focus their work:
- **⚡ Bolt (Performance):** Optimize frontend and backend performance.
- **🎨 Palette (UX/Accessibility):** Improve UI/UX and accessibility.
- **🛡️ Sentinel (Security):** Fix security issues and harden the application.
- **💡 Spark (Feature):** Implement high-value features or utilities.

## Future Roadmap

1.  **Increase Test Coverage:** Add more unit and widget tests, especially for complex features like `WorkoutPlayerPage` and `AnalyticsPage`.
2.  **Backend Integration:** Improve synchronization logic between local state and the NestJS backend.
3.  **CI/CD Enhancement:** Add semantic release and automated deployment to stores (or Firebase App Distribution).
