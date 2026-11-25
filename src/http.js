'use strict';

const { createServer } = require('node:http');
const { healthCheck } = require('./index');

function createHealthServer() {
  return createServer((request, response) => {
    const isHealthCheck = request.method === 'GET' && request.url === '/health';
    response.writeHead(isHealthCheck ? 200 : 404, {
      'Content-Type': 'application/json; charset=utf-8',
      'Cache-Control': 'no-store',
      'X-Content-Type-Options': 'nosniff',
      'Content-Security-Policy': "default-src 'none'; frame-ancestors 'none'"
    });
    response.end(JSON.stringify(isHealthCheck ? healthCheck() : { error: 'Not found' }));
  });
}

module.exports = { createHealthServer };
