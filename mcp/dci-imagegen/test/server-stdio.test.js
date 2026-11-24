// Uji ujung ke ujung: klien MCP asli <-> server dci-imagegen lewat stdio sungguhan, 9router palsu di belakangnya.
// Author: Mas Wondho — Duta Corpora Indonesia (DCI)
// Copyright © 2026 Duta Corpora Indonesia

import assert from 'node:assert/strict';
import { readFile, readdir } from 'node:fs/promises';
import { join } from 'node:path';
import test from 'node:test';
import { fileURLToPath } from 'node:url';
import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';
import { KEY_UJI, buatPng, folderSementara, mulaiRouterPalsu } from './helpers.js';

const INDEKS = fileURLToPath(new URL('../src/index.js', import.meta.url));

async function mulaiKlien({ router, t, keyDiEnv = KEY_UJI }) {
  const transport = new StdioClientTransport({
    command: process.execPath,
    args: [INDEKS],
    stderr: 'pipe',
    env: { ...process.env, HOME: t.dir, USERPROFILE: t.dir, NINEROUTER_URL: router.url, NINEROUTER_KEY: keyDiEnv },
  });
  let stderr = '';
  transport.stderr?.on('data', (d) => { stderr += d; });
  const klien = new Client({ name: 'uji', version: '0.0.1' });
  await klien.connect(transport);
  return { klien, stderr: () => stderr };
}

test('stdio: dua tool terdaftar dan skema generate_image memuat batas n', async () => {
  const router = await mulaiRouterPalsu();
  const t = await folderSementara();
  const { klien } = await mulaiKlien({ router, t });
  try {
    const { tools } = await klien.listTools();
    assert.deepEqual(tools.map((x) => x.name).sort(), ['generate_image', 'list_image_models']);
    const gen = tools.find((x) => x.name === 'generate_image');
    assert.equal(gen.inputSchema.properties.n.maximum, 8);
    assert.deepEqual(gen.inputSchema.required, ['prompt']);
    assert.match(gen.description, /output_dir/);
    assert.match(gen.description, /TANYAKAN/);
  } finally {
    await klien.close();
    await router.tutup();
    await t.bersihkan();
  }
});

test('stdio: list_image_models menampilkan model dan kemampuan', async () => {
  const router = await mulaiRouterPalsu();
  const t = await folderSementara();
  const { klien } = await mulaiKlien({ router, t });
  try {
    const r = await klien.callTool({ name: 'list_image_models', arguments: {} });
    assert.equal(r.isError, false);
    assert.match(r.content[0].text, /cx\/gpt-image-2\.6-sunburst/);
    assert.match(r.content[0].text, /edit/);
  } finally {
    await klien.close();
    await router.tutup();
    await t.bersihkan();
  }
});

test('stdio: generate_image n=2 menulis dua berkas dan melaporkan progres', async () => {
  const router = await mulaiRouterPalsu({ generate: () => ({ status: 200, body: buatPng(100, 50) }) });
  const t = await folderSementara();
  const { klien } = await mulaiKlien({ router, t });
  try {
    const keluar = join(t.dir, 'hasil');
    const progres = [];
    const r = await klien.callTool(
      { name: 'generate_image', arguments: { prompt: 'logo uji stdio', n: 2, output_dir: keluar } },
      undefined,
      { onprogress: (p) => progres.push(`${p.progress}/${p.total}`), timeout: 20_000 },
    );
    assert.equal(r.isError, false);
    assert.match(r.content[0].text, /2 dari 2 gambar tersimpan/);
    assert.equal((await readdir(keluar)).length, 2);
    assert.ok(progres.includes('2/2'), `progres: ${progres.join(',')}`);
  } finally {
    await klien.close();
    await router.tutup();
    await t.bersihkan();
  }
});

test('stdio: n=5 tanpa confirmed -> isError dan nol panggilan ke 9router; dengan confirmed jalan', async () => {
  const router = await mulaiRouterPalsu();
  const t = await folderSementara();
  const { klien } = await mulaiKlien({ router, t });
  try {
    const keluar = join(t.dir, 'lima');
    const ditolak = await klien.callTool({ name: 'generate_image', arguments: { prompt: 'lima gambar', n: 5, output_dir: keluar } });
    assert.equal(ditolak.isError, true);
    assert.match(ditolak.content[0].text, /confirmed=true/);
    assert.equal(router.panggilan.length, 0);
    const jalan = await klien.callTool({ name: 'generate_image', arguments: { prompt: 'lima gambar', n: 5, confirmed: true, output_dir: keluar } });
    assert.equal(jalan.isError, false);
    assert.equal((await readdir(keluar)).length, 5);
  } finally {
    await klien.close();
    await router.tutup();
    await t.bersihkan();
  }
});

test('stdio: n=9 ditolak validasi skema', async () => {
  const router = await mulaiRouterPalsu();
  const t = await folderSementara();
  const { klien } = await mulaiKlien({ router, t });
  try {
    const r = await klien.callTool({ name: 'generate_image', arguments: { prompt: 'sembilan', n: 9 } }).catch((e) => ({ galat: String(e.message) }));
    assert.ok(r.galat ? /validation|maximum|Too big/i.test(r.galat) : r.isError === true);
    assert.equal(router.panggilan.length, 0);
  } finally {
    await klien.close();
    await router.tutup();
    await t.bersihkan();
  }
});

test('stdio: key TIDAK bocor di output tool maupun stderr, juga saat 9router membalas galat berisi key', async () => {
  const router = await mulaiRouterPalsu({
    generate: () => ({ status: 400, body: JSON.stringify({ error: { message: `permintaan ditolak untuk ${KEY_UJI}` } }) }),
  });
  const t = await folderSementara();
  const { klien, stderr } = await mulaiKlien({ router, t });
  try {
    const r = await klien.callTool({ name: 'generate_image', arguments: { prompt: 'uji kebocoran', output_dir: join(t.dir, 'k') } });
    const semua = JSON.stringify(r) + stderr();
    assert.ok(!semua.includes(KEY_UJI), 'key bocor');
    assert.ok(!/Bearer\s/i.test(semua), 'header Bearer bocor');
    assert.equal(r.isError, true);
  } finally {
    await klien.close();
    await router.tutup();
    await t.bersihkan();
  }
});

test('stdio: kredensial kosong -> galat jelas, bukan crash', async () => {
  const router = await mulaiRouterPalsu();
  const t = await folderSementara();
  const transport = new StdioClientTransport({
    command: process.execPath,
    args: [INDEKS],
    stderr: 'pipe',
    env: { ...process.env, HOME: t.dir, USERPROFILE: t.dir, NINEROUTER_URL: '', NINEROUTER_KEY: '' },
  });
  const klien = new Client({ name: 'uji', version: '0.0.1' });
  await klien.connect(transport);
  try {
    const r = await klien.callTool({ name: 'list_image_models', arguments: {} });
    assert.equal(r.isError, true);
    assert.match(r.content[0].text, /belum lengkap/);
  } finally {
    await klien.close();
    await router.tutup();
    await t.bersihkan();
  }
});

test('stdio: stdout hanya berisi protokol (hasil berkas tidak dicetak sebagai gambar mentah)', async () => {
  const router = await mulaiRouterPalsu();
  const t = await folderSementara();
  const { klien } = await mulaiKlien({ router, t });
  try {
    const keluar = join(t.dir, 'sepi');
    const r = await klien.callTool({ name: 'generate_image', arguments: { prompt: 'hasil sepi', output_dir: keluar } });
    assert.equal(r.content.every((c) => c.type === 'text'), true);
    const berkas = (await readdir(keluar))[0];
    assert.ok(!r.content[0].text.includes((await readFile(join(keluar, berkas))).toString('base64').slice(0, 20)));
  } finally {
    await klien.close();
    await router.tutup();
    await t.bersihkan();
  }
});
