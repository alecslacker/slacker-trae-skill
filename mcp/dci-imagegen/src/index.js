#!/usr/bin/env node
// dci-imagegen — titik masuk stdio. Hanya protokol MCP yang boleh keluar lewat stdout.
// Author: Mas Wondho — Duta Corpora Indonesia (DCI)
// Copyright © 2026 Duta Corpora Indonesia

import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { sensor } from './errors.js';
import { buatServer } from './server.js';

process.on('unhandledRejection', (e) => {
  console.error(`[dci-imagegen] penolakan tak tertangani: ${sensor(e?.message || e)}`);
});

const server = buatServer();
await server.connect(new StdioServerTransport());
console.error('[dci-imagegen] siap (stdio)');
