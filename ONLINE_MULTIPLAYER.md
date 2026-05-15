# Bano ke Online Multiplayer Setup

This setup lets players on different networks play together. The phones do not connect directly to each other. Every phone connects to one public WebSocket server.

## 1. Get A Public Server

Use a VPS/cloud server with:

- Ubuntu Linux
- Public IPv4 address
- At least 1 CPU and 1 GB RAM
- TCP ports `3000`, `80`, and `443` allowed in the provider firewall

For quick testing you can use:

```text
ws://YOUR_SERVER_PUBLIC_IP:3000
```

For a real phone release, use:

```text
wss://your-domain.com
```

## 2. Install Node.js On The Server

SSH into the VPS, then install Node.js:

```bash
sudo apt update
sudo apt install -y nodejs npm
node -v
npm -v
```

Node.js `18` or newer is required.

## 3. Upload The Server Folder

Upload this project folder to the VPS:

```text
multiplayer_server
```

The folder must contain:

```text
server.js
roomManager.js
utils.js
package.json
```

Example server path:

```text
/home/ubuntu/bano-ke/multiplayer_server
```

## 4. Install Server Dependencies

On the VPS:

```bash
cd /home/ubuntu/bano-ke/multiplayer_server
npm install
```

## 5. Start The Server

For a quick test:

```bash
npm start
```

You should see:

```text
WebSocket multiplayer server running on ws://0.0.0.0:3000
```

## 6. Open The Firewall

On the VPS:

```bash
sudo ufw allow 3000/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

Also make sure your cloud/VPS provider firewall allows TCP `3000`.

## 7. Test From Your Phone

In the game:

```text
Settings > Online Server URL
```

Use:

```text
ws://YOUR_SERVER_PUBLIC_IP:3000
```

Then:

1. Phone 1 opens the game.
2. Tap `ONLINE`.
3. Pick a `2`, `3`, `4`, or `5` player always-open room.
4. Phone 2 opens the game on another network.
5. Set the same server URL.
6. Tap `ONLINE`.
7. Join the same open room size, or join a private room by code.
8. The host taps `START GAME`, or the open room starts when full.

The server keeps one open public room available for every player size. When a public room fills and starts, the server creates another open room automatically.

## 8. Keep The Server Running 24/7

Create a systemd service:

```bash
sudo nano /etc/systemd/system/bano-ke-multiplayer.service
```

Paste this:

```ini
[Unit]
Description=Bano ke Multiplayer Server
After=network.target

[Service]
WorkingDirectory=/home/ubuntu/bano-ke/multiplayer_server
ExecStart=/usr/bin/node server.js
Restart=always
RestartSec=3
Environment=PORT=3000

[Install]
WantedBy=multi-user.target
```

Enable it:

```bash
sudo systemctl daemon-reload
sudo systemctl enable bano-ke-multiplayer
sudo systemctl start bano-ke-multiplayer
sudo systemctl status bano-ke-multiplayer
```

View logs:

```bash
journalctl -u bano-ke-multiplayer -f
```

## 9. Render Deployment

Render works well for testing because the server already uses:

```js
process.env.PORT
```

Render setup:

1. Push this project to GitHub.
2. In Render, create a `Web Service`.
3. Connect the GitHub repo.
4. Set the root directory to:

```text
multiplayer_server
```

5. Set the build command:

```text
npm install
```

6. Set the start command:

```text
npm start
```

7. Deploy.
8. Copy the Render URL. It should look like:

```text
https://your-app-name.onrender.com
```

9. In the game, set:

```text
wss://your-app-name.onrender.com
```

Important: use `wss://`, not `https://`, inside the game.

## 10. Production Setup With Domain And WSS

Point your domain DNS `A` record to the VPS public IP.

Install Nginx and Certbot:

```bash
sudo apt install -y nginx certbot python3-certbot-nginx
```

Create an Nginx site:

```bash
sudo nano /etc/nginx/sites-available/bano-ke-multiplayer
```

Paste this, replacing `your-domain.com`:

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_read_timeout 3600;
    }
}
```

Enable it:

```bash
sudo ln -s /etc/nginx/sites-available/bano-ke-multiplayer /etc/nginx/sites-enabled/bano-ke-multiplayer
sudo nginx -t
sudo systemctl reload nginx
```

Add SSL:

```bash
sudo certbot --nginx -d your-domain.com
```

Then set the game URL to:

```text
wss://your-domain.com
```

## 11. Important Notes

- `127.0.0.1` only means the current device. It will not work for phones on different networks.
- The server must be public and always running.
- Use `ws://PUBLIC_IP:3000` for quick tests.
- Use `wss://your-domain.com` for production.
- Every player must use the same Online Server URL.
- Android exports must have the `Internet` permission enabled.
