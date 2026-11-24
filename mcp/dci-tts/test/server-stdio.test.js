// dci-tts — tes server MCP end-to-end lewat klien resmi SDK (stdio).
// Author: Mas Wondho — Duta Corpora Indonesia (DCI)
// Copyright © 2026 Duta Corpora Indonesia

import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtemp, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { InMemoryTransport } from '@modelcontextprotocol/sdk/inMemory.js';
import { buatServer } from '../src/server.js';
import { MP3_PALSU, stubFetch, KEY_UJI, URL_UJI } from './helpers.js';

async function sambungkan({ balasan = [], env = {}, cwd, home } = {}) {
  const tanpaEnvLokal = join(tmpdir(), 'dci-tts-uji-tidak-ada'); // sengaja tidak ada, agar tes tidak membaca ~/.9router/env asli
  const server = buatServer({ env, cwd, home, berkasEnv: tanpaEnvLokal, fetchImpl: stubFetch(balasan) });
  const klien = new Client({ name: 'uji-klien', version: '0.0.1' });
  const [s, c] = InMemoryTransport.createLinkedPair();
  await Promise.all([server.connect(s), klien.connect(c)]);
  return { klien, tutup: async () => { await klien.close(); await server.close(); } };
}

test('tools/list memuat dua tool dengan deskripsi berisi aturan', async () => {
  const { klien, tutup } = await sambungkan();
  try {
    const daftar = await klien.listTools();
    const nama = daftar.tools.map((t) => t.name).sort();
    assert.deepEqual(nama, ['list_free_voices', 'text_to_speech']);
    const tts = daftar.tools.find((t) => t.name === 'text_to_speech');
    assert.ok(tts.description.includes('generated-audio'));
    assert.ok(tts.description.includes('edge-tts/id-ID-ArdiNeural'));
    assert.ok(tts.description.includes('confirmed'));
  } finally {
    await tutup();
  }
});

test('list_free_voices memuat suara Ardi tanpa panggilan jaringan', async () => {
  const fetchGagal = stubFetch([]); // kosong: kalau dipakai, tool akan gagal
  const { klien, tutup } = await sambungkan({ balasan: [], env: { NINEROUTER_URL: URL_UJI, NINEROUTER_KEY: KEY_UJI } });
  void fetchGagal;
  try {
    const r = await klien.callTool({ name: 'list_free_voices', arguments: {} });
    assert.equal(r.isError, false);
    assert.ok(r.content[0].text.includes('id-ID-ArdiNeural'));
    assert.ok(r.content[0].text.includes('dashboard 9router'));
  } finally {
    await tutup();
  }
});

test('text_to_speech end-to-end: env lengkap -> hasil path mp3', async () => {
  const proyek = await mkdtemp(join(tmpdir(), 'dci-tts-e2e-'));
  const fetchPalsu = stubFetch([{ body: MP3_PALSU }]);
  const { klien, tutup } = await sambungkan({
    balasan: [{ body: MP3_PALSU }],
    env: { NINEROUTER_URL: URL_UJI, NINEROUTER_KEY: KEY_UJI },
    cwd: proyek,
    home: 'C:\\Users\\uji',
  });
  void fetchPalsu;
  try {
    const r = await klien.callTool({ name: 'text_to_speech', arguments: { segments: 'Uji ujung ke ujung suara.' } });
    assert.equal(r.isError, false);
    assert.ok(r.content[0].text.includes('1 dari 1 audio tersimpan'));
    assert.ok(r.content[0].text.includes(join(proyek, 'generated-audio')));
  } finally {
    await tutup();
    await rm(proyek, { recursive: true, force: true }).catch(() => {});
  }
});

// Regresi: argumen MCP pakai output_dir (underscore) tetapi lapisan speech membaca outputDir.
// Bug asli 2026-11-25: keduanya tidak disambung, output_dir diabaikan diam-diam dan hasil
// selalu jatuh ke folder cadangan. Tes ini memastikan output_dir lewat MCP benar-benar dipakai.
test('regresi: output_dir lewat MCP dipakai, tidak jatuh ke cadangan', async () => {
  const proyek = await mkdtemp(join(tmpdir(), 'dci-tts-regresi-'));
  const { klien, tutup } = await sambungkan({
    balasan: [{ body: MP3_PALSU }],
    env: { NINEROUTER_URL: URL_UJI, NINEROUTER_KEY: KEY_UJI },
    cwd: proyek,
    home: 'C:\\Users\\uji',
  });
  try {
    const tujuan = join(proyek, 'hasil-khusus');
    const r = await klien.callTool({
      name: 'text_to_speech',
      arguments: { segments: 'Uji regresi folder output.', voice: 'edge-tts/id-ID-ArdiNeural', output_dir: tujuan },
    });
    assert.equal(r.isError, false);
    assert.ok(r.content[0].text.includes(tujuan), 'hasil harus di output_dir yang diminta');
    assert.ok(r.content[0].text.includes('PERHATIAN') === false, 'tidak boleh masuk folder cadangan');
  } finally {
    await tutup();
    await rm(proyek, { recursive: true, force: true }).catch(() => {});
  }
});

test('text_to_speech tanpa kredensial -> jawaban error konfigurasi yang jelas', async () => {
  const { klien, tutup } = await sambungkan({ env: {}, cwd: 'C:\\p', home: 'C:\\Users\\uji' });
  try {
    const r = await klien.callTool({ name: 'text_to_speech', arguments: { segments: 'Uji tanpa kredensial.' } });
    assert.equal(r.isError, true);
    assert.ok(r.content[0].text.includes('~/.9router/env'));
  } finally {
    await tutup();
  }
});

test('7 adegan tanpa confirmed -> error minta konfirmasi; dengan confirmed jalan', async () => {
  const tujuh = Array(7).fill('adegan naskah uji konfirmasi');
  const proyek = await mkdtemp(join(tmpdir(), 'dci-tts-konf-'));
  const { klien, tutup } = await sambungkan({
    balasan: Array(7).fill({ body: MP3_PALSU }),
    env: { NINEROUTER_URL: URL_UJI, NINEROUTER_KEY: KEY_UJI },
    cwd: proyek,
    home: 'C:\\Users\\uji',
  });
  try {
    const r1 = await klien.callTool({ name: 'text_to_speech', arguments: { segments: tujuh } });
    assert.equal(r1.isError, true);
    assert.ok(r1.content[0].text.includes('confirmed=true'));

    const r2 = await klien.callTool({ name: 'text_to_speech', arguments: { segments: tujuh, confirmed: true } });
    assert.equal(r2.isError, false);
    assert.ok(r2.content[0].text.includes('7 dari 7 audio tersimpan'));
  } finally {
    await tutup();
    await rm(proyek, { recursive: true, force: true }).catch(() => {});
  }
});
