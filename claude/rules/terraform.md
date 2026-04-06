---
paths:
  - "**/*.tf"
  - "**/*.tfvars"
---

# Terraform

- Run via mise: `mise exec -- terraform <command>`
- Format: `terraform fmt -recursive`
- Validate: `terraform validate`
- Use variables with descriptions and type constraints
- Prefer `for_each` over `count` for named resources
- Keep provider versions pinned in `required_providers`
