---
description: Review and update project documentation based on repository changes.
---

# Review Docs Workflow

Follow these rules to ensure the project documentation is always accurate and professional.

## Rules

1.  **Analyze Recent Changes**: Identify all changes in the infrastructure (Terraform), services (Docker Compose), or scripts. Start by reviewing the delta since the last documentation update.

    Use `git diff HEAD~1..HEAD` to understand the technical delta and modified files.
2.  **Persona Assignment**: Adopt the [.agent/skills/skills/documentation-specialist/SKILL.md](@documentation-specialist) persona. Every output must meet the high-fidelity standards for technical manuals and architecture guides.
3.  **Map Documentation Impact**:
    - **README.md**: Update if onboarding, requirements, or core project purpose changes.
    - **docs/ARCHITECTURE.md**: Update if cluster topology (Nodes, Networks, Volumes) or infrastructure design is modified.
    - **docs/adr/**: Create or update Architecture Decision Records for any significant design choice using the standard template.
    - **docs/TECHNICAL_MANUAL.md**: Update for internal logic, component details, or implementation specific changes.
    - **docs/SECURITY.md**: Update if firewall rules, hardening policies, or secret management flows are changed.
4.  **Truth at Source**: Document ONLY what is actually implemented in the code. Avoid speculative or planned features unless clearly labeled as "Future/Roadmap".
5.  **Versioning (MAJOR.MINOR)**:
    - Increment the **Minor** version for routine updates, typo fixes, or documentation refinements.
    - Increment the **Major** version for significant infrastructure shifts or architectural redesigns.
    - Every file MUST end with a `## 📝 Version History` table updated with the today's date and a concise summary of changes.
6.  **Visual Documentation**: All complex flows or topologies MUST be accompanied by a Mermaid.js diagram (`flowchart TD`, `sequenceDiagram`). Ensure diagrams use correct syntax and avoid placeholders.
7.  **Update Root CHANGELOG.md**: Document every release and major documentation cycle in the root changelog, categorizing changes by Infrastructure, Cluster, Security, and Documentation.
8.  **Technical Quality Audit**: Before finalizing documentation, scan for and remove any hardcoded internal IDs, secrets, or plain-text credentials that might have inadvertently been included.
9.  **Standardized Language**: Maintain all technical documentation in professional **English**, ensuring terminology matches industry standards (SRE, DevOps, IaC).
10. **Template Consistency**: Use the standardized assets/templates from the documentation specialist skill to maintain a premium feel across all files.