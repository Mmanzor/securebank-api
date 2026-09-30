'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const { healthCheck, canTransfer } = require('../src/index');

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
