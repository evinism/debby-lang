#!/usr/bin/env node

require('source-map-support/register');
const run = require('./build/cli.js').default;
run();
