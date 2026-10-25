# Vertical video editing (TikTok / Reels / Shorts)

## Output defaults
- 9:16, **1080×1920**, 30 fps, H.264 (`yuv420p`) + AAC, MP4.
- Keep text and faces inside the safe zone: roughly 150 px clear at the top, 350 px at the bottom (captions/UI), 120 px on the right (buttons).
- Put raw footage in `videos/<project>/`; outputs go in `videos/<project>/edit/` (git-ignored).

## Tools
- **Video-Use** (skill `video-use`): cutting, grading, subtitles from talking-head footage. Repo at `~/Developer/video-use`. Transcription needs `ELEVENLABS_API_KEY`.
- **HyperFrames** (skills `hyperframes*`): HTML-based animations, titles, captions. Start projects with `npx hyperframes init <name> --resolution portrait --non-interactive`.
- **Remotion** (skills `remotion-*`): React-based animations. Render with `--width=1080 --height=1920 --browser-executable="$REMOTION_CHROME"`.
- **yt-dlp**: download reference videos.
- **FFmpeg / FFprobe**: final encode and checks.

## Network quirks in cloud sessions
- `cdn.jsdelivr.net` may be blocked: if a HyperFrames render fails loading GSAP, `npm i gsap`, copy `node_modules/gsap/dist/gsap.min.js` into the project and point the `<script>` at the local copy.
- `remotion.media` is blocked: always pass `--browser-executable="$REMOTION_CHROME"`.
- YouTube may be blocked for yt-dlp unless the environment allows it.

## Before handing over a video
Verify with `ffprobe` that it is 1080×1920 and has audio.
