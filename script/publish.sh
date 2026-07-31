#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# publish.sh — the whole publishing pipeline, run on the machine that holds
# the vault (the Mac mini).
#
#   script/publish.sh              # import, show the diff, ask, push
#   script/publish.sh --dry-run    # show what would change, touch nothing
#   script/publish.sh --yes        # no prompt (for a LaunchAgent)
#
# Order matters:
#   1. debounce  — skip notes still being edited, so LiveSync can't hand us
#                  half a sentence from a phone mid-write
#   2. import    — allowlist Blog/ + publish: true, prune what's gone
#   3. guard     — refuse if vault content somehow got tracked
#   4. review    — the git diff IS the review; you see exactly what ships
#   5. push      — CI builds _posts, nothing more
# ---------------------------------------------------------------------------
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VAULT="${VAULT:-$HOME/Obsidian Vault}"
PUBLISH_DIR="Blog"
QUIET_SECONDS="${QUIET_SECONDS:-60}"

ASSUME_YES=0
DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    --yes|-y)  ASSUME_YES=1 ;;
    --dry-run) DRY_RUN=1 ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

cd "$REPO"

[ -d "$VAULT/$PUBLISH_DIR" ] || { echo "no $PUBLISH_DIR/ in vault: $VAULT" >&2; exit 1; }
git rev-parse --git-dir >/dev/null 2>&1 || { echo "$REPO is not a git repository" >&2; exit 1; }

# --- 1. debounce ------------------------------------------------------------
# A note touched in the last QUIET_SECONDS may still be mid-sync. Rather than
# publish a fragment, back off and let the next run pick it up.
recent="$(ruby -e '
  root, quiet = ARGV[0], ARGV[1].to_i
  now = Time.now
  puts Dir.glob(File.join(root, "**", "*.md"))
           .select { |f| (now - File.mtime(f)) < quiet }
           .map    { |f| File.basename(f, ".md") }
' "$VAULT/$PUBLISH_DIR" "$QUIET_SECONDS")"

if [ -n "$recent" ]; then
  echo "still being edited (touched in the last ${QUIET_SECONDS}s), backing off:"
  # Quoted + read, not `printf '%s\n' $recent` — note titles contain spaces.
  printf '%s\n' "$recent" | while IFS= read -r name; do printf '  %s\n' "$name"; done
  echo "nothing published."
  exit 0
fi

# --- 2. import --------------------------------------------------------------
echo "importing from $VAULT/$PUBLISH_DIR"
if [ "$DRY_RUN" -eq 1 ]; then
  ruby script/import_vault.rb "$VAULT" --dry-run
  exit 0
fi
ruby script/import_vault.rb "$VAULT"

# --- 3. guard ---------------------------------------------------------------
git add -A _posts assets/img
bash script/guard_repo.sh

# --- 4. review --------------------------------------------------------------
if git diff --cached --quiet; then
  echo
  echo "no change — the site already matches the vault."
  exit 0
fi

echo
echo "about to publish:"
echo
git diff --cached --name-status -- _posts assets/img | while read -r status path; do
  case "$status" in
    A) printf '  + %s\n' "$(basename "$path")" ;;
    D) printf '  - %s  (unpublished)\n' "$(basename "$path")" ;;
    M) printf '  ~ %s\n' "$(basename "$path")" ;;
    *) printf '  %s %s\n' "$status" "$path" ;;
  esac
done
echo
git diff --cached --stat -- _posts assets/img | tail -1

if [ "$ASSUME_YES" -ne 1 ]; then
  # No tty and no --yes means an automated run: refuse rather than guess.
  if [ ! -t 0 ]; then
    echo >&2
    echo "not a terminal and --yes not given — staged but not pushed." >&2
    exit 1
  fi
  echo
  read -r -p "push this to the live site? [y/N] " reply
  case "$reply" in
    y|Y|yes) ;;
    *) echo "left staged, nothing pushed."; exit 0 ;;
  esac
fi

# --- 5. push ----------------------------------------------------------------
count="$(git diff --cached --name-only -- _posts | wc -l | tr -d ' ')"
git commit -q -m "publish: ${count} post file(s) changed"
git push -q
echo
echo "pushed. GitHub Actions is building — check the Actions tab."
