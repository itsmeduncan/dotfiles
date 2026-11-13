/**
 * Auto-Format Extension
 *
 * Formats files after the agent edits or writes them — the Pi equivalent of
 * Claude Code's PostToolUse auto-format.sh hook. Runs the same formatters:
 *   .py                      -> ruff format
 *   .ts .tsx .js .jsx .json .css .md -> the project's own prettier, if installed
 *   .swift                   -> swiftformat
 *   .kt .kts                 -> ktlint --format
 *
 * Prettier runs only from the project's own node_modules, and only in a git
 * repo that does NOT commit node_modules: a cloned repo that ships its own
 * node_modules/.bin/prettier would otherwise run its code on every edit.
 *
 * Failures are swallowed (formatter missing, syntax error mid-edit, etc.), matching
 * the shell hook's `|| true` behavior, so a formatting hiccup never blocks the agent.
 */

import { execFile, execFileSync } from "node:child_process";
import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const TIMEOUT_MS = 30_000;

/** Run a formatter, resolving quietly regardless of outcome. */
function run(cmd: string, args: string[]): Promise<void> {
    return new Promise((resolve) => {
        execFile(cmd, args, { timeout: TIMEOUT_MS }, () => resolve());
    });
}

/** Resolve a tool path the way pi does: strip a leading "@", expand "~", resolve against cwd. */
function resolveToolPath(input: string, cwd: string): string {
    let p = input.startsWith("@") ? input.slice(1) : input;
    if (p === "~") p = os.homedir();
    else if (p.startsWith("~/")) p = path.join(os.homedir(), p.slice(2));
    return path.resolve(cwd, p);
}

function git(dir: string, args: string[]): string | undefined {
    try {
        return execFileSync("git", ["-C", dir, ...args], { encoding: "utf8", stdio: ["ignore", "pipe", "ignore"] }).trim();
    } catch {
        return undefined;
    }
}

/** The project's own node_modules/.bin/prettier between the file and the git top-level. */
function findProjectPrettier(filePath: string): string | undefined {
    let dir = fs.realpathSync(path.dirname(filePath));
    const top = git(dir, ["rev-parse", "--show-toplevel"]);
    if (!top) return undefined;
    if (git(top, ["ls-files", "--", "node_modules"])) return undefined; // tracked node_modules: untrusted
    for (;;) {
        const candidate = path.join(dir, "node_modules", ".bin", "prettier");
        if (fs.existsSync(candidate)) return candidate;
        const parent = path.dirname(dir);
        if (dir === top || parent === dir) return undefined;
        dir = parent;
    }
}

async function formatFile(filePath: string): Promise<void> {
    if (!fs.existsSync(filePath)) return;

    if (filePath.endsWith(".py")) {
        await run("ruff", ["format", "--quiet", filePath]);
    } else if (/\.(tsx?|jsx?|json|css|md)$/.test(filePath)) {
        const prettier = findProjectPrettier(filePath);
        if (prettier) await run(prettier, ["--write", "--log-level", "silent", filePath]);
    } else if (filePath.endsWith(".swift")) {
        await run("swiftformat", ["--quiet", filePath]);
    } else if (/\.(kt|kts)$/.test(filePath)) {
        await run("ktlint", ["--format", filePath]);
    }
}

export default function autoFormatExtension(pi: ExtensionAPI) {
    pi.on("tool_result", async (event, ctx) => {
        if (event.isError) return;
        if (event.toolName !== "edit" && event.toolName !== "write") return;

        const input = (event.input as { path?: string })?.path;
        if (!input) return;
        try {
            await formatFile(resolveToolPath(input, ctx.cwd));
        } catch {
            // Never let a formatter failure surface to the agent.
        }
    });
}
