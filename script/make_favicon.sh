#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# make_favicon.sh — bake the site favicon from a font glyph.
#
#   script/make_favicon.sh
#   LETTER=Y ACCENT='#7aa2f7' BG='#1a1b26' script/make_favicon.sh
#
# Why PNG rather than an SVG with <text> in it: an SVG favicon cannot fetch a
# webfont, so it would fall back to whatever monospace the visitor happens to
# have and the letterform would differ per platform. Chrome *can* fetch the
# font, so we render once here and ship pixels that look the same everywhere.
#
# Needs Google Chrome and a network connection (for the webfont). No
# ImageMagick, no locally installed font, no Photoshop.
#
# One trap worth knowing: Chrome clamps the layout viewport to ~490px, so
# `--window-size=32,32` lays the page out at 490px and then captures the
# top-left 32x32 — which is empty. The tile is therefore pinned at 0,0 with an
# exact pixel size, and everything is sized in px rather than vmin.
# ---------------------------------------------------------------------------
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$REPO/assets"

LETTER="${LETTER:-R}"
ACCENT="${ACCENT:-#fabd2f}"   # gruvbox --accent
BG="${BG:-#282828}"           # gruvbox --bg
FONT="${FONT:-JetBrains Mono}"
WEIGHT="${WEIGHT:-800}"

# Ratios of the tile size, tuned for JetBrains Mono ExtraBold "R": ~77% height
# fill, optically centred (its side bearings are asymmetric and it sits high in
# the em box). Change LETTER or FONT and the check below will tell you if the
# centring drifted.
FONT_RATIO="${FONT_RATIO:-1.06}"
SHIFT_X_RATIO="${SHIFT_X_RATIO:--0.016}"
SHIFT_Y_RATIO="${SHIFT_Y_RATIO:-0.009}"

CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
[ -x "$CHROME" ] || { echo "Chrome not found at: $CHROME (set CHROME=)" >&2; exit 1; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "baking '${LETTER}' in ${FONT} ${WEIGHT}, ${ACCENT} on ${BG}"

render() { # $1 = pixel size, $2 = output path
  python3 - "$1" "$LETTER" "$ACCENT" "$BG" "$FONT" "$WEIGHT" \
      "$FONT_RATIO" "$SHIFT_X_RATIO" "$SHIFT_Y_RATIO" > "$TMP/tile.html" <<'PY'
import sys
size, letter, accent, bg, font, weight, fr, sx, sy = sys.argv[1:10]
S = int(size)
fs = round(float(fr) * S, 3)
tx = round(float(sx) * S, 3)
ty = round(float(sy) * S, 3)
fam = font.replace(" ", "+")
print(f'''<!doctype html><html><head><meta charset="utf-8">
<link href="https://fonts.googleapis.com/css2?family={fam}:wght@{weight}&display=block" rel="stylesheet">
<style>
 html,body{{margin:0;padding:0;background:#000}}
 #t{{position:absolute;top:0;left:0;width:{S}px;height:{S}px;background:{bg};
     overflow:hidden;display:flex;align-items:center;justify-content:center}}
 #t span{{font-family:"{font}",monospace;font-weight:{weight};color:{accent};
     font-size:{fs}px;line-height:1;transform:translate({tx}px,{ty}px)}}
</style></head><body><div id="t"><span>{letter}</span></div></body></html>''')
PY
  "$CHROME" --headless --disable-gpu --no-sandbox --hide-scrollbars \
    --window-size="$1,$1" --virtual-time-budget=8000 \
    --screenshot="$2" "file://$TMP/tile.html" 2>/dev/null
}

render 32  "$OUT/favicon-32.png"
render 180 "$OUT/apple-touch-icon.png"
render 512 "$OUT/favicon-512.png"

# Verify EVERY size, not just the biggest. A blank 32px tile shipped once
# because only the 512 was checked: the failure mode is size-specific.
python3 - "$BG" "$OUT/favicon-32.png" "$OUT/apple-touch-icon.png" "$OUT/favicon-512.png" <<'PY'
import struct, sys, zlib
bg = sys.argv[1].lstrip('#')
BR, BG_, BB = (int(bg[i:i+2], 16) for i in (0, 2, 4))

def stats(path):
    d = open(path, 'rb').read(); pos, idat = 8, b''
    while pos < len(d):
        ln = struct.unpack('>I', d[pos:pos+4])[0]; typ = d[pos+4:pos+8]
        if typ == b'IHDR': w, h = struct.unpack('>II', d[pos+8:pos+16])
        elif typ == b'IDAT': idat += d[pos+8:pos+8+ln]
        pos += 12 + ln
    raw = zlib.decompress(idat); stride = w*3
    prev = bytearray(stride); off = 0; ink = 0
    minx, maxx, miny, maxy = w, 0, h, 0
    for y in range(h):
        ft = raw[off]; off += 1
        line = bytearray(raw[off:off+stride]); off += stride
        if ft == 1:
            for i in range(3, stride): line[i] = (line[i]+line[i-3]) & 255
        elif ft == 2:
            for i in range(stride): line[i] = (line[i]+prev[i]) & 255
        elif ft == 3:
            for i in range(stride):
                a = line[i-3] if i >= 3 else 0
                line[i] = (line[i]+((a+prev[i]) >> 1)) & 255
        elif ft == 4:
            for i in range(stride):
                a = line[i-3] if i >= 3 else 0; b = prev[i]; c = prev[i-3] if i >= 3 else 0
                pa, pb, pc = abs(b-c), abs(a-c), abs(a+b-2*c)
                pr = a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)
                line[i] = (line[i]+pr) & 255
        for x in range(w):
            if (abs(line[x*3]-BR) > 24 or abs(line[x*3+1]-BG_) > 24 or abs(line[x*3+2]-BB) > 24):
                ink += 1
                minx = min(minx, x); maxx = max(maxx, x)
                miny = min(miny, y); maxy = max(maxy, y)
        prev = line
    return w, h, ink, minx, maxx, miny, maxy

bad = False
for p in sys.argv[2:]:
    w, h, ink, x0, x1, y0, y1 = stats(p)
    name = p.rsplit('/', 1)[-1]
    if ink == 0:
        print(f"  FAIL {name}: tile is blank — webfont did not load, or the "
              f"glyph fell outside the captured region"); bad = True; continue
    if x0 == 0 or y0 == 0 or x1 == w-1 or y1 == h-1:
        print(f"  FAIL {name}: glyph clipped — lower FONT_RATIO"); bad = True; continue
    print(f"  ok   {name}: {w}x{h}, glyph {x1-x0+1}x{y1-y0+1} "
          f"({100*(y1-y0+1)//h}% tall, {100*ink//(w*h)}% ink), "
          f"centre off h{abs(x0-(w-1-x1))} v{abs(y0-(h-1-y1))}")
sys.exit(1 if bad else 0)
PY
