# Reyna on Claw

Claw (`claw.tailca933d.ts.net`, Ubuntu 24.04, no GPU) is her always-on home. This folder is
the whole deployment: one systemd user unit, one reset script, this page. Secrets live only
in `~/reyna-yurios/.env` on Claw.

## Status

See the bottom of this page for what was verified on the last deploy.

## First deploy

```bash
ssh dodontommy@claw
cd ~/reyna-yurios
git fetch origin && git checkout -B reyna/foundation origin/reyna/foundation
.venv/bin/pip install -e ".[dev]"
cp .env.example .env            # then set the keys below
cp deploy/claw/reyna-yurios.service ~/.config/systemd/user/
systemctl --user daemon-reload && systemctl --user enable --now reyna-yurios
deploy/claw/reset-reyna.sh reyna data/cards/reyna.png     # import + approve (+ start)
```

`.env` keys that differ from the example:

| key | value |
|---|---|
| `CHAT_MODEL` / `UTILITY_MODEL` | `openrouter/deepseek/deepseek-v4.1-flash` |
| `CHAT_THINKING` / `UTILITY_THINKING` | `false` |
| `OPENROUTER_API_KEY` | the key |
| `OWNER_TOKEN` | 32+ random chars; every non-loopback request needs it (`Authorization: Bearer …`, or the `/auth` page once in a browser) |
| `HOST` | `0.0.0.0` (LAN and Tailscale, token-gated; loopback is open) |
| `USER_NAME` | `Tommy` |
| `STT_BACKEND` / `TTS_BACKEND` / `VAD_BACKEND` | `fake` until the voice stack is installed |
| `MIND_TOOLS_ENABLED` | `true`, with `MIND_TOOL_ALLOWLIST=write_note,append_note,read_note,list_notes` |
| `LOREBOOK_BUDGET_TOKENS` | `900` (her lore entries are short but there are ten) |
| `SEARCH_BACKEND` / `SELFIE_BACKEND` | `off` |

The card itself (`data/cards/reyna.png`) is private and is not in git; copy it over with `scp`.

## Redeploy

```bash
ssh dodontommy@claw 'cd ~/reyna-yurios && git pull --ff-only && systemctl --user restart reyna-yurios'
```

## Reset (after a tone or personality change)

`deploy/claw/reset-reyna.sh` purges her learned state through the switchboard's own two-step,
re-imports the card and approves it. Authored card, `.env` and Telegram pairing survive.

## Telegram

Make a bot with @BotFather, paste its token as `TELEGRAM_BOT_TOKEN` in `.env` (or in the gear
panel in her room), restart, message the bot once, put the id it answers with in
`TELEGRAM_CHAT_ID`, restart again. Her replies with blank lines arrive as separate messages.

## Voice

Kokoro needs the system package: `sudo apt install espeak-ng`, then
`.venv/bin/pip install -e ".[voice]"` and set the three voice backends in `.env` back to
`faster_whisper` / `kokoro` / `silero`. CPU-only; Claw's six cores are enough.

## Useful

```bash
systemctl --user status reyna-yurios
journalctl --user -u reyna-yurios -f
curl -s http://127.0.0.1:8768/api/health | python3 -m json.tool
```

Her assembled prompts, tick traces and tool calls are on the mind debug page (the last icon
on her switchboard tile) and on disk under `data/characters/reyna/`.
