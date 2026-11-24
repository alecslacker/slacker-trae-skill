#!/usr/bin/env node
// dci-imagegen — pemanggil manual untuk uji nyata (tanpa agent). Menjalankan server lewat stdio sungguhan.
// Pemakaian: node scripts/panggil.mjs <list_image_models|generate_image> '<json argumen>'
//        atau node scripts/panggil.mjs <tool> @berkas.json   (aman dari masalah tanda kutip PowerShell)
// Author: Mas Wondho — Duta Corpora Indonesia (DCI)
// Copyright © 2026 Duta Corpora Indonesia

import { readFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';

const [nama, mentah = '{}'] = process.argv.slice(2);
if (!nama) {
  console.error("Pemakaian: node scripts/panggil.mjs <list_image_models|generate_image> '<json argumen>' | @berkas.json");
  process.exit(2);
}
let argumen;
try {
  argumen = JSON.parse(mentah.startsWith('@') ? await readFile(mentah.slice(1), 'utf8') : mentah);
} catch (e) {
  console.error(`Argumen bukan JSON yang valid atau berkas tidak terbaca (${e?.code || e?.name}).`);
  process.exit(2);
}

// SDK hanya meneruskan sebagian kecil environment ke proses anak. Override kredensial harus dikirim eksplisit.
const env = {};
for (const k of ['NINEROUTER_URL', 'NINEROUTER_KEY']) if (process.env[k]) env[k] = process.env[k];
const transport = new StdioClientTransport({
  command: process.execPath,
  args: [fileURLToPath(new URL('../src/index.js', import.meta.url))],
  stderr: 'inherit',
  env,
});
const klien = new Client({ name: 'panggil-manual', version: '0.1.0' });
await klien.connect(transport);
try {
  const mulai = Date.now();
  const r = await klien.callTool({ name: nama, arguments: argumen }, undefined, {
    timeout: 600_000,
    resetTimeoutOnProgress: true,
    onprogress: (p) => console.error(`progres ${p.progress}/${p.total}`),
  });
  console.log(r.content.map((c) => c.text).join('\n'));
  console.error(`(${Math.round((Date.now() - mulai) / 1000)} detik, isError=${r.isError === true})`);
  process.exitCode = r.isError ? 1 : 0;
} finally {
  await klien.close();
}
