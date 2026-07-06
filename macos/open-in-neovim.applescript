-- "Open in Neovim" — a LaunchServices document handler for markdown files.
--
-- lib/macos.sh compiles this to ~/Applications/Open in Neovim.app with
-- `osacompile`, stamps it with a stable bundle id, and registers it as the
-- default .md app via `duti`. Opening a markdown file (Finder double-click,
-- `open foo.md`, a link handoff) launches nvim on it in a new Ghostty window.
-- Launching the app with no file just opens nvim in a fresh Ghostty window.
--
-- Why the shell wrapper: Ghostty's `-e` execs its command through
-- `/usr/bin/login` with a minimal PATH, so a bare `nvim` isn't found (it's
-- mise-managed) and, even if it were, nvim would miss its tooling (ripgrep,
-- language servers, node for markdown-preview). Routing through
-- `/bin/zsh -ilc 'exec nvim "$@"'` sources the full login+interactive
-- environment first, so nvim launches exactly as it would from the terminal.
--
-- Edit this source, then re-run `./install.sh --only=macos` to rebuild the app.

on open theFiles
	repeat with f in theFiles
		set p to POSIX path of f
		do shell script "open -na Ghostty --args -e /bin/zsh -ilc 'exec nvim \"$@\"' nvim " & quoted form of p
	end repeat
end open

on run
	do shell script "open -na Ghostty --args -e /bin/zsh -ilc 'exec nvim'"
end run
