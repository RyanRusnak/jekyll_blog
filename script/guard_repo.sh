#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# guard_repo.sh — refuse to ship if vault content is tracked in this repo.
#
# The architecture is "the repo IS the published surface": only generated
# posts and images live here, never the vault. This script enforces that.
# It runs in two places:
#
#   * script/hooks/pre-push  — locally, before anything leaves the machine
#   * .github/workflows      — in CI, in case something reached main anyway
#
# Exit 0 = clean. Exit 1 = something that looks like vault content is tracked.
# ---------------------------------------------------------------------------
set -uo pipefail

# Top-level directories from the vault that must never appear here. Add to
# this list whenever you add a folder to the vault.
FORBIDDEN_DIRS="Calendar Finances Musings Stuff vault garden"

# Filenames that only ever exist inside an Obsidian vault.
FORBIDDEN_GLOBS=".obsidian .trash .obsidian.vimrc"

fail=0
note() { printf '  %s\n' "$1" >&2; }

tracked=$(git ls-files)
[ -z "$tracked" ] && exit 0

# --- path check -------------------------------------------------------------
for dir in $FORBIDDEN_DIRS; do
  hits=$(printf '%s\n' "$tracked" | grep -E "(^|/)${dir}/" || true)
  if [ -n "$hits" ]; then
    [ "$fail" -eq 0 ] && printf '\nvault content is tracked in this repo:\n\n' >&2
    fail=1
    note "$dir/ — $(printf '%s\n' "$hits" | wc -l | tr -d ' ') file(s)"
  fi
done

for glob in $FORBIDDEN_GLOBS; do
  hits=$(printf '%s\n' "$tracked" | grep -F "$glob" || true)
  if [ -n "$hits" ]; then
    [ "$fail" -eq 0 ] && printf '\nvault content is tracked in this repo:\n\n' >&2
    fail=1
    note "$glob — $(printf '%s\n' "$hits" | wc -l | tr -d ' ') file(s)"
  fi
done

# --- content check ----------------------------------------------------------
# .canary holds one extended-regex per line; blank lines and # comments are
# ignored. It is gitignored on purpose — a canary committed to the repo is a
# canary you are testing against itself. This half of the check is local only.
canary=".canary"
if [ -f "$canary" ]; then
  while IFS= read -r pattern; do
    case "$pattern" in ''|'#'*) continue ;; esac
    hits=$(printf '%s\n' "$tracked" | xargs -I{} grep -lE "$pattern" {} 2>/dev/null || true)
    if [ -n "$hits" ]; then
      [ "$fail" -eq 0 ] && printf '\ncanary pattern matched in tracked files:\n\n' >&2
      fail=1
      note "/${pattern}/ → $(printf '%s\n' "$hits" | tr '\n' ' ')"
    fi
  done < "$canary"
fi

if [ "$fail" -ne 0 ]; then
  cat >&2 <<'MSG'

Nothing was pushed. The vault belongs outside this repo; only generated
_posts/ and assets/img/ are tracked. Untrack the files above, then retry.
MSG
  exit 1
fi

exit 0
