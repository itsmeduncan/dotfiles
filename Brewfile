# Brewfile — declarative Homebrew manifest.
# Synced by lib/brew.sh via `brew bundle install --file=Brewfile`.
#
# Scope: only things mise can't manage or that are tightly coupled to Homebrew
# (services with `brew services`, zsh plugin assets sourced from brew paths,
# system networking utilities, GUI casks). All CLI dev tools live in mise.toml.
#
# Note on version pinning: Homebrew only supports version pinning for formulae
# that ship as versioned siblings (e.g. postgresql@18). Most formulae have no
# such variant — `brew install tmux` always installs latest. For true byte-
# reproducible Homebrew state across machines, see `bootstrap-state.snapshot`
# which captures `brew bundle list` output at a known-good moment.

# --- Bootstrap ---
brew "mise" # version manager — bootstraps everything in mise.toml

# --- Terminal multiplexer ---
brew "tmux"

# --- zsh plugins (sourced from brew paths in zshrc) ---
brew "spaceship"
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"

# --- Services / system tooling ---
# postgresql is pinned to a major version because the data directory is
# version-specific. Bumping major versions (18 -> 19) requires pg_upgrade.
# To upgrade: brew install postgresql@19, run pg_upgrade, edit this file.
brew "postgresql@18", restart_service: :changed, link: true
brew "watchman"

# --- Networking ---
brew "mosh"
brew "nmap"
brew "wget"

# --- Docs / files ---
brew "tldr"
brew "yazi"

# --- Not in mise registry ---
brew "git-absorb"

# --- Ruby gem (brew tap is canonical) ---
brew "cocoapods"

# --- GUI applications ---
cask "ghostty"
cask "orbstack"
cask "1password"
cask "1password-cli" # required for SSH-agent commit signing (see gitconfig)
cask "slack"
cask "notion"
cask "obsidian" # markdown notes vault at ~/notes/ (also edited via obsidian.nvim)
cask "tailscale-app"
cask "lm-studio"
cask "gcloud-cli"

# --- Fonts ---
cask "font-meslo-lg-nerd-font"

# --- Android (only installed when sdk dir is missing; see lib/android.sh) ---
cask "android-commandlinetools"
