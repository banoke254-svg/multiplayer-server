# What CODM-Style Online Multiplayer Needs

The APK cannot host CODM-style online play by itself. Phones should connect outward to a public server.

This project now has the starter version:

- Public open rooms for 2, 3, 4, or 5 human players.
- Private rooms with 5-character codes.
- AI fill so every match has 5 marbles total.
- Node.js WebSocket backend in `multiplayer_server`.
- Client setting: `Settings > Online Server URL`.
- Host-authoritative match sync through room `game_message` relays.

## Minimum Working Setup

1. Deploy the `multiplayer_server` folder on a computer/VPS that both phones can reach.
2. Open TCP port `3000` on that server.
3. Install and start the server:

```bash
npm install
npm start
```

4. Put the server URL into the phone app Settings:

```text
ws://YOUR_SERVER_IP:3000
```

For production, put the server behind HTTPS/TLS and use:

```text
wss://your-domain.com
```

## Production Pieces Still Needed For A Full CODM-Like System

- Dedicated always-on hosting.
- TLS/domain for `wss://`.
- Accounts, reconnects, bans, and basic anti-cheat.
- Server-authoritative physics if you want stronger fairness.
- Monitoring/logs so crashes and disconnects can be diagnosed.

The current server is a real cross-network room backend, but not a full CODM-scale platform yet.
