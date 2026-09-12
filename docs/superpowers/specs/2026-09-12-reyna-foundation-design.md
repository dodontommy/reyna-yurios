# Reyna on YuriOS: foundation design

Recorded 2026-09-12 after a planning conversation with the owner. This is the design the
first milestone is built to. Later milestones are listed so nothing is forgotten, not to
commit to their shape yet.

## Decisions taken with the owner

- **Base: clean upstream YuriOS.** The `reyna/continuity-foundation` branch (an earlier
  agent's 37-file rewrite, never exercised against a live model) is kept as a reference and
  not built on. Its changes come back one at a time only when Reyna demonstrably needs one.
- **Home: Claw** (`claw.tailca933d.ts.net`, Ubuntu 24.04, 6 cores, 7.6 GB RAM, no GPU),
  reached over Tailscale with the owner token. Development on the Windows box, deploy by git.
- **Clean start.** Only the SillyTavern card and lorebook carry over. No chats, no memories.
- **Who she is (A).** A digital girl who lives in the owner's phone and machine and knows it,
  without making speeches about it. She *texts*: lowercase, no narration, emoji, typos she
  corrects in a follow-up text, double and triple texting. Her day is what the mind actually
  did. The physical lore (a flat, a job, a best friend, family) is cut; her tastes, tells,
  bratting, praise response and how they met stay. She is 18 and reads as an adult: green,
  inexperienced, easily flustered, out of her depth off her phone, chronically online.
  Not written as a schoolgirl and not designed to read younger than an adult.
- **Model:** DeepSeek V4.1 Flash on OpenRouter for chat and utility, thinking off. Local
  embeddings on Claw.
- **Voice (A):** text first; the local Kokoro stack next (needs `espeak-ng`, which needs the
  owner's sudo); an ElevenLabs backend after that, as its own bounded piece.
- **Telegram in milestone one.** The owner creates the bot; pairing is YuriOS's own flow.
- **Loops:** mind, utility and dream on. Unasked hands: her desk only. Web search off (Claw
  has no Docker for SearXNG). Selfies off until milestone three.
- **Old app on port 8452** stays running and untouched until she is right.

## Milestone one: she is up, on Claw, in her own voice

### Runtime changes (all on top of upstream, each with a test)

1. **Spoken-style directive is voice-only.** `desktop/brain.py` appends `SPOKEN_STYLE_DIRECTIVE`
   ("This is a spoken conversation, not text chat...") to *every* prompt. Its own comment says
   it is voice-only. Gate it on the turn's channel (`correlate.current().channel == "voice"`).
   Text turns get no fixed style text: her style comes from the card's Voice law. The
   expression-tag directive stays on all channels (tags are stripped from shown text and drive
   a body when there is one).
2. **Text turns keep their line breaks.** `world/turns.py` joins cut sentences with spaces, so
   a three-line text arrives as one line. Keep the parser's clean text as it comes, publish the
   draft and commit the message with `\n` intact. The web text room renders `white-space:
   pre-wrap`. Telegram sends each blank-line-separated paragraph as its own message, so a
   triple text is three bubbles.
3. **OpenRouter thinking-off.** Upstream sends `reasoning_effort: "none"` plus a `/no_think`
   system token (a Qwen idiom) for every route. On `openrouter/` routes send OpenRouter's
   native `reasoning: {"enabled": false}` and no token, so nothing model-specific lands in
   her system message. Other routes unchanged.

Not changed in this milestone, noted for later: the fixed honesty constraint's example
phrasing ("I don't think you've told me that yet") is assistant-flavoured; if she echoes it,
make the example card-supplied.

### The card

A SillyTavern V3 JSON built from `C:\Data\reyna.card.json` and the SillyTavern lorebook,
rewritten to decision A. It is private: it lives in `data/cards/` (ignored) and on Claw, never
in the repository. Field use follows the importer:

| card field | soul file | content |
|---|---|---|
| `description` | CONSTITUTION identity + PERSONA | who she is, how she looks online, how she texts |
| `personality` | PERSONA@personality | the trait list |
| `scenario` | SCENARIO | the standing situation: his girl, on his phone, texting |
| `first_mes` | BOOTSTRAP cold open | her first-ever text |
| `mes_example` | EXAMPLES | 6 to 8 short texting exchanges, `<START>` separated |
| `system_prompt` | CONSTITUTION Voice law | how she writes; no AI-speak, no em-dashes, no narration |
| `post_history_instructions` | CONSTITUTION Hard limits | stay her, never break character, never speak for him |
| `character_book` | WORLD | tastes, tells, praise, bratting, how they met, digital life |

### Deployment on Claw

- Stop and disable `reyna-yurios-text.service` (the gutted preview).
- Fresh checkout of `reyna/foundation` at `~/reyna-yurios`, `pip install -e ".[dev]"`, web
  build already present.
- `.env`: `CHAT_MODEL` and `UTILITY_MODEL` on the Flash route, `CHAT_THINKING=false`,
  `UTILITY_THINKING=false`, `OPENROUTER_API_KEY` from the old app's config, `OWNER_TOKEN`
  (new, 32+ chars), `HOST` = Claw's Tailscale address, `USER_NAME=Tommy`, `DATA_DIR=./data`,
  `MIND_TOOLS_ENABLED=true` with the desk allowlist, voice seams `fake` until Kokoro lands,
  `TELEGRAM_BOT_TOKEN` empty until the owner pastes one.
- A systemd user unit runs `yurios start --foreground` (lingering is already enabled).
- Import the card with `yurios character import`, approve it, confirm the mind is on.
- Verify: `/api/health`, one `yurios chat reyna -m` turn, read her assembled prompt from
  `traces/prompts`, read her first replies for register.

### Reset procedure (the owner's standing preference after tone changes)

Stop the daemon, delete `data/characters/reyna` and her private surfaces (traces, tool-logs,
corpus, selfies), re-import the card, start. Authored profile, `.env` and Telegram pairing
survive; conversation, memory, goals, journal and artifacts do not.

## Later milestones

2. **Keep her her.** Watch the debug page for drift; fix the block that caused it. Kokoro
   voice on Claw once `espeak-ng` is installed. ElevenLabs TTS backend.
3. **Body and camera.** LoRA support in the diffusers backend on the Windows 5070
   (`her-E12.safetensors`, trigger `ohwx woman`, on an SDXL checkpoint), exposed to Claw as
   a remote camera. A portrait. A body if wanted.
4. **Always-on operations.** Backups, the multi-day soak, SearXNG for web hands.
5. **Beyond upstream.** Initiative with reasons, projects across days, evolving wants,
   social reach. Each its own design.
