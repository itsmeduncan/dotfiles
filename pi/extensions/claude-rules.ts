/**
 * Claude Rules Extension
 *
 * Scans the project's .claude/rules/ folder for rule files and lists them
 * in the system prompt. The agent then uses the read tool to load specific
 * rules when they are relevant. This mirrors Claude Code's path-scoped rules
 * (claude/rules/{python,typescript,swift,kotlin,terraform}.md in dotfiles)
 * without needing Claude Code's built-in rule loader.
 *
 * Adapted from the pi-coding-agent examples/extensions/claude-rules.ts.
 */

import * as fs from "node:fs";
import * as path from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

/** Recursively find all .md files in a directory. */
function findMarkdownFiles(dir: string, basePath = ""): string[] {
	const results: string[] = [];
	if (!fs.existsSync(dir)) return results;

	for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
		const relativePath = basePath ? `${basePath}/${entry.name}` : entry.name;
		if (entry.isDirectory()) {
			results.push(...findMarkdownFiles(path.join(dir, entry.name), relativePath));
		} else if (entry.isFile() && entry.name.endsWith(".md")) {
			results.push(relativePath);
		}
	}
	return results;
}

export default function claudeRulesExtension(pi: ExtensionAPI) {
	let ruleFiles: string[] = [];

	pi.on("session_start", async (_event, ctx) => {
		const rulesDir = path.join(ctx.cwd, ".claude", "rules");
		ruleFiles = findMarkdownFiles(rulesDir);
		if (ruleFiles.length > 0 && ctx.hasUI) {
			ctx.ui.notify(`Found ${ruleFiles.length} rule(s) in .claude/rules/`, "info");
		}
	});

	pi.on("before_agent_start", async (event) => {
		if (ruleFiles.length === 0) return;

		const rulesList = ruleFiles.map((f) => `- .claude/rules/${f}`).join("\n");
		return {
			systemPrompt:
				event.systemPrompt +
				`

## Project Rules

The following project rules are available in .claude/rules/:

${rulesList}

When working on tasks related to these rules, use the read tool to load the relevant rule files for guidance.
`,
		};
	});
}
