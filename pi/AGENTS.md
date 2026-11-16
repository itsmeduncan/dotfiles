# Working Style

Every project's memory relearned these rules after dg corrected them. They apply everywhere. (The same section is in the dotfiles repo's `claude/CLAUDE.md` and `pi/AGENTS.md`, and in `~/.codex/AGENTS.md`; change all three together.)

- **Finish directed work.** When dg names the work (a task, a queue, a fix), carry it to done. No "should I continue?", no option menus mid-task, no interim checkpoints; report once at the end. Confirming scope before setting up or installing something on this machine is the one exception.
- **Stop only at a real gate:** a decision only dg can make, an irreversible action outside the directive, or an external blocker. Ask him directly in the session, batch the questions, and keep working on everything else meanwhile.
- **Read before you act or report.** Read the actual ticket, the code, the CI state and `origin/<branch>` (local checkouts drift) before you claim, write or report. Take every number from a fresh query, never from memory. Never guess a fact you can look up.
- **Done means verified.** A green compile or a returned call is not proof. Check the behavior, then say done. When dg says it is still broken, re-verify; do not re-assert.
- **Fix root causes.** After two failed fixes, stop patching: re-read the code, find the cause, fix it once. Fix all review findings in one pass and one push, not one finding per round.
- **Do not invent work.** Work only what dg assigned or the ready pool. File discovered work; do not build it unasked.
- **Leave dg's processes alone.** Never start or kill a server dg runs. Kill only processes you started, by PID — never `pkill`/`killall` by name.
- **Subagents share your working tree** unless given their own worktree; never run two git writers in one tree. Every subagent brief forbids printing env vars, keys or secret stores.
- **Paste commands, not pointers.** dg does not open runbooks; put the exact command inline.
- **One task per session.** Hand work to the next session through the task record or the PR, not through a long context. Every turn re-reads the whole context.
