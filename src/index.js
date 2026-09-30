'use strict';

function healthCheck() {
  return {
    service: 'securebank-api',
    status: 'ok'
  };
}

function canTransfer(authenticatedUserId, originAccountOwnerId) {
  return Boolean(authenticatedUserId) && authenticatedUserId === originAccountOwnerId;
}

module.exports = { healthCheck, canTransfer };
