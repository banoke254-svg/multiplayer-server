'use strict';

const http = require('http');
const crypto = require('crypto');
const WebSocket = require('ws');

const PORT = Number.parseInt(process.env.PORT || '3000', 10);
const TOTAL_MATCH_SLOTS = 5;
const HEARTBEAT_INTERVAL_MS = 30000;
const RECONNECT_GRACE_MS = 30000;
const MAX_PAYLOAD_BYTES = 32 * 1024;
const ROOM_CODE_ALPHABET = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
const CLIENT_INPUT_MESSAGES = new Set([
  'remote_player_aim',
  'remote_player_shot',
  'player_customization',
  'client_scene_ready',
  'sync_request',
  'chat_message'
]);
const AUTHORITY_STATE_MESSAGES = new Set([
  'marble_states',
  'turn_state',
  'scoreboard',
  'remote_turn_started',
  'broadcast_remote_player_aim',
  'match_finished'
]);

const clientsById = new Map();
const sessionsByToken = new Map();
const rooms = new Map();

class RoomManager {
  ensurePublicRooms() {
    for (let capacity = 2; capacity <= TOTAL_MATCH_SLOTS; capacity += 1) {
      const hasOpenRoom = Array.from(rooms.values()).some((room) => {
        return !room.is_private
          && !room.started
          && room.max_players === capacity
          && room.players.length < room.max_players;
      });

      if (!hasOpenRoom) {
        this.createRoom(null, capacity, false, {
          partyName: `${capacity} Player Open Party`
        });
      }
    }
  }

  createPublicMatch(client, maxPlayers) {
    this.ensurePublicRooms();
    const capacity = clampPlayerCount(maxPlayers);
    let room = Array.from(rooms.values()).find((candidate) => {
      return !candidate.is_private
        && !candidate.started
        && candidate.max_players === capacity
        && candidate.players.length < candidate.max_players;
    });

    if (!room) {
      room = this.createRoom(client, capacity, false, {
        partyName: `${capacity} Player Open Party`
      });
    }

    return this.addPlayer(room, client);
  }

  createPrivateRoom(client, maxPlayers) {
    const room = this.createRoom(client, clampPlayerCount(maxPlayers), true, {
      partyName: `${client.name || 'Player'}'s Private Party`
    });
    const result = this.addPlayer(room, client);

    if (result.ok) {
      const roomData = this.serializeRoom(room, true);
      sendJson(client, {
        type: 'room_created',
        code: room.code,
        party_code: room.code,
        server_authoritative: true,
        room: roomData,
        party: roomData
      });
    }

    return result;
  }

  joinRoomByCode(client, code) {
    const cleanCode = normalizeRoomCode(code);
    const room = Array.from(rooms.values()).find((candidate) => {
      return candidate.code === cleanCode && !candidate.started;
    });

    if (!room) {
      return { ok: false, error: 'Party code not found.' };
    }

    return this.addPlayer(room, client);
  }

  invitePlayer(client, targetId, maxPlayers) {
    if (!client) {
      return { ok: false, error: 'Invalid player.' };
    }

    const targetClient = clientsById.get(String(targetId || ''));

    if (!targetClient || targetClient.connected !== true) {
      return { ok: false, error: 'That player is no longer online.' };
    }

    if (targetClient.id === client.id) {
      return { ok: false, error: 'You cannot invite yourself.' };
    }

    let room = rooms.get(client.room_id || '');

    if (!room || room.started || room.players.length >= room.max_players) {
      room = this.createRoom(client, clampPlayerCount(maxPlayers || TOTAL_MATCH_SLOTS), true, {
        partyName: `${client.name || 'Player'}'s Invite Party`
      });

      const addResult = this.addPlayer(room, client);

      if (!addResult.ok) {
        return addResult;
      }
    }

    const roomData = this.serializeRoom(room, true);

    sendJson(targetClient, {
      type: 'room_invite',
      from_id: client.id,
      from_name: client.name || 'Player',
      code: room.code,
      party_code: room.code,
      room_code: room.code,
      room: roomData,
      party: roomData,
      server_time: Date.now()
    });

    sendJson(client, {
      type: 'invite_sent',
      target_id: targetClient.id,
      target_name: targetClient.name || 'Player',
      code: room.code,
      party_code: room.code,
      room_code: room.code,
      room: roomData,
      party: roomData,
      server_time: Date.now()
    });

    return { ok: true, room };
  }

  addPlayer(room, client) {
    if (!room || !client) {
      return { ok: false, error: 'Invalid party or player.' };
    }

    if (room.started) {
      return { ok: false, error: 'This match already started.' };
    }

    if (room.players.includes(client.id)) {
      this.sendRoomJoined(client, room);
      this.broadcastRoomUpdate(room);
      return { ok: true, room };
    }

    if (room.players.length >= room.max_players) {
      return { ok: false, error: 'Party is full.' };
    }

    if (client.room_id && client.room_id !== room.id) {
      this.removePlayer(client, false);
    }

    client.room_id = room.id;
    room.players.push(client.id);

    if (!room.host_id) {
      room.host_id = client.id;
    }
    room.updated_at = Date.now();

    console.log(`[room] ${client.id} joined ${room.code} (${room.players.length}/${room.max_players})`);

    if (room.players.length >= room.max_players) {
      this.sendRoomJoined(client, room);
      this.startMatch(room, 'room_full');
      return { ok: true, room };
    }

    this.sendRoomJoined(client, room);
    this.broadcastRoomUpdate(room);

    return { ok: true, room };
  }

  removePlayer(client, deleteSession) {
    if (!client || !client.room_id) {
      if (deleteSession) {
        deleteClientSession(client);
      }
      return;
    }

    const room = rooms.get(client.room_id);
    client.room_id = '';

    if (!room) {
      if (deleteSession) {
        deleteClientSession(client);
      }
      return;
    }

    room.players = room.players.filter((id) => id !== client.id);

    if (room.players.length === 0) {
      if (room.start_timer) {
        clearTimeout(room.start_timer);
        room.start_timer = null;
      }
      rooms.delete(room.id);
      console.log(`[room] removed empty room ${room.code}`);
      if (!room.is_private) {
        this.ensurePublicRooms();
      }
      if (deleteSession) {
        deleteClientSession(client);
      }
      broadcastOnlineDirectory();
      return;
    }

    if (room.host_id === client.id) {
      room.host_id = room.players[0];
      console.log(`[room] host migrated in ${room.code}: ${room.host_id}`);
    }
    room.updated_at = Date.now();

    this.broadcastRoomUpdate(room);

    if (deleteSession) {
      deleteClientSession(client);
    }
  }

  startMatchForHost(client) {
    const room = rooms.get(client.room_id || '');

    if (!room) {
      return { ok: false, error: 'You are not in a party.' };
    }

    if (!room.host_id && room.players.length > 0) {
      room.host_id = room.players[0];
    }

    if (room.host_id !== client.id) {
      return { ok: false, error: 'Only the host can start the match.' };
    }

    if (room.players.length < 2) {
      return { ok: false, error: 'At least 2 players are needed to start.' };
    }

    this.startMatch(room, 'host_started');
    return { ok: true, room };
  }

  scheduleMatchStart(room, reason, delayMs) {
    if (!room || room.started || room.start_timer) {
      return;
    }

    room.start_at = Date.now() + Math.max(delayMs, 0);
    room.start_reason = reason;

    room.start_timer = setTimeout(() => {
      room.start_timer = null;
      if (!rooms.has(room.id) || room.started || room.players.length <= 0) {
        room.start_at = 0;
        return;
      }
      this.startMatch(room, reason);
    }, Math.max(delayMs, 0));

    this.broadcastRoomUpdate(room);
  }

  startMatch(room, reason) {
    if (!room || room.started) {
      return;
    }

    if (room.start_timer) {
      clearTimeout(room.start_timer);
      room.start_timer = null;
    }
    room.start_at = 0;
    room.started = true;
    room.party_state = 'running';
    room.started_at = Date.now();
    room.updated_at = room.started_at;
    room.server_tick = 0;
    const roomData = this.serializeRoom(room, true);
    const message = {
      type: 'start_match',
      reason,
      room_id: room.id,
      party_id: room.id,
      code: room.code,
      party_code: room.code,
      players: roomData.players,
      ai_players: roomData.ai_players,
      slots: roomData.slots,
      ai_count: roomData.ai_count,
      max_players: room.max_players,
      server_authoritative: true,
      authority_mode: roomData.authority_mode,
      room: roomData,
      party: roomData
    };

    console.log(`[match] start ${room.code}: humans=${roomData.players.length}, ai=${roomData.ai_count}, reason=${reason}`);
    this.broadcastToRoom(room, message);

    if (!room.is_private) {
      this.ensurePublicRooms();
    }
    broadcastOnlineDirectory();
  }

  relayPlayerUpdate(client, payload) {
    const room = rooms.get(client.room_id || '');

    if (!room || !room.players.includes(client.id)) {
      return { ok: false, error: 'Player is not in a party.' };
    }
    room.message_sequence = nextRoomSequence(room);
    room.updated_at = Date.now();

    this.broadcastToRoom(room, {
      type: 'player_update',
      player_id: client.id,
      position: payload.position || null,
      rotation: payload.rotation || null,
      velocity: payload.velocity || null,
      server_sequence: room.message_sequence,
      timestamp: Date.now()
    }, client.id);

    return { ok: true, room };
  }

  relayGameMessage(client, payload) {
    const room = rooms.get(client.room_id || '');

    if (!room || !room.players.includes(client.id)) {
      return { ok: false, error: 'Player is not in a party.' };
    }

    const messageType = String(payload.message_type || '').trim();

    if (!messageType) {
      return { ok: false, error: 'Game message type is missing.' };
    }
    if (!CLIENT_INPUT_MESSAGES.has(messageType) && !AUTHORITY_STATE_MESSAGES.has(messageType)) {
      return { ok: false, error: `Unsupported game message: ${messageType}` };
    }

    const senderIsAuthority = client.id === room.host_id;
    if (AUTHORITY_STATE_MESSAGES.has(messageType) && !senderIsAuthority) {
      return { ok: false, error: 'Only the party authority can send world state.' };
    }

    const requestedTargetId = String(payload.target_id || '');
    if (requestedTargetId && !room.players.includes(requestedTargetId)) {
      return { ok: false, error: 'Target player is not in this party.' };
    }

    const targetId = requestedTargetId || this.getDefaultGameMessageTarget(room, client, messageType);
    room.message_sequence = nextRoomSequence(room);
    room.updated_at = Date.now();
    const cleanPayload = payload.payload && typeof payload.payload === 'object' ? payload.payload : {};
    cleanPayload.server_sequence = room.message_sequence;
    cleanPayload.server_time = room.updated_at;
    cleanPayload.server_authoritative = true;
    cleanPayload.party_id = room.id;

    if (messageType === 'chat_message') {
      const chatText = sanitizeChatText(cleanPayload.text || cleanPayload.message || '');

      if (!chatText) {
        return { ok: false, error: 'Chat message is empty.' };
      }

      cleanPayload.text = chatText;
      cleanPayload.sender_id = client.id;
      cleanPayload.sender_name = client.name || 'Player';
      cleanPayload.sent_at = room.updated_at;
    }

    const serverMessage = {
      type: 'game_message',
      sender_id: client.id,
      target_id: targetId,
      message_type: messageType,
      payload: cleanPayload,
      server_sequence: room.message_sequence,
      timestamp: room.updated_at
    };

    if (targetId) {
      const targetClient = clientsById.get(targetId);
      sendJson(targetClient, serverMessage);
    } else {
      this.broadcastToRoom(room, serverMessage, client.id);
    }

    return { ok: true, room };
  }

  getDefaultGameMessageTarget(room, client, messageType) {
    if (!room || !client || client.id === room.host_id) {
      return '';
    }
    if (
      messageType === 'remote_player_aim'
      || messageType === 'remote_player_shot'
      || messageType === 'client_scene_ready'
      || messageType === 'sync_request'
    ) {
      return room.host_id || '';
    }
    return '';
  }

  createRoom(hostClient, maxPlayers, isPrivate, options = {}) {
    const code = this.createUniqueRoomCode();
    const room = {
      id: `room_${crypto.randomUUID()}`,
      code,
      party_name: options.partyName || (isPrivate ? 'Private Party' : `${maxPlayers} Player Open Party`),
      max_players: maxPlayers,
      players: [],
      host_id: hostClient ? hostClient.id : '',
      is_private: isPrivate,
      allow_ai: false,
      started: false,
      party_state: 'lobby',
      created_at: Date.now(),
      updated_at: Date.now(),
      started_at: 0,
      start_timer: null,
      start_at: 0,
      start_reason: '',
      message_sequence: 0,
      server_tick: 0
    };

    rooms.set(room.id, room);
    console.log(`[room] created ${isPrivate ? 'private' : 'public'} ${code}`);
    return room;
  }

  createUniqueRoomCode() {
    let code = '';

    do {
      code = '';

      for (let i = 0; i < 5; i += 1) {
        code += ROOM_CODE_ALPHABET[crypto.randomInt(0, ROOM_CODE_ALPHABET.length)];
      }
    } while (Array.from(rooms.values()).some((room) => room.code === code));

    return code;
  }

  serializeRoom(room, includePrivateCode) {
    const humanPlayers = room.players
      .map((id) => clientsById.get(id))
      .filter(Boolean)
      .map((client) => ({
        id: client.id,
        name: client.name || 'Player',
        login_id: client.login_id || '',
        is_host: client.id === room.host_id,
        is_ai: false,
        connected: client.connected === true
      }));
    const aiCount = room.allow_ai === true ? Math.max(TOTAL_MATCH_SLOTS - humanPlayers.length, 0) : 0;
    const aiPlayers = room.allow_ai === true
      ? Array.from({ length: aiCount }, (_value, index) => ({
        id: `ai_${index + 1}`,
        name: `AI ${index + 1}`,
        is_host: false,
        is_ai: true,
        connected: true
      }))
      : [];

    return {
      id: room.id,
      party_id: room.id,
      party_name: room.party_name || (room.is_private ? 'Private Party' : `${room.max_players} Player Open Party`),
      code: includePrivateCode || !room.is_private ? room.code : '',
      room_code: includePrivateCode || !room.is_private ? room.code : '',
      party_code: includePrivateCode || !room.is_private ? room.code : '',
      max_players: room.max_players,
      human_capacity: room.max_players,
      player_count: humanPlayers.length,
      connected_count: humanPlayers.filter((player) => player.connected).length,
      open_slots: Math.max(room.max_players - humanPlayers.length, 0),
      players: humanPlayers,
      ai_count: aiCount,
      ai_players: aiPlayers,
      slots: humanPlayers.concat(aiPlayers),
      host_id: room.host_id,
      simulation_host_id: room.host_id,
      party_authority_id: 'server',
      server_authoritative: true,
      authority_mode: 'dedicated_party_server',
      is_private: room.is_private,
      is_public: !room.is_private,
      started: room.started,
      party_state: room.party_state || (room.started ? 'running' : 'lobby'),
      start_at: room.start_at || 0,
      started_at: room.started_at || 0,
      created_at: room.created_at || 0,
      updated_at: room.updated_at || room.created_at || 0,
      server_tick: room.server_tick || 0,
      message_sequence: room.message_sequence || 0,
      server_time: Date.now()
    };
  }

  listRooms() {
    this.ensurePublicRooms();
    return Array.from(rooms.values())
      .filter((room) => !room.started)
      .map((room) => this.serializeRoom(room, false));
  }

  sendRoomJoined(client, room) {
    const roomData = this.serializeRoom(room, true);
    sendJson(client, {
      type: 'room_joined',
      client_id: client.id,
      party_id: room.id,
      party_code: room.code,
      server_authoritative: true,
      room: roomData,
      party: roomData
    });
  }

  broadcastRoomUpdate(room) {
    const roomData = this.serializeRoom(room, true);
    this.broadcastToRoom(room, {
      type: 'room_update',
      room_id: room.id,
      party_id: room.id,
      code: room.code,
      party_code: room.code,
      players: roomData.players.length,
      max_players: room.max_players,
      ai_count: roomData.ai_count,
      start_at: roomData.start_at,
      server_time: roomData.server_time,
      server_authoritative: true,
      room: roomData,
      party: roomData
    });
    broadcastOnlineDirectory();
  }

  broadcastToRoom(room, payload, exceptClientId = '') {
    room.players.forEach((clientId) => {
      if (clientId === exceptClientId) {
        return;
      }

      const client = clientsById.get(clientId);
      sendJson(client, payload);
    });
  }
}

const roomManager = new RoomManager();
roomManager.ensurePublicRooms();

function serializeOnlinePlayers() {
  return Array.from(clientsById.values())
    .filter((client) => client.connected === true)
    .map((client) => {
      const room = rooms.get(client.room_id || '');

      return {
        id: client.id,
        client_id: client.id,
        name: client.name || 'Player',
        login_id: client.login_id || '',
        connected: true,
        in_room: Boolean(room),
        room_code: room ? room.code : '',
        party_state: room ? (room.party_state || (room.started ? 'running' : 'lobby')) : 'online',
        is_private: room ? room.is_private === true : false,
        room_capacity: room ? room.max_players : 0
      };
    });
}

function buildOnlineDirectoryPayload() {
  const roomList = roomManager.listRooms();
  const connectedClients = Array.from(clientsById.values()).filter((candidate) => candidate.connected).length;
  const runningParties = Array.from(rooms.values()).filter((room) => room.started).length;
  const onlinePlayers = serializeOnlinePlayers();

  return {
    type: 'online_players_update',
    rooms: roomList,
    parties: roomList,
    online_players_list: onlinePlayers,
    players_online: onlinePlayers,
    online_players: connectedClients,
    open_parties: roomList.length,
    running_parties: runningParties,
    authority_mode: 'dedicated_party_server',
    server_time: Date.now()
  };
}

function broadcastOnlineDirectory() {
  const payload = buildOnlineDirectoryPayload();

  clientsById.forEach((client) => {
    if (client.connected === true) {
      sendJson(client, payload);
    }
  });
}

function sanitizeChatText(value) {
  return String(value || '')
    .replace(/[\u0000-\u001f\u007f]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim()
    .slice(0, 160);
}

const httpServer = http.createServer((request, response) => {
  if (request.url === '/health') {
    const connectedClients = Array.from(clientsById.values()).filter((client) => client.connected).length;
    const openParties = Array.from(rooms.values()).filter((room) => !room.started).length;
    const runningParties = Array.from(rooms.values()).filter((room) => room.started).length;
    response.writeHead(200, { 'Content-Type': 'application/json' });
    response.end(JSON.stringify({
      ok: true,
      connected_clients: connectedClients,
      open_parties: openParties,
      running_parties: runningParties,
      sessions: clientsById.size,
      rooms: rooms.size,
      authority_mode: 'dedicated_party_server',
      uptime: process.uptime()
    }));
    return;
  }

  response.writeHead(200, { 'Content-Type': 'text/plain' });
  response.end('BANO dedicated party server is running.');
});

const websocketServer = new WebSocket.Server({
  server: httpServer,
  maxPayload: MAX_PAYLOAD_BYTES
});

websocketServer.on('connection', (socket, request) => {
  const client = createClient(socket, request);
  socket.client = client;

  console.log(`[connect] ${client.id} from ${client.ip}`);

  sendJson(client, {
    type: 'connected',
    client_id: client.id,
    session_token: client.session_token
  });
  broadcastOnlineDirectory();

  socket.on('pong', () => {
    const activeClient = socket.client;

    if (activeClient) {
      activeClient.is_alive = true;
    }
  });

  socket.on('message', (data) => {
    handleMessage(socket.client, data, socket);
  });

  socket.on('close', (code, reason) => {
    handleDisconnect(socket.client, socket, code, reason);
  });

  socket.on('error', (error) => {
    console.log(`[socket_error] ${socket.client ? socket.client.id : 'unknown'}: ${error.message}`);
  });
});

const heartbeatTimer = setInterval(() => {
  websocketServer.clients.forEach((socket) => {
    const client = socket.client;

    if (!client) {
      socket.terminate();
      return;
    }

    if (client.is_alive === false) {
      console.log(`[heartbeat] terminating stale client ${client.id}`);
      socket.terminate();
      return;
    }

    client.is_alive = false;
    socket.ping();
  });
}, HEARTBEAT_INTERVAL_MS);

httpServer.listen(PORT, '0.0.0.0', () => {
  console.log(`[server] BANO WebSocket server running on port ${PORT}`);
});

process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);

function createClient(socket, request) {
  const client = {
    id: `player_${crypto.randomUUID()}`,
    session_token: crypto.randomBytes(24).toString('hex'),
    name: 'Player',
    login_id: '',
    socket,
    room_id: '',
    connected: true,
    is_alive: true,
    ip: getClientIp(request),
    cleanup_timer: null
  };

  clientsById.set(client.id, client);
  sessionsByToken.set(client.session_token, client);
  return client;
}

function handleMessage(client, data, socket) {
  if (!client) {
    return;
  }

  const message = parseJson(data);

  if (!message || typeof message.type !== 'string') {
    sendError(client, 'Invalid JSON message.');
    return;
  }

  const previousName = client.name;
  const previousLoginId = client.login_id;

  if (typeof message.name === 'string' && message.name.trim() !== '') {
    client.name = message.name.trim().slice(0, 24);
  }
  if (typeof message.login_id === 'string' && message.login_id.trim() !== '') {
    client.login_id = message.login_id.trim().slice(0, 40);
  }
  const identityChanged = client.name !== previousName || client.login_id !== previousLoginId;

  switch (message.type) {
    case 'resume_session':
      resumeSession(client, socket, message.session_token, message.name, message.login_id);
      break;

    case 'list_rooms':
      sendJson(client, Object.assign(buildOnlineDirectoryPayload(), { type: 'rooms_list' }));
      break;

    case 'quick_match':
    case 'instant_match':
    case 'public_match':
    case 'create_public_room':
      handleResult(client, roomManager.createPublicMatch(client, message.max_players));
      break;

    case 'create_room':
    case 'create_private_room':
      handleResult(client, roomManager.createPrivateRoom(client, message.max_players));
      break;

    case 'join_room':
      handleResult(client, roomManager.joinRoomByCode(client, message.code || message.room_code));
      break;

    case 'invite_player':
      handleResult(client, roomManager.invitePlayer(client, message.target_id, message.max_players));
      break;

    case 'start_match':
    case 'start_game':
      handleResult(client, roomManager.startMatchForHost(client));
      break;

    case 'player_update':
      handleResult(client, roomManager.relayPlayerUpdate(client, message));
      break;

    case 'game_message':
      handleResult(client, roomManager.relayGameMessage(client, message));
      break;

    case 'ping':
      sendJson(client, {
        type: 'pong',
        timestamp: Date.now()
      });
      break;

    default:
      sendError(client, `Unknown message type: ${message.type}`);
      break;
  }

  if (identityChanged && message.type !== 'resume_session') {
    broadcastOnlineDirectory();
  }
}

function resumeSession(tempClient, socket, sessionToken, name, loginId) {
  const existingClient = sessionsByToken.get(String(sessionToken || ''));

  if (!existingClient || existingClient.id === tempClient.id) {
    sendJson(tempClient, {
      type: 'session_resume_failed',
      reason: 'Session expired.'
    });
    return;
  }

  clientsById.delete(tempClient.id);
  sessionsByToken.delete(tempClient.session_token);

  if (tempClient.socket && tempClient.socket.readyState === WebSocket.OPEN) {
    tempClient.socket.client = existingClient;
  }

  if (existingClient.socket && existingClient.socket !== socket && existingClient.socket.readyState === WebSocket.OPEN) {
    existingClient.socket.close(4000, 'Session resumed on another socket.');
  }

  if (existingClient.cleanup_timer) {
    clearTimeout(existingClient.cleanup_timer);
    existingClient.cleanup_timer = null;
  }

  existingClient.socket = socket;
  existingClient.connected = true;
  existingClient.is_alive = true;
  socket.client = existingClient;

  if (typeof name === 'string' && name.trim() !== '') {
    existingClient.name = name.trim().slice(0, 24);
  }
  if (typeof loginId === 'string' && loginId.trim() !== '') {
    existingClient.login_id = loginId.trim().slice(0, 40);
  }

  sendJson(existingClient, {
    type: 'session_resumed',
    client_id: existingClient.id,
    session_token: existingClient.session_token
  });

  const room = rooms.get(existingClient.room_id || '');

  if (room) {
    roomManager.sendRoomJoined(existingClient, room);
    roomManager.broadcastRoomUpdate(room);
  }

  console.log(`[resume] ${existingClient.id}`);
  broadcastOnlineDirectory();
}

function handleDisconnect(client, socket, code, reason) {
  if (!client || client.socket !== socket) {
    return;
  }

  client.connected = false;
  const cleanReason = reason ? reason.toString() : '';
  console.log(`[disconnect] ${client.id} code=${code} reason=${cleanReason}`);

  const room = rooms.get(client.room_id || '');

  if (room) {
    roomManager.broadcastRoomUpdate(room);
  } else {
    broadcastOnlineDirectory();
  }

  if (client.cleanup_timer) {
    clearTimeout(client.cleanup_timer);
  }

  client.cleanup_timer = setTimeout(() => {
    console.log(`[cleanup] removing expired session ${client.id}`);
    roomManager.removePlayer(client, true);
  }, RECONNECT_GRACE_MS);
}

function handleResult(client, result) {
  if (result && result.ok) {
    return;
  }

  sendError(client, result && result.error ? result.error : 'Request failed.');
}

function deleteClientSession(client) {
  if (!client) {
    return;
  }

  if (client.cleanup_timer) {
    clearTimeout(client.cleanup_timer);
    client.cleanup_timer = null;
  }

  clientsById.delete(client.id);
  sessionsByToken.delete(client.session_token);
}

function sendJson(client, payload) {
  if (!client || !client.socket || client.socket.readyState !== WebSocket.OPEN) {
    return false;
  }

  try {
    client.socket.send(JSON.stringify(payload));
    return true;
  } catch (error) {
    console.log(`[send_error] ${client.id}: ${error.message}`);
    return false;
  }
}

function sendError(client, error) {
  console.log(`[error] ${client ? client.id : 'unknown'}: ${error}`);
  sendJson(client, {
    type: 'error',
    error
  });
}

function parseJson(data) {
  try {
    return JSON.parse(data.toString());
  } catch (_error) {
    return null;
  }
}

function clampPlayerCount(value) {
  const parsed = Number.parseInt(value, 10);

  if (Number.isNaN(parsed)) {
    return 2;
  }

  return Math.min(Math.max(parsed, 2), TOTAL_MATCH_SLOTS);
}

function normalizeRoomCode(code) {
  return String(code || '').trim().toUpperCase();
}

function nextRoomSequence(room) {
  const currentSequence = Number.parseInt(room && room.message_sequence, 10);
  return Number.isFinite(currentSequence) ? currentSequence + 1 : 1;
}

function getClientIp(request) {
  const forwardedFor = request.headers['x-forwarded-for'];

  if (typeof forwardedFor === 'string' && forwardedFor.trim() !== '') {
    return forwardedFor.split(',')[0].trim();
  }

  return request.socket.remoteAddress || 'unknown';
}

function shutdown() {
  console.log('[server] shutting down');
  clearInterval(heartbeatTimer);

  websocketServer.clients.forEach((socket) => {
    if (socket.readyState === WebSocket.OPEN) {
      socket.send(JSON.stringify({ type: 'server_shutdown' }));
      socket.close(1001, 'Server shutting down.');
    }
  });

  httpServer.close(() => {
    process.exit(0);
  });

  setTimeout(() => {
    process.exit(1);
  }, 3000).unref();
}
