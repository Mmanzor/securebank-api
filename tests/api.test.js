
'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const { server } = require('../src/server');

test('API: verifica autorización BOLA por HTTP', async () => {
  await new Promise((resolve) => {
    server.listen(0, '127.0.0.1', resolve);
  });

  const address = server.address();
  const baseUrl = `http://127.0.0.1:${address.port}`;

  try {
    const ownResponse = await fetch(`${baseUrl}/users/user-01`, {
      headers: {
        Authorization: 'Bearer lab-token-01'
      }
    });

    assert.equal(ownResponse.status, 200);

    const otherResponse = await fetch(`${baseUrl}/users/user-02`, {
      headers: {
        Authorization: 'Bearer lab-token-01'
      }
    });

    assert.equal(otherResponse.status, 403);

    const anonymousResponse = await fetch(`${baseUrl}/users/user-01`);

    assert.equal(anonymousResponse.status, 401);
  } finally {
    await new Promise((resolve, reject) => {
      server.close((error) => error ? reject(error) : resolve());
    });
  }
});
