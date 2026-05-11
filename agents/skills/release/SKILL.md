---
name: release
description: Cut a release. Generates an internal changelog (every commit, every PR) and a public-facing changelog (curated, tagged), then opens a PR merging main into the release branch.
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, AskUserQuestion
---

# /release

Promote `main` to the `release` branch with a paired changelog cut.

You are running the `/release` workflow. Output:

1. `docs/changelog/internal/<YYYY-MM-DD>.md` — every PR + every commit since the last release, with authors, SHAs, and raw subjects. The team's source of truth for what shipped.
2. `docs/changelog/public/<YYYY-MM-DD>.md` — curated, customer-facing entries grouped by tag (Feature / Improvement / Fix / Connector / Guardrail). Skipped if no user-facing changes.
3. A new branch `cut/<YYYY-MM-DD>` carrying just the changelog commits, pushed and opened as a PR with base `release`, head `cut/<YYYY-MM-DD>`.

This is a **non-interactive** workflow under Auto Mode. The only stops are when you genuinely cannot proceed: dirty working tree, no changes to release, or the public changelog turns out empty (ask whether to ship internal-only).

## Step 0 — Preflight

```bash
git status --porcelain
```

If there's any output, **stop**. Tell the user to commit / stash and rerun. The release branch must be cut from a clean main.

```bash
git fetch origin main release 2>&1 | tail -3
git rev-parse --abbrev-ref HEAD
```

If not on `main`, `git checkout main && git pull --ff-only`.

## Step 1 — Detect the release range

```bash
RELEASE_DATE=$(date -u +%Y-%m-%d)
# Branch name uses `cut/` not `release/` because `release` exists as a
# branch — git can't create `release/<date>` as a child name when the
# parent path is already a leaf branch.
RELEASE_BRANCH="cut/${RELEASE_DATE}"
LAST_RELEASE_SHA=$(git rev-parse origin/release)
COMMIT_COUNT=$(git rev-list --count "${LAST_RELEASE_SHA}..origin/main")
echo "Releasing $COMMIT_COUNT commits since $LAST_RELEASE_SHA"
```

If `COMMIT_COUNT == 0`, **stop** — `main` is already at `release`. There's nothing to cut.

If a `cut/${RELEASE_DATE}` branch already exists locally or on origin, append a short SHA: `RELEASE_BRANCH="cut/${RELEASE_DATE}-$(git rev-parse --short origin/main)"`. This way re-running on the same day doesn't collide.

## Step 2 — Build the internal changelog (always runs)

Internal changelog is the **full** record. Every commit, every PR, every author, every SHA. It exists so a year from now you can answer "what shipped on 2026-05-06" without grepping git.

```bash
git log --first-parent "${LAST_RELEASE_SHA}..origin/main" \
  --pretty=format:"%h%x09%ad%x09%an%x09%s" --date=short
```

For each merge commit (`Merge pull request #N from ...`), pull the PR number out of the subject. For each non-merge commit, list it as a direct push.

Write `docs/changelog/internal/<YYYY-MM-DD>.md`:

```markdown
# Internal changelog — <YYYY-MM-DD>

Range: `<short-sha-of-last-release>..<short-sha-of-main>` (<COMMIT_COUNT> commits)

## Pull requests

- **#<N>** — `<merge subject minus "Merge pull request #N from owner/branch">` (<author>, <YYYY-MM-DD>, `<short-sha>`)
- ...

## Direct pushes (not via PR)

- `<short-sha>` <subject> (<author>, <YYYY-MM-DD>)
- ...

## Stats

- Merged PRs: <N>
- Direct pushes: <M>
- Authors: <comma-separated unique names>
- Files changed: <run `git diff --shortstat ${LAST_RELEASE_SHA}..origin/main` and paste>
```

If a section has zero entries, omit it (don't ship empty headings).

## Step 3 — Build the public changelog (curated)

Walk the merged PRs from Step 2. For each PR:

1. Fetch the body via `gh pr view <N> --json title,body,labels`. If `gh` isn't authenticated or the PR can't be loaded, fall back to the merge commit subject + the squashed commit body (`git log <merge-sha> -1 --format=%B`).
2. Classify it. The classification rule is conservative — when in doubt, **skip** (internal changes don't go in the public log):

   | Tag             | Example PR shapes                                                                           |
   | --------------- | ------------------------------------------------------------------------------------------- |
   | **Feature**     | "feat:" prefix; new connector, new page, new founder-visible capability                     |
   | **Improvement** | "feat:" or "perf:" that enhances an existing user-visible feature                           |
   | **Fix**         | "fix:" prefix touching user-visible behavior (chat, dashboard, billing, onboarding)         |
   | **Connector**   | new connector slice — anything under `services/api/app/connectors/<id>/`                    |
   | **Guardrail**   | policy / approval / hard-floor / audit / rollback ledger changes the founder feels          |
   | (skipped)       | infra-only refactors, test coverage, schema-registry plumbing, CI changes, dependabot bumps |

   The skip rule is the load-bearing one: **a PR that doesn't change anything a customer can observe does not appear in the public log.** Schema registry, idempotency cache plumbing, lint fixes, internal docs — internal log only.

3. Rewrite the title in plain user-facing language. **Strip:**
   - Conventional-commit prefixes (`feat:`, `fix(chat):`, etc.)
   - Internal jargon (`ConnectorInvocation`, `BrainEvent`, `signature_hash`)
   - Implementation details ("via Postgres advisory lock")

   Keep what a non-engineer reading the changelog would need: **what changed** + **what it means for them**.

4. Group by tag, then within each tag write 1–3 lines per entry. Lead with the verb.

Write `docs/changelog/public/<YYYY-MM-DD>.md`:

```markdown
---
date: <YYYY-MM-DD>
range: <short-sha-of-last-release>..<short-sha-of-main>
---

# <YYYY-MM-DD>

## Features

- **<Short headline>.** <One-to-three sentence plain-English description.>
- ...

## Improvements

- ...

## Fixes

- ...

## Connectors

- **<Connector Name> connector.** <What founders can now do — read X, write Y, with Z approval gate.>

## Guardrails

- ...
```

If a tag has zero entries, omit the heading.

If **every** PR in the range was internal (no Feature / Improvement / Fix / Connector / Guardrail entries), use AskUserQuestion:

> Re-grounding: Project = Aqen, on branch `<branch>`, cutting release to `<RELEASE_DATE>`.
> Plain English: Every PR in this batch is internal plumbing — nothing that a customer can see has changed since the last release. Want to ship the release anyway (internal-only)?
>
> RECOMMENDATION: Choose A — internal releases are still worth tagging so the audit trail is continuous. Completeness: 9/10.
> A) Ship internal-only (no public changelog file written) — Completeness: 9/10
> B) Cancel — wait until there's a customer-visible change to bundle with — Completeness: 6/10

If A: skip writing the public file and continue. If B: stop and don't open the PR.

## Step 4 — Render the public site

Run the build script so the rendered HTML + RSS land in the same release commit:

```bash
node sites/landing/scripts/build-changelog.mjs
```

Output: `sites/landing/changelog/index.html` + `sites/landing/changelog/rss.xml`. The script has no npm deps; it walks `docs/changelog/public/*.md`, parses each file, and emits the canonical /changelog page Caddy serves on `www.aqen.ai/changelog`.

Skip this step on internal-only releases — there's no public markdown to render.

## Step 5 — Commit + push

```bash
git checkout -b "$RELEASE_BRANCH" origin/main
git add docs/changelog/ sites/landing/changelog/
git commit -m "chore(release): changelog for $RELEASE_DATE

Internal: docs/changelog/internal/$RELEASE_DATE.md ($COMMIT_COUNT commits)
Public:   docs/changelog/public/$RELEASE_DATE.md (or 'omitted — internal-only release')"
git push -u origin "$RELEASE_BRANCH"
```

If `git commit` reports "nothing to commit" (which only happens if you're re-running and the changelog already landed), skip the commit and proceed straight to the PR step.

## Step 6 — Open the PR (target: `main`)

The cut PR targets `main`, not `release`. Two reasons:

1. The changelog files belong on the source-of-truth branch. If the PR went straight to `release`, the markdown source on `main` would always be one release behind, and the next `/release` run would re-classify the same PRs that just shipped.
2. CI on `main` is the gate everyone watches. Routing the cut through `main` reuses that gate instead of asking the team to babysit a parallel CI lane on `release`.

```bash
gh pr create \
  --base main \
  --head "$RELEASE_BRANCH" \
  --title "release: $RELEASE_DATE" \
  --body "$(cat <<EOF
## Summary

Cuts the changelog for $RELEASE_DATE. <COMMIT_COUNT> commits in this batch since the last release ($(git rev-parse --short origin/release)).

After this lands on \`main\`, fast-forward \`release\` to match (\`git push origin main:release\`) — that's the deploy promotion.

## Internal changelog

See \`docs/changelog/internal/$RELEASE_DATE.md\` — every PR + every direct push.

## Public changelog

See \`docs/changelog/public/$RELEASE_DATE.md\`.
<or, when public is omitted: "Omitted — every PR in this range was internal plumbing.">

## Test plan

- [x] CI passing on \`main\` at $(git rev-parse --short origin/main)
- [x] Internal changelog covers every PR in the merge range
- [x] Public changelog tagged correctly (Feature / Improvement / Fix / Connector / Guardrail)
- [ ] After merge: \`git push origin main:release\` to promote
EOF
)"
```

Print the PR URL.

## Step 7 — Promote `release` (after the cut PR merges)

The cut PR landing on `main` produces the source-of-truth state. Production tracks `release`, so fast-forward it once the cut PR is merged + green:

```bash
git fetch origin main release
git push origin origin/main:release
```

This is a fast-forward (no merge commit) because `release` was always an ancestor of `main` before the cut PR. Railway / the landing-site Caddy redeploys from the new `release` tip.

If the FF is rejected (someone direct-pushed to `release`, or `release` diverged), stop and reconcile manually — never `--force` to a deployment branch.

**Done.**

## Format conventions

### Internal changelog

- File path: `docs/changelog/internal/<YYYY-MM-DD>.md`
- One file per release. If multiple releases ship the same day, append a short SHA: `<YYYY-MM-DD>-abc1234.md`.
- Always lists the **range** (last-release SHA `..` main SHA) so re-creation from the git log is mechanical.
- Authors deduped, ordered by how often they appear in the range.

### Public changelog

- File path: `docs/changelog/public/<YYYY-MM-DD>.md`
- Customer voice. No conventional-commit prefixes, no implementation details, no internal naming.
- Tag taxonomy is closed: Feature / Improvement / Fix / Connector / Guardrail. New tags require updating this skill.
- A PR can appear under at most one tag.
- Internal-only releases skip the file entirely. The PR description explicitly notes the skip so the audit trail records the decision.

### Tag rule of thumb

Ask: **"would a non-Aqen-employee customer notice this?"** If yes → public, pick the tag. If no → internal-only.

## When NOT to invoke this skill

- Mid-day fixes that haven't landed on `main` yet — wait for them to merge first.
- During an active rollback — finish the rollback, then cut a fresh release that includes the revert.
- When `main` is failing CI — fix CI on `main`, then cut.
