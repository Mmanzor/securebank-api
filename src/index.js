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


function canAccessUser(authenticatedUserId, requestedUserId) {
  return Boolean(authenticatedUserId) &&
    authenticatedUserId === requestedUserId;
}


module.exports = { healthCheck, canTransfer, canAccessUser };
