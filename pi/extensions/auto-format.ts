/**
 * Auto-Format Extension
 *
 * Formats files after the agent edits or writes them — the Pi equivalent of
 * Claude Code's PostToolUse auto-format.sh hook. Runs the same formatters:
 *   .py                      -> ruff format
 *   .ts .tsx .js .jsx .json .css .md -> prettier
 *   .swift                   -> swiftformat
 *   .kt .kts                 -> ktlint --format
 *
 * Failures are swallowed (formatter missing, syntax error mid-edit, etc.), matching
 * the shell hook's `|| true` behavior, so a formatting hiccup never blocks the agent.
 */

import { execFile } from "node:child_process";
import * as fs from "node:fs";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const TIMEOUT_MS = 30_000;

/** Run a formatter, resolving quietly regardless of outcome. */
function run(cmd: string, args: string[]): Promise<void> {
	return new Promise((resolve) => {
		execFile(cmd, args, { timeout: TIMEOUT_MS }, () => resolve());
	});
}

async function formatFile(filePath: string): Promise<void> {
	if (!filePath || !fs.existsSync(filePath)) return;

	if (filePath.endsWith(".py")) {
		await run("ruff", ["format", "--quiet", filePath]);
	} else if (/\.(tsx?|jsx?|json|css|md)$/.test(filePath)) {
		await run("npx", ["--yes", "prettier", "--write", "--log-level", "silent", filePath]);
	} else if (filePath.endsWith(".swift")) {
		await run("swiftformat", ["--quiet", filePath]);
	} else if (/\.(kt|kts)$/.test(filePath)) {
		await run("ktlint", ["--format", filePath]);
	}
}

export default function autoFormatExtension(pi: ExtensionAPI) {
	pi.on("tool_result", async (event) => {
		if (event.isError) return;
		if (event.toolName !== "edit" && event.toolName !== "write") return;

		const filePath = (event.input as { path?: string })?.path;
		if (filePath) {
			try {
				await formatFile(filePath);
			} catch {
				// Never let a formatter failure surface to the agent.
			}
		}
	});
}
