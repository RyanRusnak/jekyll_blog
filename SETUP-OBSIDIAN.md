# Writing in Obsidian, publishing to Jekyll

## The one rule

**If it is in this repo, it is public.** The vault never enters git. The importer
runs on the machine that holds the vault and commits only what it generated:
`_posts/` and `assets/img/`. CI builds those and nothing else.

That is the whole security model. There is no "private folder that Jekyll knows
to skip" to reason about, because the private notes are not here at all.

---

## 1. The vault

```
~/Obsidian Vault/
  Blog/          ← the ONLY folder the importer reads
    Why Airspace.md
    Drafts/      ← never publishes, whatever the frontmatter says
    Concepts/    ← never publishes, whatever the frontmatter says
  Calendar/      ← invisible to the pipeline
  Finances/      ← invisible to the pipeline
  Musings/       ← invisible to the pipeline
  Stuff/         ← invisible to the pipeline
  templates/     ← Templater frontmatter template
```

`PUBLISH_DIR` at the top of `script/import_vault.rb` is an **allowlist**, not a
list of exclusions. A folder you add next year is private by default — you never
have to remember to exclude it.

`NEVER_PUBLISH` is the one exception inside `Blog/`. Notes under those
subfolders — at any depth, matched case-insensitively — are private even with
`publish: true`, and the importer says so rather than leaving you to wonder:

```
warning: Life Starts at 40.md: in Drafts/, which never publishes —
         `publish: true` is being ignored. Move it out of Drafts/ to publish it.
```

It is a warning rather than an error on purpose: one unfinished draft must never
be able to block publishing everything else. To publish such a note, move it up
into `Blog/`.

Sync is Obsidian LiveSync over Tailscale. Write from any device on the tailnet;
only the Mac mini has the repo and the push credentials, so a phone cannot
publish on its own.

---

## 2. The three gates

Each one alone is enough to stop an accident. Publishing takes all three.

| # | Gate | Where |
| --- | --- | --- |
| 1 | Only `Blog/` is ever read | `PUBLISH_DIR`, `script/import_vault.rb` |
| 2 | `publish: true` required — absent or `false` means private | note frontmatter |
| 2a | `Drafts/` and `Concepts/` never publish, flag or not | `NEVER_PUBLISH` |
| 3 | Vault content cannot be committed | `script/guard_repo.sh`, pre-push hook + CI |

So a leak needs two independent mistakes — moving a note into `Blog/` **and**
setting `publish: true` — and neither does anything by itself.

`_posts/` is **generated**. The importer prunes anything no longer backed by a
published note, so flipping `publish` back to `false` actually unpublishes. Do
not hand-edit files in `_posts/`; edit the note.

---

## 3. Frontmatter

```yaml
---
title: Publishing from a folder
date: 2026-07-24
kind: essay
tags: [writing, tooling]
description: One sentence that shows up in the post list and in search.
publish: true
---
```

| Field | Format | Notes |
| --- | --- | --- |
| `title` | plain text | Becomes the `<h1>` and the URL slug |
| `date` | `YYYY-MM-DD` | Falls back to file mtime if missing or unparseable |
| `kind` | `essay` · `notes` · `til` · `links` | Small caps in the meta row. Defaults to `notes` |
| `tags` | `[a, b]` — lowercase, no `#` | Rendered as `#a #b` chips |
| `description` | one or two sentences | Homepage excerpt. Falls back to the first paragraph |
| `publish` | `true` | **Anything else stays private** |
| `slug` | optional | Override the URL |
| `dropcap` | optional, `false` | Turns off the big accent capital |

> [!warning]
> Renaming a published note changes its URL. Set `slug:` once a post has been
> linked from anywhere you care about.

Two notes that slugify to the same URL are a collision: the importer warns and
publishes only the first, rather than silently clobbering one with the other.

---

## 4. Markdown the theme understands

| You write | You get |
| --- | --- |
| `## Section` | Small-caps section rule with an accent dash |
| `> quote` | Large italic pull quote with an accent bar |
| `> [!note]` / `[!warning]` / `[!tip]` / `[!danger]` / `[!quote]` | Coloured callout blocks |
| `[[another note]]` | Real link **if that note is in `Blog/` and published**; otherwise plain text |
| `[[another note\|alias]]` | Same, with your alias as the label |
| `![[screenshot.png]]` | Full-width bordered figure; `![[shot.png\|caption]]` adds a caption |
| ```` ```mermaid ```` fence | Rendered diagram |
| `[^1]` footnotes | Footnote list under a hairline rule |

Attachments are resolved **inside `Blog/` only** — put images in
`Blog/attachments/`. An embed pointing outside it is dropped with a warning
rather than reaching into the rest of the vault on a filename match.

A wikilink to an unpublished note renders as plain text with no tooltip, so a
dead link never advertises that a private note exists.

Backlinks are automatic: any published post whose body links to this one appears
in the **linked from** panel. You do not maintain that list.

---

## 5. One-time setup on the Mac mini

```bash
cd ~/Code/Personal/blog
git init && git remote add origin git@github.com:you/blog.git

# Gate 3: refuse to push vault content. Version controlled, survives a reclone.
git config core.hooksPath script/hooks

# Optional but recommended: content canary
cp .canary.example .canary
$EDITOR .canary        # add a token you paste into your sensitive notes
```

**Obsidian settings**

- Files & Links → New link format: **Shortest possible path**; Wikilinks: **on**;
  default attachment folder: `Blog/attachments`
- Editor → Properties in document: **Visible** (gives you a checkbox for
  `publish` instead of raw YAML — typing the key is where typos live)
- Enable the **Templater** plugin, point its template folder at `templates/`,
  and use `templates/blog post.md` for new posts. It writes `publish: false`,
  so publishing is always a deliberate flip.

---

## 6. The loop

```bash
script/publish.sh --dry-run   # what would change; touches nothing
script/publish.sh             # import, show the diff, ask, push
```

`publish.sh` does five things in order:

1. **Debounce** — skips notes touched in the last 60s, so LiveSync can't hand the
   importer half a sentence you are still typing on your phone
2. **Import** — allowlist + `publish: true`, prune what's gone
3. **Guard** — refuse if vault content got tracked
4. **Review** — prints added / removed / modified posts and waits for `y`
5. **Push** — CI builds `_posts`

The git diff *is* the review step. Nothing reaches the site that you have not
seen listed.

**Automating it.** A LaunchAgent can run `script/publish.sh` on a timer, but
without `--yes` it stages and stops when there is no terminal — an unattended run
can never publish on its own. Add `--yes` only once you trust the gates.

---

## 7. Preview locally

```bash
script/publish.sh --dry-run              # see what's publishable
ruby script/import_vault.rb ~/Obsidian\ Vault
bundle exec jekyll serve --livereload
```

Two panes: Obsidian on the left, `localhost:4000` on the right.

There is deliberately no "preview an unpublished note" mode. A flag that
publishes everything is a flag you can forget you left on; to preview a post,
set `publish: true` and look at it locally before you push.
