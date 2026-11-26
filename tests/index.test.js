'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const { healthCheck, canTransfer, canAccessUser } = require('../src/index');

test('healthCheck informa que el servicio está operativo', () => {
  assert.deepEqual(healthCheck(), {
    service: 'securebank-api',
    status: 'ok'
  });
});

test('permite transferencia cuando el usuario es dueño de la cuenta origen', () => {
  assert.equal(canTransfer('user-01', 'user-01'), true);
});

test('rechaza transferencia cuando la cuenta origen pertenece a otro usuario', () => {
  assert.equal(canTransfer('user-01', 'user-02'), false);
});


test('BOLA: permite consultar los datos del propio usuario', () => {
  assert.equal(canAccessUser('user-01', 'user-01'), true);
});

test('BOLA: rechaza el acceso a los datos de otro usuario', () => {
  assert.equal(canAccessUser('user-01', 'user-02'), false);
});

test('BOLA: rechaza el acceso cuando no hay usuario autenticado', () => {
  assert.equal(canAccessUser(null, 'user-01'), false);
});
