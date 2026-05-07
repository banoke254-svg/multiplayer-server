const WebSocket = require("ws");

const PORT = process.env.PORT || 3000;

const wss = new WebSocket.Server({ port: PORT });

console.log("Server running on port", PORT);

let rooms = {};


// ========================================
// ROOM CODE
// ========================================

function generateRoomCode() {
    return Math.random().toString(36).substring(2, 7).toUpperCase();
}


// ========================================
// ROOM DATA
// ========================================

function buildRoomData(room) {

    return {
        code: room.code,
        players: room.players.map(p => p.id),
        max_players: room.max_players,
        ai_count: room.max_players - room.players.length
    };
}


// ========================================
// SEND TO ROOM
// ========================================

function sendRoomUpdate(room) {

    const roomData = buildRoomData(room);

    room.players.forEach(player => {

        if (player.readyState === WebSocket.OPEN) {

            player.send(JSON.stringify({
                type: "room_update",
                room: roomData
            }));
        }
    });
}


// ========================================
// CONNECTION
// ========================================

wss.on("connection", (ws) => {

    ws.id = Math.random().toString(36).substring(2, 9);

    console.log("PLAYER CONNECTED:", ws.id);

    // tell client connected
    ws.send(JSON.stringify({
        type: "connected",
        client_id: ws.id
    }));


    // ====================================
    // MESSAGE
    // ====================================

    ws.on("message", (message) => {

        let data;

        try {
            data = JSON.parse(message.toString());
        }
        catch (err) {
            console.log("Invalid JSON");
            return;
        }

        console.log("MESSAGE:", data);


        // ====================================
        // PUBLIC MATCH
        // ====================================

        if (data.type === "public_match") {

            let foundRoom = null;

            // find existing room
            for (const code in rooms) {

                const room = rooms[code];

                if (room.players.length < room.max_players) {
                    foundRoom = room;
                    break;
                }
            }

            // create room if none exists
            if (!foundRoom) {

                const code = generateRoomCode();

                foundRoom = {
                    code: code,
                    players: [],
                    max_players: data.max_players || 5,
                    host: ws.id
                };

                rooms[code] = foundRoom;

                console.log("NEW PUBLIC ROOM:", code);
            }

            foundRoom.players.push(ws);

            ws.room = foundRoom.code;

            // send room joined
            ws.send(JSON.stringify({
                type: "room_joined",
                room: buildRoomData(foundRoom)
            }));

            // update everyone
            sendRoomUpdate(foundRoom);
        }


        // ====================================
        // CREATE PRIVATE ROOM
        // ====================================

        if (data.type === "create_room") {

            const code = generateRoomCode();

            const room = {
                code: code,
                players: [ws],
                max_players: data.max_players || 5,
                host: ws.id
            };

            rooms[code] = room;

            ws.room = code;

            ws.send(JSON.stringify({
                type: "room_created",
                code: code,
                room: buildRoomData(room)
            }));

            console.log("PRIVATE ROOM CREATED:", code);
        }


        // ====================================
        // JOIN PRIVATE ROOM
        // ====================================

        if (data.type === "join_room") {

            const code = data.code;

            const room = rooms[code];

            if (!room) {

                ws.send(JSON.stringify({
                    type: "error",
                    message: "Room not found"
                }));

                return;
            }

            if (room.players.length >= room.max_players) {

                ws.send(JSON.stringify({
                    type: "error",
                    message: "Room full"
                }));

                return;
            }

            room.players.push(ws);

            ws.room = code;

            ws.send(JSON.stringify({
                type: "room_joined",
                room: buildRoomData(room)
            }));

            sendRoomUpdate(room);

            console.log("PLAYER JOINED ROOM:", code);
        }


        // ====================================
        // START MATCH
        // ====================================

        if (data.type === "start_match") {

            const room = rooms[ws.room];

            if (!room) return;

            room.players.forEach(player => {

                player.send(JSON.stringify({
                    type: "start_match",
                    room: buildRoomData(room)
                }));
            });

            console.log("MATCH STARTED:", room.code);
        }

    });


    // ====================================
    // DISCONNECT
    // ====================================

    ws.on("close", () => {

        console.log("PLAYER DISCONNECTED:", ws.id);

        const roomCode = ws.room;

        if (!roomCode) return;

        const room = rooms[roomCode];

        if (!room) return;

        room.players = room.players.filter(p => p !== ws);

        // delete empty room
        if (room.players.length <= 0) {

            delete rooms[roomCode];

            console.log("ROOM DELETED:", roomCode);

            return;
        }

        // update remaining players
        sendRoomUpdate(room);
    });

});
