'use strict';

const { once } = require('node:events');
const assert = require('node:assert/strict');
const test = require('node:test');
const { createHealthServer } = require('../src/http');

test('el servicio de prueba expone salud y rechaza otras rutas', async (context) => {
  const server = createHealthServer().listen(0, '127.0.0.1');
  context.after(() => new Promise((resolve, reject) => {
    server.close((error) => error ? reject(error) : resolve());
  }));
  await once(server, 'listening');
  const baseUrl = `http://127.0.0.1:${server.address().port}`;

  const health = await fetch(`${baseUrl}/health`);
  assert.equal(health.status, 200);
  assert.equal(health.headers.get('cache-control'), 'no-store');
  assert.equal(health.headers.get('x-content-type-options'), 'nosniff');
  assert.deepEqual(await health.json(), { service: 'securebank-api', status: 'ok' });

  const missing = await fetch(`${baseUrl}/missing`);
  assert.equal(missing.status, 404);
  assert.deepEqual(await missing.json(), { error: 'Not found' });

  const post = await fetch(`${baseUrl}/health`, { method: 'POST' });
  assert.equal(post.status, 404);
  await post.json();
});
