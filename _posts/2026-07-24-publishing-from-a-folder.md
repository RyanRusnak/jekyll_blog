---
layout: post
title: Publishing from a folder
date: '2026-07-24'
kind: essay
tags:
- writing
- tooling
description: Every post here starts as a markdown file in an Obsidian vault. No CMS,
  no publish button — a folder, a git remote, and forty lines of YAML.
slug: publishing-from-a-folder
mermaid: true
---

Every post on this site begins as a file in a folder. It is an Obsidian vault,
which is a generous way of saying it is a directory of markdown with some links
between the files. There is no CMS. There is no publish button. There is a
folder, and there is a robot that watches it.

I have tried the other way. I have had blogs on platforms that let me drag images
around and pick from nine hundred fonts, and I wrote almost nothing on any of
them, because opening the editor felt like arriving at an office. Writing in a
text file feels like writing in a notebook — the tool disappears, and the only
thing left in front of me is the sentence I have not finished.

## The pipeline

The whole thing is four moving parts, and three of them are things I would have
running anyway. Obsidian writes the file. A script on an always-on Mac mini
imports it. Git moves the result. A GitHub Action builds the site with Jekyll.
Nothing here is clever, and that is the entire point — see <span class="wikilink-dead">boring by design</span>
for the longer argument.

<div class="mermaid">
flowchart LR
  A[Obsidian<br/>Blog/*.md] --> B[import on the mini<br/>publish: true only]
  B --> C[git push<br/>_posts only] --> D[Jekyll build<br/>GitHub Actions] --> E[Pages]
</div>

A note becomes a post when I add three lines of frontmatter to it. Everything
without `publish: true` stays private, which means the vault stays a vault — most
of what is in there is grocery lists and half-formed grudges.[^1]

The important half is what the repository is allowed to contain. The vault never
enters git. The importer runs where the notes live, and the only thing that gets
committed is what it generated:

```bash
# on the machine with the vault
ruby script/import_vault.rb ~/Obsidian\ Vault   # reads Blog/, prunes the rest
git add _posts assets/img && git push           # nothing else is tracked
```

<div class="callout callout-note">
  <div class="callout-title"><span class="ic">i</span>note</div>
  <p>`import_vault.rb` rewrites wikilinks into Jekyll permalinks, turns Obsidian callouts into the blocks you are looking at, and copies only the attachments that published notes actually reference.</p>
</div>


<div class="callout callout-warning">
  <div class="callout-title"><span class="ic">!</span>warning</div>
  <p>A vault-wide sync will happily publish a note you renamed at 1am. Read from an allowlisted folder rather than skipping a list of private ones — a denylist makes every folder you add later public by default.</p>
</div>


## What it looks like from the inside

Two panes, no browser. The left one is the note; the right one is the local
preview, which I check about twice per post and otherwise ignore.

> The best writing tool is the one you already have open for another reason.

I do not know whether anyone should copy this setup. I know that I have published
more in six months of owning a folder than in six years of owning an account, and
that when this site eventually dies, the writing will still be sitting in a
folder, in files I can open with anything.

[^1]: Both of which are, admittedly, good writing prompts.
