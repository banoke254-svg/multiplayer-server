'use strict';

const crypto = require('crypto');

const ROOM_CODE_ALPHABET = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
const WEBSOCKET_OPEN = 1;

function clampPlayerCount(value) {
  const count = Number.parseInt(value, 10);

  if (Number.isNaN(count)) {
    return 2;
  }

  return Math.min(Math.max(count, 2), 5);
}

function createClientId() {
  return `p_${crypto.randomUUID()}`;
}

function createRoomId() {
  return `r_${crypto.randomUUID()}`;
}

function createRoomCode(existingCodes) {
  let code = '';

  do {
    code = '';

    for (let index = 0; index < 5; index += 1) {
      const charIndex = crypto.randomInt(0, ROOM_CODE_ALPHABET.length);
      code += ROOM_CODE_ALPHABET[charIndex];
    }
  } while (existingCodes.has(code));

  return code;
}

function parseJsonMessage(data) {
  try {
    return JSON.parse(data.toString());
  } catch (error) {
    return null;
  }
}

function normalizeRoomCode(code) {
  return String(code || '').trim().toUpperCase();
}

function safeSend(socket, payload) {
  if (!socket || socket.readyState !== WEBSOCKET_OPEN) {
    return false;
  }

  try {
    socket.send(JSON.stringify(payload));
    return true;
  } catch (error) {
    return false;
  }
}

function toPublicPlayer(player) {
  return {
    id: player.id,
    name: player.name,
    login_id: player.login_id || '',
    is_host: player.is_host === true
  };
}

module.exports = {
  clampPlayerCount,
  createClientId,
  createRoomCode,
  createRoomId,
  normalizeRoomCode,
  parseJsonMessage,
  safeSend,
  toPublicPlayer
};
