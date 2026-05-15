'use strict';

const {
  clampPlayerCount,
  createRoomCode,
  createRoomId,
  normalizeRoomCode,
  safeSend,
  toPublicPlayer
} = require('./utils');

const TOTAL_MARBLE_SLOTS = 5;

class RoomManager {
  constructor() {
    this.rooms = new Map();
    this.clientRooms = new Map();
  }

  createOrJoinPublicRoom(client, options = {}) {
    const maxPlayers = clampPlayerCount(options.max_players);
    const openRoom = this.findOpenPublicRoom(maxPlayers);

    if (openRoom) {
      return this.joinRoomById(client, openRoom.id);
    }

    const room = this.createRoom({
      max_players: maxPlayers,
      is_private: false,
      room_code: ''
    });

    return this.addPlayerToRoom(client, room);
  }

  createPrivateRoom(client, options = {}) {
    const maxPlayers = clampPlayerCount(options.max_players);
    const existingCodes = new Set(
      Array.from(this.rooms.values())
        .filter((room) => room.is_private)
        .map((room) => room.room_code)
    );
    const room = this.createRoom({
      max_players: maxPlayers,
      is_private: true,
      room_code: createRoomCode(existingCodes)
    });

    return this.addPlayerToRoom(client, room);
  }

  joinRoom(client, options = {}) {
    const roomCode = normalizeRoomCode(options.room_code || options.code);

    if (roomCode !== '') {
      return this.joinPrivateRoomByCode(client, roomCode);
    }

    if (options.room_id || options.id) {
      return this.joinRoomById(client, String(options.room_id || options.id));
    }

    return this.createOrJoinPublicRoom(client, options);
  }

  joinPrivateRoomByCode(client, code) {
    const room = Array.from(this.rooms.values()).find((candidate) => {
      return candidate.is_private && candidate.room_code === code;
    });

    if (!room) {
      return { ok: false, error: 'Room code not found.' };
    }

    return this.addPlayerToRoom(client, room);
  }

  joinRoomById(client, roomId) {
    const room = this.rooms.get(roomId);

    if (!room) {
      return { ok: false, error: 'Room not found.' };
    }

    return this.addPlayerToRoom(client, room);
  }

  startGame(client) {
    const room = this.getClientRoom(client.id);

    if (!room) {
      return { ok: false, error: 'Player is not in a room.' };
    }

    if (room.started) {
      return { ok: false, error: 'Game already started.' };
    }

    const player = room.players.find((candidate) => candidate.id === client.id);

    if (!player || !player.is_host) {
      return { ok: false, error: 'Only the host can start the game.' };
    }

    if (room.players.length < 2) {
      return { ok: false, error: 'At least 2 players are needed to start.' };
    }

    this.broadcastStartGame(room);
    return { ok: true, room };
  }

  handlePlayerUpdate(client, payload) {
    const room = this.getClientRoom(client.id);

    if (!room) {
      return { ok: false, error: 'Player is not in a room.' };
    }

    const playerExists = room.players.some((player) => player.id === client.id);

    if (!playerExists) {
      return { ok: false, error: 'Player is not in this room.' };
    }

    this.broadcastToRoom(room.id, {
      type: 'player_update',
      room_id: room.id,
      player_id: client.id,
      position: payload.position || null,
      rotation: payload.rotation || null,
      velocity: payload.velocity || null,
      angular_velocity: payload.angular_velocity || null,
      timestamp: Date.now()
    }, client.id);

    return { ok: true, room };
  }

  handleGameMessage(client, payload) {
    const room = this.getClientRoom(client.id);

    if (!room) {
      return { ok: false, error: 'Player is not in a room.' };
    }

    if (!room.players.some((player) => player.id === client.id)) {
      return { ok: false, error: 'Player is not in this room.' };
    }

    const messageType = String(payload.message_type || '').trim();

    if (messageType === '') {
      return { ok: false, error: 'Game message type is missing.' };
    }

    this.broadcastToRoom(room.id, {
      type: 'game_message',
      room_id: room.id,
      sender_id: client.id,
      target_id: String(payload.target_id || ''),
      message_type: messageType,
      payload: payload.payload || {},
      timestamp: Date.now()
    }, client.id);

    return { ok: true, room };
  }

  removeClient(clientId) {
    const room = this.getClientRoom(clientId);

    if (!room) {
      return null;
    }

    const playerIndex = room.players.findIndex((player) => player.id === clientId);

    if (playerIndex === -1) {
      this.clientRooms.delete(clientId);
      return null;
    }

    const [removedPlayer] = room.players.splice(playerIndex, 1);
    this.clientRooms.delete(clientId);

    if (room.players.length === 0) {
      this.rooms.delete(room.id);
      console.log(`[room] removed empty room ${room.id}`);
      return { room, removedPlayer, deleted: true };
    }

    if (removedPlayer.is_host) {
      room.players[0].is_host = true;
      room.host_id = room.players[0].id;
      console.log(`[room] host changed in ${room.id}: ${room.host_id}`);
    }

    this.broadcastRoomUpdate(room);
    return { room, removedPlayer, deleted: false };
  }

  createRoom(options) {
    const room = {
      id: createRoomId(),
      max_players: clampPlayerCount(options.max_players),
      players: [],
      is_private: options.is_private === true,
      room_code: options.room_code || '',
      allow_ai: options.allow_ai === true,
      host_id: '',
      started: false,
      created_at: Date.now()
    };

    this.rooms.set(room.id, room);
    console.log(`[room] created ${room.is_private ? 'private' : 'public'} room ${room.id}`);
    return room;
  }

  addPlayerToRoom(client, room) {
    if (!client || !client.id) {
      return { ok: false, error: 'Invalid client.' };
    }

    if (room.started) {
      return { ok: false, error: 'Game already started.' };
    }

    if (room.players.some((player) => player.id === client.id)) {
      this.sendRoomJoined(client, room);
      this.broadcastRoomUpdate(room);
      return { ok: true, room };
    }

    if (room.players.length >= room.max_players) {
      return { ok: false, error: 'Room is full.' };
    }

    const currentRoom = this.getClientRoom(client.id);

    if (currentRoom && currentRoom.id !== room.id) {
      this.removeClient(client.id);
    }

    const player = {
      id: client.id,
      name: client.name || `Player ${room.players.length + 1}`,
      login_id: client.login_id || '',
      socket: client.socket,
      is_host: room.players.length === 0
    };

    room.players.push(player);
    room.host_id = room.host_id || player.id;
    this.clientRooms.set(client.id, room.id);

    console.log(`[room] ${client.id} joined ${room.id} (${room.players.length}/${room.max_players})`);

    this.sendRoomJoined(client, room);
    this.broadcastRoomUpdate(room);

    if (room.players.length >= room.max_players) {
      this.broadcastStartGame(room);
    }

    return { ok: true, room };
  }

  findOpenPublicRoom(maxPlayers) {
    return Array.from(this.rooms.values()).find((room) => {
      return !room.is_private
        && !room.started
        && room.max_players === maxPlayers
        && room.players.length < room.max_players;
    }) || null;
  }

  getClientRoom(clientId) {
    const roomId = this.clientRooms.get(clientId);

    if (!roomId) {
      return null;
    }

    return this.rooms.get(roomId) || null;
  }

  serializeRoom(room, includePrivateCode = true) {
    return {
      id: room.id,
      max_players: room.max_players,
      human_capacity: room.max_players,
      players: room.players.map(toPublicPlayer),
      is_private: room.is_private,
      room_code: includePrivateCode ? room.room_code : '',
      host_id: room.host_id,
      started: room.started,
      open_slots: Math.max(room.max_players - room.players.length, 0),
      ai_count: this.calculateAiCount(room),
      ai_count_if_full: room.allow_ai === true ? Math.max(TOTAL_MARBLE_SLOTS - room.max_players, 0) : 0
    };
  }

  calculateAiCount(room) {
    return room.allow_ai === true ? Math.max(TOTAL_MARBLE_SLOTS - room.players.length, 0) : 0;
  }

  listRooms() {
    return Array.from(this.rooms.values())
      .filter((room) => !room.started)
      .map((room) => this.serializeRoom(room, false));
  }

  sendRoomJoined(client, room) {
    safeSend(client.socket, {
      type: 'room_joined',
      client_id: client.id,
      room: this.serializeRoom(room)
    });
  }

  broadcastRoomUpdate(room) {
    this.broadcastToRoom(room.id, {
      type: 'room_update',
      room: this.serializeRoom(room)
    });
  }

  broadcastStartGame(room) {
    if (room.started) {
      return;
    }

    room.started = true;
    const roomData = this.serializeRoom(room);

    const message = {
      type: 'start_game',
      room_id: room.id,
      players: roomData.players,
      ai_count: this.calculateAiCount(room),
      human_capacity: room.max_players,
      total_slots: TOTAL_MARBLE_SLOTS,
      room: roomData
    };

    console.log(`[game] start ${room.id}: players=${room.players.length}, ai=${message.ai_count}`);
    this.broadcastToRoom(room.id, message);
  }

  broadcastToRoom(roomId, payload, exceptClientId = '') {
    const room = this.rooms.get(roomId);

    if (!room) {
      return;
    }

    room.players.forEach((player) => {
      if (player.id === exceptClientId) {
        return;
      }

      safeSend(player.socket, payload);
    });
  }
}

module.exports = RoomManager;
