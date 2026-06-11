#!/bin/bash
# AI agent configs: Claude Code, opencode, and the shared skills directory
# consumed by Claude, Codex, opencode, and pi.
# shellcheck source=lib/_common.sh
. "$DOTFILES_DIR/lib/_common.sh"

# Tool roots that consume the shared agents/skills/ tree.
_AGENT_SKILL_ROOTS=(
  "$HOME/.claude/skills"
  "$HOME/.agents/skills"
  "$HOME/.pi/agent/skills"
)

agents_run() {
  # Shared skills — one source, multiple consumers.
  for root in "${_AGENT_SKILL_ROOTS[@]}"; do
    link "$DOTFILES_DIR/agents/skills" "$root"
  done

  # opencode auth seed (placeholder; user replaces with real keys).
  # NOT symlinked — auth.json holds secrets and lives outside the repo.
  if [ ! -f "$HOME/.local/share/opencode/auth.json" ]; then
    if [ "${CHECK_MODE:-0}" = "1" ]; then
      warn "opencode auth.json missing — will be seeded on next install"
    elif [ "${DRY_RUN:-0}" = "1" ]; then
      would "seed ~/.local/share/opencode/auth.json with lm-studio placeholder"
    else
      mkdir -p "$HOME/.local/share/opencode"
      cat > "$HOME/.local/share/opencode/auth.json" << 'EOF'
{
  "lm-studio": {
    "type": "api",
    "key": "sk-local"
  }
}
EOF
      ok "seeded opencode auth.json with lm-studio placeholder"
    fi
  fi

  # Claude Code profile-wide config.
  link "$DOTFILES_DIR/claude/CLAUDE.md"     "$HOME/.claude/CLAUDE.md"
  link "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"
  link "$DOTFILES_DIR/claude/agents"        "$HOME/.claude/agents"
  link "$DOTFILES_DIR/claude/rules"         "$HOME/.claude/rules"
  link "$DOTFILES_DIR/claude/hooks"         "$HOME/.claude/hooks"
  link "$DOTFILES_DIR/claude/statusline.sh" "$HOME/.claude/statusline.sh"
}
