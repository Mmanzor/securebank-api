'use strict';

const { createHealthServer } = require('../src/http');

createHealthServer().listen(3000, '0.0.0.0');
