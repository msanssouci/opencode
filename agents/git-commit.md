---
description: Generate conventional commit messages. Use when the user says "commit", mycommit", "commit my changes", wants to create a git commit, or needs an automated commit message based on staged changes.
tools:
  bash: true
  read: true
  grep: true
  list: true
  question: true
  skill: false
---

## Arguments

$ARGUMENTS — Optional context about the changes (e.g., "fixing auth bug", "refactoring utils")

## Steps

1. **Check for beads integration**
   - Run: `bd list --status=in_progress,open --json 2>/dev/null || echo "No beads"`
   - If beads tasks exist in `in_progress` or `open` status:
     * ⚠️ STOP: Suggest closing all beads tasks first
     * Recommend: `bd close <id> --reason="..." --json` for each open task
     * Recommend: `bd sync --flush-only` to prepare beads metadata
     * Then proceed to get git context (step 2)
   - If no beads or beads not initialized, continue normally

2. **Get git context**
   - Run: `~/.config/opencode/scripts/run-precommit.sh && git add . && ~/.config/opencode/scripts/get-git-context.sh --staged-only`
   - ⚠️ If this fails, stop and report the error to the user
   - Returns: diff, changed files, and commitlint config (if present)

3. **Generate commit message**

   Analyze the context and generate a conventional commit following this format:

   **Format:** `type(scope): description`

   **Types:**
   | Type | Use When |
   |------|----------|
   | `feat` | New feature |
   | `fix` | Bug fix |
   | `docs` | Documentation changes |
   | `style` | Formatting, no logic change |
   | `refactor` | Code restructuring |
   | `perf` | Performance improvement |
   | `test` | Adding/fixing tests |
   | `build` | Build system/dependencies |
   | `ci` | CI configuration |
   | `chore` | Other maintenance |
   | `revert` | Reverts previous commit |

   **Rules:**
   - Scope is optional but recommended (e.g., `auth`, `api`, `ui`)
   - Description: present tense, lowercase, no period at end
   - Max 72 characters for first line
   - Focus on the "why" not the "what"
   - **If beads tasks detected in step 1**: Include them in commit footer: `Closes: beads-xxx, beads-yyy`

   **Examples:**
   - `feat(auth): add JWT token validation`
   - `fix(api): handle null response in user endpoint`
   - `refactor: extract common validation logic`
   - With beads: `feat(auth): add JWT validation\n\nCloses: beads-123, beads-124`

   If user provided context in $ARGUMENTS, use it to understand the intent.

4. **Ensure beads metadata is included (if beads detected)**
   
   If beads is being used (detected in step 1):
   - Check if `.beads/issues.jsonl` and `.beads/interactions.jsonl` exist
   - Verify they are staged: `git diff --cached --name-only | grep .beads`
   - If not staged, run: `git add .beads/issues.jsonl .beads/interactions.jsonl`

5. **Create the commit**
   
   Using the commit message you generated in step 3, run this command with Bash tool:
   
   ```bash
   git commit -m "<commit_message>"
   ```
   
   Replace `<commit_message>` with your generated message. Example:
   ```bash
   git commit -m "feat(auth): add JWT token validation"
   ```
