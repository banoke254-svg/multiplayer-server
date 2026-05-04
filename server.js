const WebSocket = require("ws");

const PORT = process.env.PORT || 3000;

const wss = new WebSocket.Server({ port: PORT });

let rooms = {};

function generateRoomCode() {
    return Math.random().toString(36).substring(2, 7).toUpperCase();
}

wss.on("connection", (ws) => {
    ws.id = Math.random().toString(36).substring(2, 9);
    console.log("Player connected:", ws.id);

    ws.on("message", (message) => {
        let data;
        try {
            data = JSON.parse(message);
        } catch {
            return;
        }

        if (data.type === "create_room") {
            const code = generateRoomCode();
            rooms[code] = {
                players: [ws],
                max_players: data.max_players || 5
            };
            ws.room = code;

            ws.send(JSON.stringify({
                type: "room_created",
                code: code
            }));
        }

        if (data.type === "join_room") {
            const room = rooms[data.code];
            if (!room) return;

            room.players.push(ws);
            ws.room = data.code;

            room.players.forEach(p => {
                p.send(JSON.stringify({
                    type: "room_update",
                    count: room.players.length
                }));
            });
        }
    });

    ws.on("close", () => {
        console.log("Player disconnected:", ws.id);
    });
});

console.log("Server running on port", PORT);
