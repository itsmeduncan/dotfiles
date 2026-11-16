/**
 * Local Providers Extension
 *
 * Registers model providers from the machine-local, untracked
 * <agent dir>/models.local.json (same `providers` shape as models.json), so
 * providers that name private hosts stay out of this public repo. No file, no
 * providers. Model fields that models.json fills by default get the same
 * defaults here.
 */

import * as fs from "node:fs";
import * as path from "node:path";
import { type ExtensionAPI, getAgentDir } from "@earendil-works/pi-coding-agent";

type LocalModel = Record<string, unknown> & { id: string };
type LocalProvider = Record<string, unknown> & { compat?: unknown; models?: LocalModel[] };

const MODEL_DEFAULTS = {
	input: ["text"],
	reasoning: false,
	contextWindow: 128000,
	maxTokens: 16384,
	cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
};

function readLocalProviders(file: string): Record<string, LocalProvider> {
	if (!fs.existsSync(file)) return {};
	try {
		return JSON.parse(fs.readFileSync(file, "utf8")).providers ?? {};
	} catch (error) {
		throw new Error(`${file} is not valid JSON (${error}). Fix it or remove it.`);
	}
}

function withDefaults({ compat, models, ...provider }: LocalProvider) {
	return {
		...provider,
		models: (models ?? []).map((model) => ({
			name: model.id,
			...MODEL_DEFAULTS,
			...(compat === undefined ? {} : { compat }),
			...model,
		})),
	};
}

export default function localProvidersExtension(pi: ExtensionAPI) {
	const file = path.join(getAgentDir(), "models.local.json");
	for (const [id, provider] of Object.entries(readLocalProviders(file))) {
		pi.registerProvider(id, withDefaults(provider) as Parameters<typeof pi.registerProvider>[1]);
	}
}
