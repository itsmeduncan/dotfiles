-- "Open in Neovim" — a LaunchServices document handler for markdown files.
--
-- lib/macos.sh compiles this to ~/Applications/Open in Neovim.app with
-- `osacompile`, stamps it with a stable bundle id, and registers it as the
-- default .md app via `duti`. Opening a markdown file (Finder double-click,
-- `open foo.md`, a link handoff) launches nvim on it in a new Ghostty window.
-- Launching the app with no file just opens nvim in a fresh Ghostty window.
--
-- Edit this source, then re-run `./install.sh --only=macos` to rebuild the app.

on open theFiles
	repeat with f in theFiles
		set p to POSIX path of f
		do shell script "open -na Ghostty --args -e nvim " & quoted form of p
	end repeat
end open

on run
	do shell script "open -na Ghostty --args -e nvim"
end run
