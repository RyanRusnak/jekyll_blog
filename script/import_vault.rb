#!/usr/bin/env ruby
# ---------------------------------------------------------------------------
# import_vault.rb — turn the vault's Blog/Published/ folder into Jekyll posts.
#
#   ruby script/import_vault.rb ~/Obsidian\ Vault
#   ruby script/import_vault.rb ~/Obsidian\ Vault --dry-run
#
# Three gates stand between a note and the internet. Each one alone is enough
# to stop a leak:
#
#   1. ALLOWLIST — only PUBLISH_DIR is read. Every other folder in the vault,
#      including the rest of Blog/, is invisible to this script. A new folder
#      is private by default. Moving a note in is a deliberate act.
#   2. publish: true — required, in the note's frontmatter. There is no flag
#      to turn this off, because a flag you can forget is not a gate.
#   3. _posts is GENERATED — anything here that no longer maps to a published
#      note is deleted, so flipping publish back to false unpublishes.
#
# So publishing takes two deliberate acts that are easy to keep straight: the
# note is in Blog/Published/, and its flag is true. Neither alone does anything.
#
# The vault itself is never committed. This script runs on the machine that
# holds the vault; CI only builds what _posts already contains.
# ---------------------------------------------------------------------------
require "yaml"
require "fileutils"
require "date"

VAULT       = File.expand_path(ARGV.find { |a| !a.start_with?("--") } || "~/Obsidian Vault")
DRY_RUN     = ARGV.include?("--dry-run")
ALLOW_EMPTY = ARGV.include?("--allow-empty")

# Gate 1. The only folder in the vault this script is permitted to read.
BLOG_DIR    = "Blog"
PUBLISH_DIR = File.join(BLOG_DIR, "Published")

# Subfolders of PUBLISH_DIR that never publish, whatever the frontmatter says.
# Largely belt and braces now that PUBLISH_DIR is a dedicated folder, but it
# still means a Blog/Published/Drafts/ cannot ship on a stray flag.
# Matched case-insensitively against every directory in the note's path.
NEVER_PUBLISH = %w[Drafts Concepts].freeze

POSTS_DIR = "_posts"
IMG_DIR   = "assets/img"
ROOT      = File.join(VAULT, PUBLISH_DIR)
BLOG_ROOT = File.join(VAULT, BLOG_DIR)

IMAGE_EXT = "png|jpe?g|gif|webp|svg"

abort "vault not found: #{VAULT}" unless Dir.exist?(VAULT)
unless Dir.exist?(ROOT)
  abort <<~MSG
    publish folder not found: #{ROOT}

    Only notes in #{PUBLISH_DIR}/ publish. Create that folder and move the
    notes you want live into it.
  MSG
end

def slugify(str)
  str.to_s.downcase.gsub(/[^a-z0-9\s-]/, "").strip.gsub(/[\s_-]+/, "-")
end

# Returns [meta, body, error]. The error matters: frontmatter that will not
# parse must never be quietly downgraded to "private", because the author who
# ticked the publish box would see nothing happen and no reason why.
def split_frontmatter(raw)
  # Tolerate a UTF-8 BOM and leading blank lines before the opening `---`.
  # Obsidian and several editors leave a stray newline at the top of a file,
  # and that alone used to make the entire frontmatter block invisible.
  text = raw.sub(/\A\xEF\xBB\xBF/, "").sub(/\A(?:[ \t]*\r?\n)+/, "")
  return [{}, raw, nil] unless text.start_with?("---")
  parts = text.split(/^---\s*$/, 3)
  begin
    meta = YAML.safe_load(parts[1], permitted_classes: [Date, Time]) || {}
    meta = {} unless meta.is_a?(Hash)
    [meta, parts[2].to_s.lstrip, nil]
  rescue StandardError => e
    [{}, parts[2].to_s.lstrip, e.message.lines.first.to_s.strip]
  end
end

warnings = []

# --- pass 1: index Blog/ only ----------------------------------------------
# Notes outside PUBLISH_DIR are never opened, so their titles and bodies
# cannot reach the build even by accident.
notes  = {}
broken = []
Dir.glob(File.join(ROOT, "**", "*.md")).sort.each do |path|
  raw = File.read(path)
  meta, body, fm_error = split_frontmatter(raw)

  # Gate 2a. A note under one of NEVER_PUBLISH is private full stop, so the
  # checks below are skipped for it: a broken link in a draft is not shipping
  # anywhere, and aborting the whole run over one would be absurd.
  rel     = path.sub(/\A#{Regexp.escape(ROOT)}#{Regexp.escape(File::SEPARATOR)}?/, "")
  blocked = File.dirname(rel).split(File::SEPARATOR)
                .find { |d| NEVER_PUBLISH.any? { |n| n.casecmp?(d) } }

  # The override is deliberate, so say so rather than let the author wonder why
  # ticking the box did nothing. A warning, not an error — one draft must never
  # be able to block publishing everything else.
  if blocked && meta["publish"] == true
    warnings << "#{File.basename(path)}: in #{blocked}/, which never publishes — " \
                "`publish: true` is being ignored. Move it out of #{blocked}/ to publish it."
  end

  # Intent-to-publish that we cannot honour must never pass silently, whatever
  # the cause: bad YAML, frontmatter in the wrong place, anything. The author
  # ticked the box and would otherwise watch the note be quietly held back.
  if !blocked && raw.match?(/^publish:\s*true\s*$/) && meta["publish"] != true
    broken << "#{File.basename(path)} — " +
              (fm_error || "frontmatter not recognised; the opening `---` must be the first thing in the file")
  elsif fm_error && !blocked
    warnings << "#{File.basename(path)}: unreadable frontmatter (#{fm_error}) — treated as private"
  end

  # `[text][url]` is reference-style link syntax and needs a matching `[url]:`
  # definition. Without one kramdown emits the whole thing verbatim, so a
  # bracketed URL ships to the live site looking like a mistake. It renders,
  # so nothing else catches it — hence a hard stop before it publishes.
  if !blocked && meta["publish"] == true && body.match?(%r{\]\[(?:https?:)?//})
    body.scan(%r{\[[^\]]*\]\[(?:https?:)?//[^\]]*\]}).each do |bad|
      broken << "#{File.basename(path)} — #{bad[0, 60]} should be [text](url), not [text][url]"
    end
  end

  name  = File.basename(path, ".md")
  title = meta["title"] || name

  notes[name.downcase] = {
    path: path, meta: meta, body: body, title: title,
    slug: slugify(meta["slug"] || title),
    # Gate 2. Anything but an explicit true is private, and NEVER_PUBLISH wins
    # over the flag outright.
    published: meta["publish"] == true && blocked.nil?
  }
end

# Notes elsewhere under Blog/ are outside the read scope, so a `publish: true`
# sitting in one would do nothing at all with no explanation — the exact silent
# failure the loud guards above exist to prevent. Only the frontmatter region is
# read here, never the body: this looks for a flag, it does not import anything.
Dir.glob(File.join(BLOG_ROOT, "**", "*.md")).sort.each do |path|
  next if path.start_with?(ROOT + File::SEPARATOR)
  head = File.foreach(path).first(40).join rescue next
  next unless head.match?(/^publish:\s*true\s*$/)
  rel = path.sub(/\A#{Regexp.escape(BLOG_ROOT)}#{Regexp.escape(File::SEPARATOR)}?/, "")
  warnings << "#{rel}: has `publish: true` but is not in #{PUBLISH_DIR}/ — " \
              "move it there to publish it."
end

unless broken.empty?
  abort <<~MSG

    #{broken.length} problem(s) would publish something broken:

    #{broken.map { |b| "  #{b}" }.join("\n")}

    Nothing was imported and nothing was pruned. Common causes:

      * an unquoted colon in a frontmatter value — YAML reads it as a nested key
            description: In 2015 I wanted two things: something   # broken
            description: "In 2015 I wanted two things: something" # fixed

      * frontmatter that is not the very first thing in the file

      * [text][url] instead of [text](url) — reference-style link syntax needs
        a matching [url]: definition, so kramdown ships it as literal text

    Fix the note and re-run.
  MSG
end

published = notes.each_value.select { |n| n[:published] }

# Two notes resolving to one URL would silently clobber each other.
published.group_by { |n| n[:slug] }.each do |slug, group|
  next if group.size == 1
  warnings << "slug collision on #{slug.inspect}: " +
              group.map { |n| File.basename(n[:path]) }.join(", ") + " — skipping all but the first"
  group.drop(1).each { |n| n[:published] = false }
end
published = published.select { |n| n[:published] }

# --- rewriters --------------------------------------------------------------

# Only links to *published* notes become real links. Everything else degrades
# to the label the author already wrote in their prose — no tooltip, no hint
# that a private note exists on the other end.
def rewrite_wikilinks(text, notes)
  text.gsub(/\[\[([^\]|#]+)(?:#[^\]|]+)?(?:\|([^\]]+))?\]\]/) do
    target, alias_text = Regexp.last_match(1).strip, Regexp.last_match(2)
    note  = notes[target.downcase]
    label = alias_text || target
    if note && note[:published]
      %(<a class="wikilink" href="/#{note[:slug]}/">#{label}</a>)
    else
      %(<span class="wikilink-dead">#{label}</span>)
    end
  end
end

def rewrite_callouts(text)
  out, i, lines = [], 0, text.lines
  while i < lines.length
    if (m = lines[i].match(/^>\s*\[!(\w+)\]([+-])?\s*(.*)$/))
      kind, heading = m[1].downcase, m[3].to_s.strip
      i += 1
      buf = []
      while i < lines.length && lines[i].start_with?(">")
        buf << lines[i].sub(/^>\s?/, "")
        i += 1
      end
      icon = { "warning" => "!", "caution" => "!", "danger" => "!", "bug" => "!",
               "tip" => "*", "success" => "+", "quote" => '"' }.fetch(kind, "i")
      out << %(<div class="callout callout-#{kind}">\n)
      out << %(  <div class="callout-title"><span class="ic">#{icon}</span>#{heading.empty? ? kind : heading}</div>\n)
      buf.join.split(/\n{2,}/).each { |para| out << "  <p>#{para.strip.gsub("\n", " ")}</p>\n" }
      out << "</div>\n\n"
    else
      out << lines[i]
      i += 1
    end
  end
  out.join
end

# Attachments are resolved inside PUBLISH_DIR only. The old vault-wide glob
# could pull an image out of Finances/ on a basename match.
def rewrite_embeds(text, root, copied, warnings, note_name)
  text.gsub(/!\[\[([^\]]+?\.(?:#{IMAGE_EXT}))(?:\|([^\]]+))?\]\]/i) do
    file, caption = Regexp.last_match(1), Regexp.last_match(2)
    base = File.basename(file)
    src  = Dir.glob(File.join(root, "**", base), File::FNM_CASEFOLD).first
    if src
      copied << base
      FileUtils.cp(src, File.join(IMG_DIR, base)) unless DRY_RUN
      %(<figure><img src="/assets/img/#{base}" alt="#{caption}">) +
        (caption ? %(<figcaption>#{caption}</figcaption>) : "") + "</figure>"
    else
      warnings << "#{note_name}: image #{base.inspect} not found under #{PUBLISH_DIR}/ — embed dropped"
      ""
    end
  end
end

# True if the note contains TeX. Matches $$…$$ (which kramdown parses) and
# Obsidian's inline $…$ (which it does not) — the lookarounds keep the inline
# pattern from matching one half of a $$ pair.
def has_math?(text)
  text.match?(/\$\$.+?\$\$/m) || text.match?(/(?<!\$)\$(?!\s)[^$\n]+\$(?!\$)/)
end

def rewrite_mermaid(text)
  text.gsub(/^```mermaid\n(.*?)^```$/m) { %(<div class="mermaid">\n#{Regexp.last_match(1)}</div>) }
end

# --- pass 2: write the posts ------------------------------------------------
FileUtils.mkdir_p(POSTS_DIR) unless DRY_RUN
FileUtils.mkdir_p(IMG_DIR)   unless DRY_RUN

written, copied_images = [], []

published.each do |note|
  meta = note[:meta]
  date = meta["date"] || File.mtime(note[:path]).to_date
  date = begin
    date.is_a?(Date) || date.is_a?(Time) ? date : Date.parse(date.to_s)
  rescue ArgumentError
    warnings << "#{File.basename(note[:path])}: unreadable date #{date.inspect} — using file mtime"
    File.mtime(note[:path]).to_date
  end

  body = note[:body]
  body = rewrite_embeds(body, ROOT, copied_images, warnings, File.basename(note[:path]))
  body = rewrite_callouts(body)
  body = rewrite_mermaid(body)
  body = rewrite_wikilinks(body, notes)

  front = {
    "layout"      => "post",
    "title"       => note[:title],
    "date"        => date.strftime("%Y-%m-%d"),
    "kind"        => meta["kind"] || "notes",
    "tags"        => meta["tags"] || [],
    "description" => meta["description"],
    "slug"        => note[:slug],
    "dropcap"     => meta["dropcap"],
    "mermaid"     => body.include?(%(class="mermaid")) || nil,
    "math"        => has_math?(body) || nil
  }
  front = front.reject { |_, v| v.nil? }

  name = "#{date.strftime('%Y-%m-%d')}-#{note[:slug]}.md"
  written << name
  File.write(File.join(POSTS_DIR, name), front.to_yaml + "---\n\n" + body) unless DRY_RUN
  puts "  publish  #{name}"
end

# --- pass 3: prune ----------------------------------------------------------
# Gate 3. _posts and assets/img are generated. Anything no longer backed by a
# published note goes away, so un-setting publish: true actually unpublishes.
existing = Dir.glob(File.join(POSTS_DIR, "*.md")).map { |p| File.basename(p) }
stale    = existing - written

if written.empty? && !stale.empty? && !ALLOW_EMPTY
  abort <<~MSG
    refusing to prune #{stale.length} post(s): no published notes found in #{ROOT}

    This usually means the vault path is wrong or no note has `publish: true`.
    If you really meant to unpublish everything, re-run with --allow-empty.
  MSG
end

stale.each do |name|
  puts "  remove   #{name}"
  File.delete(File.join(POSTS_DIR, name)) unless DRY_RUN
end

stale_images = Dir.glob(File.join(IMG_DIR, "*")).map { |p| File.basename(p) } - copied_images
stale_images.each do |name|
  puts "  remove   #{IMG_DIR}/#{name}"
  File.delete(File.join(IMG_DIR, name)) unless DRY_RUN
end

# --- report -----------------------------------------------------------------
unless warnings.empty?
  puts
  warnings.each { |w| warn "  warning: #{w}" }
end

puts
puts "#{DRY_RUN ? '[dry run] ' : ''}#{written.length} published, " \
     "#{stale.length + stale_images.length} removed, " \
     "#{notes.length - published.length} note(s) held back in #{PUBLISH_DIR}/"
