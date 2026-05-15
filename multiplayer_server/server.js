'use strict';

const http = require('http');
const https = require('https');
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');
const WebSocket = require('ws');

loadEnvFile(path.join(__dirname, '.env'));

const PORT = Number.parseInt(process.env.PORT || '3000', 10);
const ADMIN_TOKEN = process.env.ADMIN_TOKEN || '';
const ADMIN_HTML_PATH = path.join(__dirname, 'admin.html');
const PAYSTACK_SECRET_KEY = sanitizeSecretKey(process.env.PAYSTACK_SECRET_KEY || '');
const PAYSTACK_API_HOST = 'api.paystack.co';
const GOLD_PACK_TIERS = new Map([
  [100, 10],
  [175, 30],
  [500, 100]
]);
const TOTAL_MATCH_SLOTS = 5;
const HEARTBEAT_INTERVAL_MS = 30000;
const RECONNECT_GRACE_MS = 30000;
const MAX_PAYLOAD_BYTES = 32 * 1024;
const REALTIME_FLUSH_INTERVAL_MS = Math.max(Number.parseInt(process.env.REALTIME_FLUSH_INTERVAL_MS || '33', 10), 16);
const MAX_SOCKET_BUFFERED_BYTES = Math.max(Number.parseInt(process.env.MAX_SOCKET_BUFFERED_BYTES || String(256 * 1024), 10), 64 * 1024);
const MAX_OUTBOUND_QUEUE_MESSAGES = Math.max(Number.parseInt(process.env.MAX_OUTBOUND_QUEUE_MESSAGES || '128', 10), 16);
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
const paymentRecordsByInvoiceId = new Map();
const paymentRecords = [];

function createSocialSets() {
  return {
    friends: new Set(),
    incomingFriendRequests: new Set(),
    outgoingFriendRequests: new Set()
  };
}

function loadEnvFile(envPath) {
  if (!envPath || !fs.existsSync(envPath)) {
    return;
  }

  const lines = fs.readFileSync(envPath, 'utf8').split(/\r?\n/);

  lines.forEach((line) => {
    const trimmedLine = line.trim();

    if (!trimmedLine || trimmedLine.startsWith('#')) {
      return;
    }

    const separatorIndex = trimmedLine.indexOf('=');

    if (separatorIndex <= 0) {
      return;
    }

    const key = trimmedLine.slice(0, separatorIndex).trim();
    let value = trimmedLine.slice(separatorIndex + 1).trim();

    if (
      (value.startsWith('"') && value.endsWith('"'))
      || (value.startsWith("'") && value.endsWith("'"))
    ) {
      value = value.slice(1, -1);
    }

    if (!Object.prototype.hasOwnProperty.call(process.env, key)) {
      process.env[key] = value;
    }
  });
}

function sanitizeSecretKey(value) {
  let cleanValue = String(value || '')
    .replace(/[\u0000-\u001f\u007f]/g, '')
    .trim();

  if (cleanValue.startsWith('PAYSTACK_SECRET_KEY=')) {
    cleanValue = cleanValue.slice('PAYSTACK_SECRET_KEY='.length).trim();
  }

  if (
    (cleanValue.startsWith('"') && cleanValue.endsWith('"'))
    || (cleanValue.startsWith("'") && cleanValue.endsWith("'"))
  ) {
    cleanValue = cleanValue.slice(1, -1).trim();
  }

  return cleanValue;
}

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
    const partyClients = this.getInvitePartyClientsForMove(client);
    const capacity = Math.max(clampPlayerCount(maxPlayers), partyClients.length);
    let room = Array.from(rooms.values()).find((candidate) => {
      return !candidate.is_private
        && !candidate.started
        && candidate.max_players === capacity
        && this.roomHasSpaceForClients(candidate, partyClients);
    });

    if (!room) {
      room = this.createRoom(client, capacity, false, {
        partyName: `${capacity} Player Open Party`
      });
    }

    return this.addClientsToRoom(room, partyClients);
  }

  createPrivateRoom(client, maxPlayers) {
    const partyClients = this.getInvitePartyClientsForMove(client);
    const capacity = Math.max(clampPlayerCount(maxPlayers), partyClients.length);
    const room = this.createRoom(client, capacity, true, {
      partyName: `${client.name || 'Player'}'s Private Party`
    });
    const result = this.addClientsToRoom(room, partyClients);

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

    const partyClients = this.getInvitePartyClientsForMove(client);
    return this.addClientsToRoom(room, partyClients);
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
        partyName: `${client.name || 'Player'}'s Invite Party`,
        inviteRoom: true
      });

      const addResult = this.addPlayer(room, client, { notifyJoined: false });

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

  declineInvite(client, inviterId, roomCode) {
    if (!client) {
      return { ok: false, error: 'Invalid player.' };
    }

    const inviterClient = clientsById.get(String(inviterId || ''));

    if (!inviterClient || inviterClient.connected !== true) {
      return { ok: true };
    }

    const cleanCode = normalizeRoomCode(roomCode);
    sendJson(inviterClient, {
      type: 'room_invite_declined',
      target_id: client.id,
      target_name: client.name || 'Player',
      code: cleanCode,
      party_code: cleanCode,
      room_code: cleanCode,
      server_time: Date.now()
    });

    return { ok: true };
  }

  getInvitePartyClientsForMove(client) {
    if (!client) {
      return [];
    }

    const sourceRoom = rooms.get(client.room_id || '');

    if (!sourceRoom || sourceRoom.started || sourceRoom.invite_room !== true || sourceRoom.host_id !== client.id) {
      return [client];
    }

    const partyClients = sourceRoom.players
      .map((clientId) => clientsById.get(clientId))
      .filter((partyClient) => partyClient && partyClient.connected === true);

    return partyClients.length > 0 ? partyClients : [client];
  }

  roomHasSpaceForClients(room, partyClients) {
    if (!room) {
      return false;
    }

    const incomingIds = new Set((partyClients || []).map((partyClient) => partyClient.id));
    const currentCount = room.players.filter((clientId) => !incomingIds.has(clientId)).length;
    return currentCount + incomingIds.size <= room.max_players;
  }

  addClientsToRoom(room, partyClients) {
    if (!room || !Array.isArray(partyClients) || partyClients.length <= 0) {
      return { ok: false, error: 'Invalid party or player.' };
    }

    const uniqueClients = [];
    const seenIds = new Set();

    partyClients.forEach((partyClient) => {
      if (!partyClient || seenIds.has(partyClient.id)) {
        return;
      }
      seenIds.add(partyClient.id);
      uniqueClients.push(partyClient);
    });

    if (!this.roomHasSpaceForClients(room, uniqueClients)) {
      return { ok: false, error: 'Party is full.' };
    }

    let lastResult = { ok: true, room };

    for (const partyClient of uniqueClients) {
      lastResult = this.addPlayer(room, partyClient);

      if (!lastResult.ok) {
        return lastResult;
      }
    }

    return { ok: true, room };
  }

  addPlayer(room, client, options = {}) {
    if (!room || !client) {
      return { ok: false, error: 'Invalid party or player.' };
    }

    if (room.started) {
      return { ok: false, error: 'This match already started.' };
    }

    const notifyJoined = options.notifyJoined !== false;

    if (room.players.includes(client.id)) {
      if (notifyJoined) {
        this.sendRoomJoined(client, room);
      }
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
    client.rooms_joined = (client.rooms_joined || 0) + 1;
    client.last_room_joined_at = Date.now();
    room.players.push(client.id);

    if (!room.host_id) {
      room.host_id = client.id;
    }
    room.updated_at = Date.now();

    console.log(`[room] ${client.id} joined ${room.code} (${room.players.length}/${room.max_players})`);

    if (room.players.length >= room.max_players) {
      if (notifyJoined) {
        this.sendRoomJoined(client, room);
      }
      this.startMatch(room, 'room_full');
      return { ok: true, room };
    }

    if (notifyJoined) {
      this.sendRoomJoined(client, room);
    }
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
      invite_room: options.inviteRoom === true,
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
        age: client.age || 0,
        coin_balance: client.coin_balance || 0,
        gold_balance: client.gold_balance || 0,
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
      invite_room: room.invite_room === true,
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
        age: client.age || 0,
        coin_balance: client.coin_balance || 0,
        gold_balance: client.gold_balance || 0,
        connected: true,
        in_room: Boolean(room),
        room_code: room ? room.code : '',
        party_state: room ? (room.party_state || (room.started ? 'running' : 'lobby')) : 'online',
        is_private: room ? room.is_private === true : false,
        room_capacity: room ? room.max_players : 0
      };
    });
}

function serializeSocialClient(client) {
  if (!client) {
    return null;
  }
  const room = rooms.get(client.room_id || '');
  return {
    id: client.id,
    client_id: client.id,
    name: client.name || 'Player',
    login_id: client.login_id || '',
    age: client.age || 0,
    coin_balance: client.coin_balance || 0,
    gold_balance: client.gold_balance || 0,
    connected: client.connected === true,
    in_room: Boolean(room),
    room_code: room ? room.code : '',
    party_state: room ? (room.party_state || (room.started ? 'running' : 'lobby')) : 'online',
    is_private: room ? room.is_private === true : false,
    room_capacity: room ? room.max_players : 0
  };
}

function serializeSocialClients(ids) {
  return Array.from(ids || [])
    .map((id) => serializeSocialClient(clientsById.get(id)))
    .filter(Boolean);
}

function buildFriendsPayload(client) {
  return {
    type: 'friends_update',
    friends: serializeSocialClients(client.friends),
    incoming_requests: serializeSocialClients(client.incomingFriendRequests),
    outgoing_requests: serializeSocialClients(client.outgoingFriendRequests),
    server_time: Date.now()
  };
}

function sendFriendsUpdate(client) {
  if (!client) {
    return;
  }
  sendJson(client, buildFriendsPayload(client));
}

function sendFriendsUpdateForPair(firstClient, secondClient) {
  sendFriendsUpdate(firstClient);
  sendFriendsUpdate(secondClient);
}

function requestFriend(client, targetId) {
  if (!client) {
    return { ok: false, error: 'Invalid player.' };
  }

  const targetClient = clientsById.get(String(targetId || ''));

  if (!targetClient || targetClient.connected !== true) {
    return { ok: false, error: 'That player is no longer online.' };
  }
  if (targetClient.id === client.id) {
    return { ok: false, error: 'You cannot friend yourself.' };
  }
  if (client.friends.has(targetClient.id)) {
    return { ok: false, error: 'That player is already your friend.' };
  }

  targetClient.incomingFriendRequests.add(client.id);
  client.outgoingFriendRequests.add(targetClient.id);

  sendJson(targetClient, {
    type: 'friend_request',
    from: serializeSocialClient(client),
    from_id: client.id,
    from_name: client.name || 'Player',
    server_time: Date.now()
  });

  sendJson(client, {
    type: 'friend_request_sent',
    target: serializeSocialClient(targetClient),
    target_id: targetClient.id,
    target_name: targetClient.name || 'Player',
    server_time: Date.now()
  });

  sendFriendsUpdateForPair(client, targetClient);
  return { ok: true };
}

function acceptFriendRequest(client, requesterId) {
  if (!client) {
    return { ok: false, error: 'Invalid player.' };
  }

  const requester = clientsById.get(String(requesterId || ''));

  if (!requester) {
    return { ok: false, error: 'That friend request expired.' };
  }
  if (!client.incomingFriendRequests.has(requester.id)) {
    return { ok: false, error: 'Friend request not found.' };
  }

  client.incomingFriendRequests.delete(requester.id);
  requester.outgoingFriendRequests.delete(client.id);
  client.friends.add(requester.id);
  requester.friends.add(client.id);

  sendJson(client, {
    type: 'friend_request_accepted',
    friend: serializeSocialClient(requester),
    friend_id: requester.id,
    friend_name: requester.name || 'Player',
    server_time: Date.now()
  });
  sendJson(requester, {
    type: 'friend_request_accepted',
    friend: serializeSocialClient(client),
    friend_id: client.id,
    friend_name: client.name || 'Player',
    server_time: Date.now()
  });

  sendFriendsUpdateForPair(client, requester);
  return { ok: true };
}

function declineFriendRequest(client, requesterId) {
  if (!client) {
    return { ok: false, error: 'Invalid player.' };
  }

  const requester = clientsById.get(String(requesterId || ''));
  const cleanRequesterId = requester ? requester.id : String(requesterId || '');

  client.incomingFriendRequests.delete(cleanRequesterId);
  if (requester) {
    requester.outgoingFriendRequests.delete(client.id);
    sendFriendsUpdate(requester);
  }
  sendFriendsUpdate(client);
  return { ok: true };
}

function sendDirectChatMessage(client, targetId, rawText) {
  if (!client) {
    return { ok: false, error: 'Invalid player.' };
  }

  const targetClient = clientsById.get(String(targetId || ''));

  if (!targetClient || targetClient.connected !== true) {
    return { ok: false, error: 'That friend is offline.' };
  }
  if (!client.friends.has(targetClient.id)) {
    return { ok: false, error: 'Add this player as a friend before messaging.' };
  }

  const chatText = sanitizeChatText(rawText);

  if (!chatText) {
    return { ok: false, error: 'Chat message is empty.' };
  }

  const message = {
    type: 'direct_chat_message',
    text: chatText,
    sender_id: client.id,
    sender_name: client.name || 'Player',
    target_id: targetClient.id,
    target_name: targetClient.name || 'Player',
    is_direct: true,
    sent_at: Date.now(),
    server_time: Date.now()
  };

  sendJson(targetClient, message);
  sendJson(client, Object.assign({}, message, {
    type: 'direct_chat_sent',
    is_local: true
  }));
  return { ok: true };
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

function buildAdminSnapshot() {
  const now = Date.now();
  const allClients = Array.from(clientsById.values());
  const connectedClients = allClients.filter((client) => client.connected === true);
  const registeredClients = allClients.filter((client) => String(client.login_id || '').trim() !== '');
  const joinedClients = allClients.filter((client) => {
    return Boolean(client.room_id) || Number(client.rooms_joined || 0) > 0;
  });
  const openParties = Array.from(rooms.values()).filter((room) => !room.started);
  const runningParties = Array.from(rooms.values()).filter((room) => room.started);

  return {
    ok: true,
    server_time: now,
    uptime_seconds: Math.floor(process.uptime()),
    admin_auth_enabled: ADMIN_TOKEN !== '',
    totals: {
      sessions: allClients.length,
      online_players: connectedClients.length,
      registered_players: registeredClients.length,
      joined_players: joinedClients.length,
      open_parties: openParties.length,
      running_parties: runningParties.length,
      rooms: rooms.size
    },
    players: allClients
      .map(serializeAdminPlayer)
      .sort((first, second) => {
        if (first.connected !== second.connected) {
          return first.connected ? -1 : 1;
        }
        return second.last_seen_at - first.last_seen_at;
      }),
    rooms: Array.from(rooms.values())
      .map(serializeAdminRoom)
      .sort((first, second) => second.updated_at - first.updated_at)
      ,
    payments: paymentRecords
      .slice(-100)
      .reverse()
  };
}

function serializeAdminPlayer(client) {
  const room = rooms.get(client.room_id || '');
  const loginId = String(client.login_id || '').trim();

  return {
    id: client.id,
    client_id: client.id,
    name: client.name || 'Player',
    login_id: loginId,
    registered: loginId !== '',
    age: client.age || 0,
    coin_balance: client.coin_balance || 0,
    gold_balance: client.gold_balance || 0,
    purchases: summarizePaymentsForClient(client),
    connected: client.connected === true,
    ip: client.ip || 'unknown',
    in_room: Boolean(room),
    room_id: room ? room.id : '',
    room_code: room ? room.code : '',
    room_name: room ? room.party_name || '' : '',
    party_state: room ? (room.party_state || (room.started ? 'running' : 'lobby')) : 'online',
    room_capacity: room ? room.max_players : 0,
    is_host: room ? room.host_id === client.id : false,
    rooms_joined: Number(client.rooms_joined || 0),
    created_at: client.created_at || 0,
    connected_at: client.connected_at || 0,
    registered_at: client.registered_at || 0,
    last_seen_at: client.last_seen_at || client.connected_at || client.created_at || 0,
    last_room_joined_at: client.last_room_joined_at || 0,
    friends_count: client.friends ? client.friends.size : 0,
    dropped_messages: Number(client.dropped_messages || 0)
  };
}

function summarizePaymentsForClient(client) {
  const loginId = String(client && client.login_id || '').trim();
  const name = String(client && client.name || '').trim().toLowerCase();
  const matchingRecords = paymentRecords.filter((record) => {
    const recordLoginId = String(record.player_login_id || '').trim();
    const recordName = String(record.player_name || '').trim().toLowerCase();
    if (loginId && recordLoginId && loginId === recordLoginId) {
      return true;
    }
    return Boolean(name && recordName && name === recordName);
  });
  const completedRecords = matchingRecords.filter((record) => isCompletedPaymentState(record.state));

  return {
    any: completedRecords.length > 0,
    completed_count: completedRecords.length,
    total_amount: completedRecords.reduce((sum, record) => sum + Number(record.amount || 0), 0),
    total_gold: completedRecords.reduce((sum, record) => sum + Number(record.gold_amount || 0), 0),
    latest_state: matchingRecords.length > 0 ? String(matchingRecords[matchingRecords.length - 1].state || 'PENDING') : '',
    latest_at: matchingRecords.length > 0 ? Number(matchingRecords[matchingRecords.length - 1].updated_at || 0) : 0
  };
}

function serializeAdminRoom(room) {
  return {
    id: room.id,
    code: room.code,
    party_name: room.party_name || '',
    max_players: room.max_players,
    player_count: room.players.length,
    connected_count: room.players
      .map((clientId) => clientsById.get(clientId))
      .filter((client) => client && client.connected === true).length,
    is_private: room.is_private === true,
    invite_room: room.invite_room === true,
    started: room.started === true,
    party_state: room.party_state || (room.started ? 'running' : 'lobby'),
    host_id: room.host_id || '',
    players: room.players
      .map((clientId) => clientsById.get(clientId))
      .filter(Boolean)
      .map((client) => ({
        id: client.id,
        name: client.name || 'Player',
        login_id: client.login_id || '',
        age: client.age || 0,
        coin_balance: client.coin_balance || 0,
        gold_balance: client.gold_balance || 0,
        connected: client.connected === true,
        is_host: client.id === room.host_id
      })),
    created_at: room.created_at || 0,
    updated_at: room.updated_at || room.created_at || 0,
    started_at: room.started_at || 0
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

const httpServer = http.createServer(async (request, response) => {
  const requestUrl = new URL(request.url || '/', `http://${request.headers.host || 'localhost'}`);

  if (request.method === 'OPTIONS') {
    writeCorsHeaders(response);
    response.writeHead(204);
    response.end();
    return;
  }

  if (request.method === 'GET' && requestUrl.pathname === '/health') {
    const connectedClients = Array.from(clientsById.values()).filter((client) => client.connected).length;
    const openParties = Array.from(rooms.values()).filter((room) => !room.started).length;
    const runningParties = Array.from(rooms.values()).filter((room) => room.started).length;
    writeJsonResponse(response, 200, {
      ok: true,
      connected_clients: connectedClients,
      open_parties: openParties,
      running_parties: runningParties,
      sessions: clientsById.size,
      rooms: rooms.size,
      authority_mode: 'dedicated_party_server',
      uptime: process.uptime()
    });
    return;
  }

  if (request.method === 'GET' && requestUrl.pathname === '/admin') {
    serveAdminDashboard(response);
    return;
  }

  if (request.method === 'GET' && requestUrl.pathname === '/admin/data') {
    if (!isAdminRequestAuthorized(request, requestUrl)) {
      writeJsonResponse(response, 401, {
        ok: false,
        error: 'Admin token is required.'
      });
      return;
    }
    writeJsonResponse(response, 200, buildAdminSnapshot());
    return;
  }

  if (
    request.method === 'POST'
    && requestUrl.pathname === '/payments/paystack/initialize'
  ) {
    await handlePaystackInitializeRequest(request, response);
    return;
  }

  if (
    request.method === 'POST'
    && requestUrl.pathname === '/payments/paystack/status'
  ) {
    await handlePaystackStatusRequest(request, response);
    return;
  }

  if (request.method === 'POST' && requestUrl.pathname.startsWith('/payments/')) {
    writeJsonResponse(response, 404, {
      ok: false,
      error: `Unknown payment endpoint: ${requestUrl.pathname}`
    });
    return;
  }

  response.writeHead(200, { 'Content-Type': 'text/plain' });
  response.end('BANO dedicated party server is running.');
});

function isAdminRequestAuthorized(request, requestUrl) {
  if (!ADMIN_TOKEN) {
    return true;
  }

  const queryToken = requestUrl.searchParams.get('token') || '';
  const headerToken = request.headers['x-admin-token'] || '';
  const authorization = request.headers.authorization || '';
  const bearerToken = authorization.toLowerCase().startsWith('bearer ')
    ? authorization.slice(7).trim()
    : '';

  return queryToken === ADMIN_TOKEN || headerToken === ADMIN_TOKEN || bearerToken === ADMIN_TOKEN;
}

function serveAdminDashboard(response) {
  fs.readFile(ADMIN_HTML_PATH, 'utf8', (error, html) => {
    if (error) {
      writeJsonResponse(response, 500, {
        ok: false,
        error: 'Admin dashboard file is missing.'
      });
      return;
    }

    response.writeHead(200, {
      'Content-Type': 'text/html; charset=utf-8',
      'Cache-Control': 'no-store'
    });
    response.end(html);
  });
}

function writeCorsHeaders(response) {
  response.setHeader('Access-Control-Allow-Origin', '*');
  response.setHeader('Access-Control-Allow-Methods', 'GET,POST,OPTIONS');
  response.setHeader('Access-Control-Allow-Headers', 'Content-Type, X-Admin-Token, Authorization');
}

function writeJsonResponse(response, statusCode, payload) {
  writeCorsHeaders(response);
  response.writeHead(statusCode, { 'Content-Type': 'application/json' });
  response.end(JSON.stringify(payload));
}

async function readJsonRequest(request, maxBytes = 16 * 1024) {
  return new Promise((resolve, reject) => {
    let body = '';
    request.setEncoding('utf8');
    request.on('data', (chunk) => {
      body += chunk;
      if (Buffer.byteLength(body, 'utf8') > maxBytes) {
        reject(new Error('Request body too large.'));
        request.destroy();
      }
    });
    request.on('end', () => {
      if (body.trim() === '') {
        resolve({});
        return;
      }
      try {
        resolve(JSON.parse(body));
      } catch (_error) {
        reject(new Error('Invalid JSON body.'));
      }
    });
    request.on('error', reject);
  });
}

function normalizeMpesaPhone(value) {
  let digits = String(value || '').replace(/\D/g, '');
  if (digits.length === 10 && digits.startsWith('0')) {
    digits = `254${digits.slice(1)}`;
  } else if (digits.length === 9 && /^[17]/.test(digits)) {
    digits = `254${digits}`;
  }
  return /^254[17]\d{8}$/.test(digits) ? digits : '';
}

function getPaystackMpesaPhoneCandidates(phoneNumber) {
  const digits = String(phoneNumber || '').replace(/\D/g, '');
  const candidates = [];

  if (/^254[17]\d{8}$/.test(digits)) {
    candidates.push(digits);
    candidates.push(`+${digits}`);
    candidates.push(`0${digits.slice(3)}`);
  } else if (phoneNumber) {
    candidates.push(String(phoneNumber));
  }

  return Array.from(new Set(candidates.filter(Boolean)));
}

function isPaystackPhoneFormatError(error) {
  const message = String(error && error.message || '').toLowerCase();
  return message.includes('phone') && message.includes('format');
}

function sanitizePaymentPurpose(value) {
  return String(value || '').toLowerCase() === 'gold' ? 'gold' : 'donation';
}

function createPaymentRef(purpose) {
  return `bano-${purpose}-${Date.now()}-${crypto.randomBytes(4).toString('hex')}`;
}

async function handlePaystackInitializeRequest(request, response) {
  if (!PAYSTACK_SECRET_KEY) {
    writeJsonResponse(response, 503, {
      ok: false,
      error: 'Payment server is missing PAYSTACK_SECRET_KEY.'
    });
    return;
  }

  let body;
  try {
    body = await readJsonRequest(request);
  } catch (error) {
    writeJsonResponse(response, 400, { ok: false, error: error.message });
    return;
  }

  const amount = Math.max(Math.trunc(Number(body.amount || 0)), 0);
  const phoneNumber = normalizeMpesaPhone(body.phone_number);
  const purpose = sanitizePaymentPurpose(body.purpose);
  const goldAmount = purpose === 'gold' ? GOLD_PACK_TIERS.get(amount) || 0 : 0;
  const playerName = sanitizeAdminText(body.player_name, 40);
  const playerLoginId = sanitizeAdminText(body.player_login_id || body.login_id, 40);
  const playerAge = sanitizePositiveInt(body.player_age || body.age, 120);

  if (amount <= 0) {
    writeJsonResponse(response, 400, { ok: false, error: 'Enter a valid KES amount.' });
    return;
  }

  if (purpose === 'gold' && !GOLD_PACK_TIERS.has(amount)) {
    writeJsonResponse(response, 400, { ok: false, error: 'Choose a valid gold pack.' });
    return;
  }

  if (!phoneNumber) {
    writeJsonResponse(response, 400, { ok: false, error: 'Enter a valid Safaricom phone number.' });
    return;
  }

  const apiRef = createPaymentRef(purpose);
  const email = normalizePaymentEmail(body.email) || createPaystackFallbackEmail(apiRef);
  const payload = {
    amount: String(amount * 100),
    currency: 'KES',
    email,
    reference: apiRef,
    mobile_money: {
      phone: phoneNumber,
      provider: 'mpesa'
    },
    metadata: {
      player_name: playerName,
      player_login_id: playerLoginId,
      player_age: playerAge,
      phone_number: phoneNumber,
      purpose,
      gold_amount: goldAmount
    }
  };

  try {
    const providerResponse = await postPaystackChargeWithPhoneFallback(payload, phoneNumber);
    const invoiceId = extractPaystackReference(providerResponse) || apiRef;
    recordPayment({
      invoice_id: invoiceId,
      api_ref: apiRef,
      player_name: playerName,
      player_login_id: playerLoginId,
      player_age: playerAge,
      phone_number: phoneNumber,
      purpose,
      amount,
      gold_amount: goldAmount,
      state: extractPaystackState(providerResponse) || 'PENDING',
      provider_response: providerResponse
    });
    writeJsonResponse(response, 200, {
      ok: true,
      api_ref: apiRef,
      reference: invoiceId,
      purpose,
      amount,
      gold_amount: goldAmount,
      invoice_id: invoiceId,
      access_code: providerResponse && providerResponse.data ? providerResponse.data.access_code || '' : '',
      provider_message: providerResponse && providerResponse.data ? providerResponse.data.display_text || providerResponse.data.message || '' : '',
      state: extractPaystackState(providerResponse) || 'PENDING',
      provider_response: providerResponse
    });
  } catch (error) {
    console.warn(
      `[paystack] charge failed ref=${apiRef} purpose=${purpose} amount=${amount} phone=${maskPhoneForLog(phoneNumber)} status=${error.statusCode || 'unknown'} message=${error.message || 'unknown'}`
    );
    recordPayment({
      invoice_id: apiRef,
      api_ref: apiRef,
      player_name: playerName,
      player_login_id: playerLoginId,
      player_age: playerAge,
      phone_number: phoneNumber,
      purpose,
      amount,
      gold_amount: goldAmount,
      state: 'FAILED'
    });
    writeJsonResponse(response, error.statusCode || 502, {
      ok: false,
      error: error.message || 'Paystack payment request failed.'
    });
  }
}

async function handlePaystackStatusRequest(request, response) {
  if (!PAYSTACK_SECRET_KEY) {
    writeJsonResponse(response, 503, {
      ok: false,
      error: 'Payment server is missing PAYSTACK_SECRET_KEY.'
    });
    return;
  }

  let body;
  try {
    body = await readJsonRequest(request);
  } catch (error) {
    writeJsonResponse(response, 400, { ok: false, error: error.message });
    return;
  }

  const invoiceId = String(body.invoice_id || body.reference || '').trim();
  if (!invoiceId) {
    writeJsonResponse(response, 400, { ok: false, error: 'Missing payment reference.' });
    return;
  }

  try {
    const providerResponse = await postPaystackJson('GET', `/charge/${encodeURIComponent(invoiceId)}`);
    const verifiedReference = extractPaystackReference(providerResponse) || invoiceId;
    const state = extractPaystackState(providerResponse);
    updatePaymentRecord(invoiceId, {
      state,
      provider_response: providerResponse
    });
    writeJsonResponse(response, 200, {
      ok: true,
      invoice_id: verifiedReference,
      reference: verifiedReference,
      state,
      invoice: providerResponse.data || {},
      provider_response: providerResponse
    });
  } catch (error) {
    writeJsonResponse(response, error.statusCode || 502, {
      ok: false,
      error: error.message || 'Paystack status check failed.'
    });
  }
}

function postPaystackJson(method, requestPath, payload = null) {
  const body = payload == null ? '' : JSON.stringify(payload);
  const options = {
    method,
    hostname: PAYSTACK_API_HOST,
    path: requestPath,
    headers: {
      Authorization: `Bearer ${PAYSTACK_SECRET_KEY}`,
      'Content-Type': 'application/json'
    },
    timeout: 20000
  };
  if (body !== '') {
    options.headers['Content-Length'] = Buffer.byteLength(body);
  }

  return new Promise((resolve, reject) => {
    let providerRequest;

    try {
      providerRequest = https.request(options, (providerResponse) => {
      let responseBody = '';
      providerResponse.setEncoding('utf8');
      providerResponse.on('data', (chunk) => {
        responseBody += chunk;
      });
      providerResponse.on('end', () => {
        let parsed = {};
        if (responseBody.trim() !== '') {
          try {
            parsed = JSON.parse(responseBody);
          } catch (_error) {
            parsed = { raw: responseBody };
          }
        }

        if (providerResponse.statusCode >= 200 && providerResponse.statusCode < 300 && parsed.status !== false) {
          resolve(parsed);
          return;
        }

        const error = new Error(parsed.message || parsed.error || `Paystack returned ${providerResponse.statusCode}.`);
        error.statusCode = providerResponse.statusCode;
        reject(error);
      });
      });
    } catch (error) {
      reject(error);
      return;
    }

    providerRequest.on('timeout', () => {
      providerRequest.destroy(new Error('Paystack request timed out.'));
    });
    providerRequest.on('error', reject);
    if (body !== '') {
      providerRequest.write(body);
    }
    providerRequest.end();
  });
}

async function postPaystackChargeWithPhoneFallback(payload, phoneNumber) {
  const phoneCandidates = getPaystackMpesaPhoneCandidates(phoneNumber);
  let lastError = null;

  for (const candidate of phoneCandidates) {
    const candidatePayload = Object.assign({}, payload, {
      mobile_money: Object.assign({}, payload.mobile_money, {
        phone: candidate
      })
    });

    try {
      return await postPaystackJson('POST', '/charge', candidatePayload);
    } catch (error) {
      lastError = error;
      if (!isPaystackPhoneFormatError(error)) {
        throw error;
      }
      console.log(`[paystack] retrying M-Pesa charge with alternate phone format after provider rejected ${maskPhoneForLog(candidate)}`);
    }
  }

  throw lastError || new Error('Paystack payment request failed.');
}

function maskPhoneForLog(value) {
  const digits = String(value || '').replace(/\D/g, '');
  if (digits.length <= 4) {
    return '****';
  }
  return `${'*'.repeat(Math.max(digits.length - 4, 4))}${digits.slice(-4)}`;
}

function extractPaystackReference(providerResponse) {
  if (!providerResponse || typeof providerResponse !== 'object') {
    return '';
  }
  if (providerResponse.reference) {
    return String(providerResponse.reference);
  }
  if (providerResponse.data && typeof providerResponse.data === 'object' && providerResponse.data.reference) {
    return String(providerResponse.data.reference);
  }
  return '';
}

function extractPaystackState(providerResponse) {
  if (!providerResponse || typeof providerResponse !== 'object') {
    return '';
  }
  if (providerResponse.data && typeof providerResponse.data === 'object' && providerResponse.data.status) {
    return String(providerResponse.data.status).toUpperCase();
  }
  if (providerResponse.status === true) {
    return 'PENDING';
  }
  return '';
}

function normalizePaymentEmail(value) {
  const email = String(value || '').trim().toLowerCase();
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email) ? email.slice(0, 120) : '';
}

function createPaystackFallbackEmail(reference) {
  return `player+${String(reference || crypto.randomUUID()).replace(/[^a-zA-Z0-9]/g, '').slice(0, 48)}@example.com`;
}

function recordPayment(record) {
  const now = Date.now();
  const cleanRecord = {
    invoice_id: sanitizeAdminText(record.invoice_id, 80),
    api_ref: sanitizeAdminText(record.api_ref, 80),
    player_name: sanitizeAdminText(record.player_name, 40),
    player_login_id: sanitizeAdminText(record.player_login_id, 40),
    player_age: sanitizePositiveInt(record.player_age, 120),
    phone_number: sanitizeAdminText(record.phone_number, 20),
    purpose: sanitizePaymentPurpose(record.purpose),
    amount: Math.max(Math.trunc(Number(record.amount || 0)), 0),
    gold_amount: Math.max(Math.trunc(Number(record.gold_amount || 0)), 0),
    state: sanitizeAdminText(record.state || 'PENDING', 30).toUpperCase(),
    created_at: now,
    updated_at: now
  };

  paymentRecords.push(cleanRecord);
  while (paymentRecords.length > 500) {
    const removed = paymentRecords.shift();
    if (removed && removed.invoice_id) {
      paymentRecordsByInvoiceId.delete(removed.invoice_id);
    }
  }
  if (cleanRecord.invoice_id) {
    paymentRecordsByInvoiceId.set(cleanRecord.invoice_id, cleanRecord);
  }
  return cleanRecord;
}

function updatePaymentRecord(invoiceId, updates) {
  const cleanInvoiceId = sanitizeAdminText(invoiceId, 80);
  if (!cleanInvoiceId) {
    return null;
  }

  let record = paymentRecordsByInvoiceId.get(cleanInvoiceId);
  if (!record) {
    record = recordPayment({
      invoice_id: cleanInvoiceId,
      purpose: 'donation',
      state: 'UNKNOWN'
    });
  }

  if (updates && updates.state) {
    record.state = sanitizeAdminText(updates.state, 30).toUpperCase();
  }
  record.updated_at = Date.now();
  return record;
}

function isCompletedPaymentState(state) {
  return ['COMPLETE', 'COMPLETED', 'PAID', 'SUCCESS', 'SUCCESSFUL'].includes(String(state || '').toUpperCase());
}

function sanitizePositiveInt(value, maxValue) {
  const parsed = Number.parseInt(value, 10);
  if (!Number.isFinite(parsed) || parsed <= 0) {
    return 0;
  }
  return Math.min(parsed, maxValue);
}

function sanitizeAdminText(value, maxLength) {
  return String(value || '')
    .replace(/[\u0000-\u001f\u007f]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim()
    .slice(0, maxLength);
}

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
  sendFriendsUpdate(client);
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

const outboundFlushTimer = setInterval(() => {
  clientsById.forEach((client) => {
    if (client.connected === true) {
      flushClientOutbound(client);
    }
  });
}, REALTIME_FLUSH_INTERVAL_MS);

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
    age: 0,
    coin_balance: 0,
    gold_balance: 0,
    socket,
    room_id: '',
    connected: true,
    is_alive: true,
    ip: getClientIp(request),
    created_at: Date.now(),
    connected_at: Date.now(),
    last_seen_at: Date.now(),
    registered_at: 0,
    rooms_joined: 0,
    last_room_joined_at: 0,
    cleanup_timer: null,
    outbound_queue: [],
    latest_realtime_payloads: new Map(),
    dropped_messages: 0
  };
  Object.assign(client, createSocialSets());

  clientsById.set(client.id, client);
  sessionsByToken.set(client.session_token, client);
  return client;
}

function handleMessage(client, data, socket) {
  if (!client) {
    return;
  }

  client.last_seen_at = Date.now();

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
    if (!client.registered_at) {
      client.registered_at = Date.now();
    }
  }
  updateClientProfileNumbers(client, message);
  const identityChanged = client.name !== previousName || client.login_id !== previousLoginId;

  switch (message.type) {
    case 'resume_session':
      resumeSession(client, socket, message.session_token, message.name, message.login_id, message);
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

    case 'decline_room_invite':
    case 'room_invite_declined':
      handleResult(client, roomManager.declineInvite(client, message.from_id || message.inviter_id, message.code || message.room_code));
      break;

    case 'friend_request':
    case 'request_friend':
      handleResult(client, requestFriend(client, message.target_id));
      break;

    case 'accept_friend_request':
      handleResult(client, acceptFriendRequest(client, message.from_id || message.requester_id || message.target_id));
      break;

    case 'decline_friend_request':
      handleResult(client, declineFriendRequest(client, message.from_id || message.requester_id || message.target_id));
      break;

    case 'direct_chat_message':
      handleResult(client, sendDirectChatMessage(client, message.target_id, message.text || message.message));
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

function resumeSession(tempClient, socket, sessionToken, name, loginId, profilePayload = {}) {
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
  existingClient.connected_at = Date.now();
  existingClient.last_seen_at = Date.now();
  socket.client = existingClient;

  if (typeof name === 'string' && name.trim() !== '') {
    existingClient.name = name.trim().slice(0, 24);
  }
  if (typeof loginId === 'string' && loginId.trim() !== '') {
    existingClient.login_id = loginId.trim().slice(0, 40);
    if (!existingClient.registered_at) {
      existingClient.registered_at = Date.now();
    }
  }
  updateClientProfileNumbers(existingClient, profilePayload);

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
  sendFriendsUpdate(existingClient);
  existingClient.friends.forEach((friendId) => {
    sendFriendsUpdate(clientsById.get(friendId));
  });
  broadcastOnlineDirectory();
}

function updateClientProfileNumbers(client, source) {
  if (!client || !source || typeof source !== 'object') {
    return;
  }

  const age = Number.parseInt(source.age || source.player_age || 0, 10);
  if (Number.isFinite(age) && age > 0) {
    client.age = Math.min(Math.max(age, 1), 120);
  }

  const coinBalance = Number.parseInt(source.coin_balance || source.coins || source.s_coins || 0, 10);
  if (Number.isFinite(coinBalance) && coinBalance >= 0) {
    client.coin_balance = coinBalance;
  }

  const goldBalance = Number.parseInt(source.gold_balance || source.gold || 0, 10);
  if (Number.isFinite(goldBalance) && goldBalance >= 0) {
    client.gold_balance = goldBalance;
  }
}

function handleDisconnect(client, socket, code, reason) {
  if (!client || client.socket !== socket) {
    return;
  }

  client.connected = false;
  client.last_seen_at = Date.now();
  const cleanReason = reason ? reason.toString() : '';
  console.log(`[disconnect] ${client.id} code=${code} reason=${cleanReason}`);

  const room = rooms.get(client.room_id || '');

  if (room) {
    roomManager.broadcastRoomUpdate(room);
  } else {
    broadcastOnlineDirectory();
  }
  client.friends.forEach((friendId) => {
    sendFriendsUpdate(clientsById.get(friendId));
  });

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

  if (Array.isArray(client.outbound_queue)) {
    client.outbound_queue.length = 0;
  }
  if (client.latest_realtime_payloads && client.latest_realtime_payloads instanceof Map) {
    client.latest_realtime_payloads.clear();
  }

  clientsById.delete(client.id);
  sessionsByToken.delete(client.session_token);
}

function sendJson(client, payload, options = {}) {
  if (!client || !client.socket || client.socket.readyState !== WebSocket.OPEN) {
    return false;
  }

  const realtimeKey = options.realtimeKey || getRealtimePayloadKey(payload);
  if (realtimeKey) {
    return queueLatestRealtimePayload(client, realtimeKey, payload);
  }

  try {
    const encodedPayload = JSON.stringify(payload);

    if (client.socket.bufferedAmount > MAX_SOCKET_BUFFERED_BYTES) {
      return queueReliablePayload(client, encodedPayload);
    }

    return rawSendJson(client, encodedPayload);
  } catch (error) {
    console.log(`[send_error] ${client.id}: ${error.message}`);
    return false;
  }
}

function rawSendJson(client, encodedPayload) {
  if (!client || !client.socket || client.socket.readyState !== WebSocket.OPEN) {
    return false;
  }

  try {
    client.socket.send(encodedPayload);
    return true;
  } catch (error) {
    console.log(`[send_error] ${client.id}: ${error.message}`);
    return false;
  }
}

function queueReliablePayload(client, encodedPayload) {
  if (!Array.isArray(client.outbound_queue)) {
    client.outbound_queue = [];
  }

  client.outbound_queue.push(encodedPayload);

  while (client.outbound_queue.length > MAX_OUTBOUND_QUEUE_MESSAGES) {
    client.outbound_queue.shift();
    client.dropped_messages = (client.dropped_messages || 0) + 1;
  }

  return true;
}

function queueLatestRealtimePayload(client, realtimeKey, payload) {
  if (!client.latest_realtime_payloads || !(client.latest_realtime_payloads instanceof Map)) {
    client.latest_realtime_payloads = new Map();
  }

  try {
    client.latest_realtime_payloads.set(realtimeKey, JSON.stringify(payload));
    return true;
  } catch (error) {
    console.log(`[send_error] ${client.id}: ${error.message}`);
    return false;
  }
}

function getRealtimePayloadKey(payload) {
  if (!payload || typeof payload !== 'object') {
    return '';
  }

  if (payload.type === 'player_update') {
    return `player_update:${payload.player_id || 'unknown'}`;
  }

  if (payload.type === 'game_message') {
    const messageType = String(payload.message_type || '');

    if (messageType === 'marble_states') {
      return 'game_message:marble_states';
    }

    if (messageType === 'remote_player_aim' || messageType === 'broadcast_remote_player_aim') {
      return `game_message:${messageType}:${payload.sender_id || 'unknown'}`;
    }
  }

  return '';
}

function flushClientOutbound(client) {
  if (!client || !client.socket || client.socket.readyState !== WebSocket.OPEN) {
    return;
  }

  if (client.socket.bufferedAmount > MAX_SOCKET_BUFFERED_BYTES) {
    return;
  }

  if (client.latest_realtime_payloads && client.latest_realtime_payloads.size > 0) {
    const realtimePayloads = Array.from(client.latest_realtime_payloads.values());
    client.latest_realtime_payloads.clear();

    for (const encodedPayload of realtimePayloads) {
      if (client.socket.bufferedAmount > MAX_SOCKET_BUFFERED_BYTES) {
        break;
      }

      rawSendJson(client, encodedPayload);
    }
  }

  while (
    Array.isArray(client.outbound_queue)
    && client.outbound_queue.length > 0
    && client.socket.bufferedAmount <= MAX_SOCKET_BUFFERED_BYTES
  ) {
    rawSendJson(client, client.outbound_queue.shift());
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
  clearInterval(outboundFlushTimer);

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
