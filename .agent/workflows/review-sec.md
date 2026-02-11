---
description: Perform a comprehensive security audit of the repository using the security-auditor skill.
---

# Security Review Workflow (/review-sec)

This workflow ensures the repository maintains the highest security standards, preventing secret leaks, misconfigurations, and vulnerability regressions.

## Rules

1.  **Analyze Technical Delta**: Identify all changes in the infrastructure (Terraform), services (Docker Compose), or scripts.
    
    Use `git diff HEAD~1..HEAD` to understand the technical delta and modified files.

2.  **Persona Assignment**: Adopt the [.agent/skills/skills/security-auditor/SKILL.md](@security-auditor) persona. Every audit must be rigorous, critical, and focused on risk mitigation.

3.  **Audit Scopes**:
    - **Infrastructure (Terraform)**:
        - Check for overly permissive firewall rules (e.g., `0.0.0.0/0` on sensitive ports).
        - Verify that `delete_protection` and `prevent_destroy` are enabled for critical data volumes.
        - Ensure NO secrets are hardcoded; they must be fetched from Infisical or environment variables.
    - **Services (Docker Swarm)**:
        - Scan `docker-compose.yaml` for sensitive environment variables in plain text.
        - Check for `privileged: true` or insecure volume mounts (e.g., mounting `/` or `/var/run/docker.sock` unnecessarily).
        - Verify image pinning (avoid `:latest`).
    - **Leaked Credentials**: 
        - Check if files like `.env`, `*.pem`, or `*.key` were inadvertently committed to the history.
        - Cross-reference `.env.example` to ensure it only contains placeholders.
    - **Scripts**: 
        - Audit `.sh` files for hardcoded tokens, insecure temporary file creation, or command injection risks.

4.  **Truth at Source**: Audit the code that is actually present. Do not assume security controls exist unless they are visible in the configuration.

5.  **Prioritization (CVSS-based)**:
    - **CRITICAL**: Immediate action required (e.g., leaked production secret).
    - **HIGH**: Needs fix before next deploy (e.g., restricted but unnecessary open port).
    - **MEDIUM/LOW**: Best practice improvements or hardening.

6.  **Reporting & Action**:
    - If vulnerabilities are found, update the project's `audit_implementation_plan.md` or the root `TODO`.
    - Create a concise summary of the audit findings in the conversation.
    - Never expose real secrets in the final report or conversation output.

7.  **Standardized Language**: Use professional cybersecurity terminology (STRIDE, OWASP, Least Privilege, Defense-in-Depth).

8.  **Automated Validation**: Whenever possible, run `terraform validate` or `docker compose config` during the audit to catch syntax-level security misconfigurations.
