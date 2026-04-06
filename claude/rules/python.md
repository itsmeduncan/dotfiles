---
paths:
  - "**/*.py"
  - "**/pyproject.toml"
  - "**/requirements*.txt"
---

# Python

- Package manager: uv (`uv add`, `uv sync`, `uv run`)
- Linting/formatting: ruff (`ruff check --fix`, `ruff format`)
- Type checking: pyright
- Testing: pytest
- Style: ruff format, 4-space indent, double quotes, type hints on public APIs
- Use `src/` layout for packages
- Prefer f-strings, `pathlib.Path`, `dataclasses`/`pydantic` over raw dicts
