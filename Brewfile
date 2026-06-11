# Brewfile — declarative Homebrew manifest.
# Synced by lib/brew.sh via `brew bundle install --file=Brewfile`.
#
# Scope: only things mise can't manage or that are tightly coupled to Homebrew
# (services with `brew services`, zsh plugin assets sourced from brew paths,
# system networking utilities, GUI casks). All CLI dev tools live in mise.toml.

# --- Bootstrap ---
brew "mise" # version manager — bootstraps everything in mise.toml

# --- Terminal multiplexer ---
brew "tmux"

# --- zsh plugins (sourced from brew paths in zshrc) ---
brew "spaceship"
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"

# --- Services / system tooling ---
brew "postgresql"
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
cask "tailscale"
cask "lm-studio"
cask "gcloud-cli"

# --- Fonts ---
cask "font-meslo-lg-nerd-font"

# --- Android (only installed when sdk dir is missing; see lib/android.sh) ---
cask "android-commandlinetools"
