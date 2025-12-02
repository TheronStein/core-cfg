#!/usr/bin/env bash
set -euo pipefail

path=&quot;${1:?Provide a path to preview}&quot;

if [[ ! -e &quot;$path&quot; ]]; then
  exit 0
fi

case &quot;$path&quot; in
  (*.png|*.jpg|*.jpeg|*.gif|*.bmp|*.svg|*.webp)
    if command -v chafa &gt;/dev/null; then
      chafa --size=80x20 &quot;$path&quot;
    elif command -v kitty +kitten icat &gt;/dev/null; then
      kitty +kitten icat --align left &quot;$path&quot;
    else
      file &quot;$path&quot;
    fi
    ;;
  (*.pdf)
    if command -v pdftoppm &gt;/dev/null; then
      pdftoppm -png -f 1 -l 1 -scale-to 800 -scale-to 600 &quot;$path&quot; - | chafa --size=80x20 -
    else
      file &quot;$path&quot;
    fi
    ;;
  (*.tar.gz|*.tar.bz2|*.tar.xz|*.zip|*.rar|*.7z|*.gz|*.bz2|*.xz)
    if command -v atool &gt;/dev/null; then
      atool -l &quot;$path&quot; | head -20
    elif command -v tar &gt;/dev/null; then
      tar -tf &quot;$path&quot; | head -20
    else
      file &quot;$path&quot;
    fi
    ;;
  (*.mp4|*.avi|*.mkv|*.mp3|*.wav|*.flac|*.ogg)
    ffprobe &quot;$path&quot; 2&gt;&amp;1 | head -10 || file &quot;$path&quot;
    ;;
  */)
    if [[ -d &quot;$path&quot; ]]; then
      if command -v eza &gt;/dev/null; then
        eza --tree --color=always --icons -L 3 --group-directories-first &quot;$path&quot; 2&gt;/dev/null || ls -laFGh --color=always &quot;$path&quot;
      else
        ls -laFGh --color=always &quot;$path&quot;
      fi | head -200
    else
      file &quot;$path&quot;
    fi
    ;;
  *)
    if [[ -f &quot;$path&quot; ]]; then
      if command -v bat &gt;/dev/null; then
        bat --color=always --style=full --decorations=always --line-range=:200 &quot;$path&quot;
      elif command -v highlight &gt;/dev/null; then
        highlight --out-format=ansi &quot;$path&quot; | head -200
      else
        head -200 &quot;$path&quot; | nl -b a | tail -100
      fi
    else
      file &quot;$path&quot;
    fi
    ;;
esac