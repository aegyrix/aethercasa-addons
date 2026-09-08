# ÆtherCasa Bridge

Connects your Home Assistant to [ÆtherCasa](https://aethercasa.app).

## How it works

The bridge opens an outbound secure WebSocket from your HA instance to
`api.aethercasa.app`. It streams entity state up, and forwards commands
(service calls) back down to HA. No inbound ports are opened. Your long-lived
token never leaves the add-on — the add-on uses Supervisor's auto-injected
token to talk to HA over the internal API.

## Setup

1. Install this add-on and click **Start**.
2. Open the **Log** tab. The add-on will print something like:

   ```
   ┌──────────────────────────────────────────────────────────────┐
   │  Connect this bridge to AetherCasa                           │
   │                                                              │
   │  1. Open:                                                    │
   │     https://app.aethercasa.app/activate?user_code=KN4J-9XP7  │
   │                                                              │
   │  2. Enter code:  KN4J-9XP7                                   │
   │                                                              │
   │  Code expires in 15 minutes.                                 │
   └──────────────────────────────────────────────────────────────┘
   ```

3. Open that URL on any device — phone, laptop, anything signed in to
   your ÆtherCasa account. Confirm the code matches what's shown in the
   logs, pick which home this bridge belongs to, and click **Approve**.
4. The add-on finishes pairing on its own within a few seconds.

That's it. No copy-pasting codes between apps, no long-lived token,
no config tab to fill in. The add-on persists its identity to
`/data/bridge.json` and won't ask again on restart.

### Legacy pairing (optional)

If you prefer the old code-based flow, create a bridge in the web app
(**Settings → Homes → Bridges → Add bridge**), copy the 6-digit code,
and paste it into this add-on's `pairing_code` option. Save, then Start.
Clear the field after first successful pair.

## Re-pairing

If you ever need to re-pair (e.g. you deleted the bridge in the ÆtherCasa web
app), stop the add-on, delete `/data/bridge.json` via the Supervisor file
editor, and start the add-on again. A fresh activation code will appear in the
logs.

## Options

| Key            | Default                      | Description                                  |
| -------------- | ---------------------------- | -------------------------------------------- |
| `pairing_code` | _(blank)_                    | 6-digit code from ÆtherCasa; first-boot only |
| `cloud_url`    | `https://api.aethercasa.app` | ÆtherCasa cloud endpoint                     |
| `log_level`    | `info`                       | `debug`, `info`, `warn`, `error`             |

## Privacy

- No HA long-lived token is requested; the add-on uses the supervisor-issued
  token which is scoped to this add-on and auto-rotated.
- Entity state (attributes, last_changed, etc.) is forwarded to your
  ÆtherCasa home. No raw HA credentials or integrations config ever leave
  your network.

## Troubleshooting

- **"No bridge identity yet"** — you started the add-on without a pairing
  code. Set it in Configuration, Save, then Start.
- **Bridge shows offline in the web app** — check the add-on logs for
  connection errors. Outbound HTTPS/WSS to `api.aethercasa.app:443` must be
  allowed.
