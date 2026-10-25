#!/bin/bash
# Installs the vertical-video editing toolchain (Video-Use, HyperFrames,
# Remotion skills, yt-dlp) in Claude Code cloud sessions.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

VU="$HOME/Developer/video-use"

# Installer progress bars are huge and end up in Claude's context; log them instead
LOG="$HOME/.cache/session-start.log"
mkdir -p "$(dirname "$LOG")"
exec 3>&1 >>"$LOG" 2>&1
trap 'echo "Video toolchain setup failed; see $LOG" >&3' ERR

# Video-Use (official install.md)
if [ -d "$VU/.git" ]; then
  git -C "$VU" pull --ff-only || true
else
  mkdir -p "$HOME/Developer"
  git clone https://github.com/browser-use/video-use "$VU"
fi
(cd "$VU" && uv sync)
mkdir -p "$HOME/.claude/skills"
ln -sfn "$VU" "$HOME/.claude/skills/video-use"

# ElevenLabs key: taken from the environment variable if the user set one
if [ -n "${ELEVENLABS_API_KEY:-}" ]; then
  printf 'ELEVENLABS_API_KEY=%s\n' "$ELEVENLABS_API_KEY" > "$VU/.env"
  chmod 600 "$VU/.env"
fi

# yt-dlp
command -v yt-dlp >/dev/null || pip install -q --break-system-packages yt-dlp || pip install -q yt-dlp

# HyperFrames skills + headless Chrome
npx --yes hyperframes skills update
npx --yes hyperframes browser ensure

# Remotion skills
npx --yes skills add remotion-dev/skills -g -y -a claude-code || true

# Remotion can't download its own Chrome here (remotion.media is blocked),
# so point it at the one HyperFrames installed.
CHROME=$(ls "$HOME"/.cache/hyperframes/chrome/chrome-headless-shell/*/chrome-headless-shell-linux64/chrome-headless-shell 2>/dev/null | tail -1 || true)
if [ -n "$CHROME" ] && [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  echo "export REMOTION_CHROME=\"$CHROME\"" >> "$CLAUDE_ENV_FILE"
fi

echo "Video toolchain ready (log: $LOG)" >&3
