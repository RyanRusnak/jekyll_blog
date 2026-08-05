# ryanrusnak.com

An Omarchy-inspired Jekyll blog: monospace type, sharp corners, hairline rules,
eleven switchable Omarchy palettes, and posts written in Obsidian.

- **Setting up the vault side:** see [SETUP-OBSIDIAN.md](SETUP-OBSIDIAN.md).
- **Theme switching:** click the swatch button in the header or press `T`.
  The choice persists in `localStorage`.

## Run it locally

```bash
gem install bundler
bundle install
bundle exec jekyll serve --livereload
# → http://127.0.0.1:4000
```

## Publish

The vault is **never** committed to this repo. The importer runs on the machine
that holds the vault; CI only builds the `_posts/` that are already here. If it
is in this repo, it is public.

1. Push this folder to a GitHub repo.
2. Repo → Settings → Pages → **Source: GitHub Actions**.
3. `git config core.hooksPath script/hooks` — enables the pre-push guard that
   refuses to ship vault content.
4. `script/publish.sh` — imports `Blog/Published/` from the vault, shows you the diff,
   asks, pushes. The Action builds and deploys.

Full details, including the three gates that keep private notes private, are in
[SETUP-OBSIDIAN.md](SETUP-OBSIDIAN.md).

Custom domain: add a `CNAME` file containing `ryanrusnak.com` and point an ALIAS
/ CNAME record at GitHub Pages.

## Layout of the repo

```
_config.yml                  site settings + default_theme
_layouts/                    default, post, page
_includes/                   head, header, statusbar, post-card
assets/css/main.scss         the whole theme, incl. all 11 palettes
assets/js/theme.js           palette switcher (T)
assets/js/search.js          client-side search over search.json
script/import_vault.rb       Obsidian Blog/Published/ → _posts (allowlist + prune)
script/publish.sh            the publishing pipeline, run where the vault lives
script/guard_repo.sh         refuses to ship vault content (pre-push + CI)
script/hooks/pre-push        enable with: git config core.hooksPath script/hooks
_posts/                      generated — do not hand-edit, edit the note
assets/img/                  generated — copied from Blog/Published/attachments
index.html  about.md  search.md  404.html
```

## Things you will want to change

| Where | What |
| --- | --- |
| `_config.yml` | title, tagline, url, `default_theme` |
| `_includes/header.html` | the `ryanrusnak.com` wordmark |
| `about.md` | bio + now list |
| `assets/css/main.scss` | `--accent` per palette if you want a different lead colour |

MIT licensed. Palettes belong to their respective theme authors.
