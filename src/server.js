
'use strict';

const http = require('node:http');
const { healthCheck, canAccessUser } = require('./index');

const PORT = Number(process.env.PORT || 3000);


const users = {
  'user-01': {
    id: 'user-01',
    name: 'Usuario de prueba 01'
  },
  'user-02': {
    id: 'user-02',
    name: 'Usuario de prueba 02'
  }
};

// Tokens ficticios exclusivos del laboratorio.
// No representan un sistema de autenticación real.
const testSessions = {
  'lab-token-01': 'user-01',
  'lab-token-02': 'user-02'
};


const server = http.createServer((req, res) => {
  res.setHeader('Content-Type', 'application/json; charset=utf-8');
  res.setHeader('X-Content-Type-Options', 'nosniff');

  res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate');
  res.setHeader('Pragma', 'no-cache');
  res.setHeader('Cross-Origin-Resource-Policy', 'same-origin');


  if (req.method === 'GET' && req.url === '/') {
    res.writeHead(200);
    res.end(JSON.stringify({
      service: 'securebank-api',
      message: 'SecureBank API disponible',
      endpoints: ['/health', '/users/user-01', '/users/user-02']
    }));
    return;
   }



  if (req.method === 'GET' && req.url === '/health') {
    res.writeHead(200);
    res.end(JSON.stringify(healthCheck()));
    return;
  }


if (req.method === 'GET' && /^\/users\/[^/]+$/.test(req.url)) {
  const requestedUserId = decodeURIComponent(req.url.split('/')[2]);

  const authorization = req.headers.authorization || '';
  const token = authorization.startsWith('Bearer ')
    ? authorization.slice(7)
    : '';

  const authenticatedUserId = testSessions[token];

  if (!authenticatedUserId) {
    res.writeHead(401);
    res.end(JSON.stringify({ error: 'Unauthorized' }));
    return;
  }

  if (!canAccessUser(authenticatedUserId, requestedUserId)) {
    res.writeHead(403);
    res.end(JSON.stringify({ error: 'Forbidden' }));
    return;
  }

  const user = users[requestedUserId];

  if (!user) {
    res.writeHead(404);
    res.end(JSON.stringify({ error: 'User not found' }));
    return;
  }

  res.writeHead(200);
  res.end(JSON.stringify(user));
  return;
}


  res.writeHead(404);
  res.end(JSON.stringify({
    error: 'Not Found'
  }));
});

if (require.main === module) {
  server.listen(PORT, '0.0.0.0', () => {
    console.log(`SecureBank API ejecutándose en puerto ${PORT}`);
  });
}

module.exports = { server };
