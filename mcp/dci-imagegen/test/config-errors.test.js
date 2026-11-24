// Uji: konfigurasi kredensial, penyensoran, pemetaan galat HTTP.
// Author: Mas Wondho — Duta Corpora Indonesia (DCI)
// Copyright © 2026 Duta Corpora Indonesia

import assert from 'node:assert/strict';
import { writeFile } from 'node:fs/promises';
import { join } from 'node:path';
import test from 'node:test';
import { muatKonfigurasi, uraiTeksEnv } from '../src/config.js';
import { DciError, petakanGalatHttp, sensor } from '../src/errors.js';
import { folderSementara } from './helpers.js';

test('uraiTeksEnv: komentar, kutip, BOM, CRLF', () => {
  const h = uraiTeksEnv('\uFEFF# catatan\r\nNINEROUTER_URL="https://a.example"\r\nNINEROUTER_KEY=\'sk-abc\'\r\n\r\nKOSONG=\r\n');
  assert.equal(h.NINEROUTER_URL, 'https://a.example');
  assert.equal(h.NINEROUTER_KEY, 'sk-abc');
  assert.equal(h.KOSONG, '');
});

test('muatKonfigurasi: dari berkas, lalu environment menimpa', async () => {
  const t = await folderSementara();
  try {
    const berkas = join(t.dir, 'env');
    await writeFile(berkas, 'NINEROUTER_URL=https://router.example/\nNINEROUTER_KEY=sk-dari-berkas\n');
    const a = await muatKonfigurasi({ env: {}, berkasEnv: berkas });
    assert.deepEqual(a, { baseUrl: 'https://router.example', key: 'sk-dari-berkas' });
    const b = await muatKonfigurasi({ env: { NINEROUTER_KEY: 'sk-dari-env' }, berkasEnv: berkas });
    assert.equal(b.key, 'sk-dari-env');
  } finally {
    await t.bersihkan();
  }
});

test('muatKonfigurasi: berkas tidak ada dan env kosong -> galat konfigurasi', async () => {
  await assert.rejects(
    () => muatKonfigurasi({ env: {}, berkasEnv: join('Z:\\tidak', 'ada', 'env') }),
    (e) => e instanceof DciError && e.code === 'konfigurasi' && /belum lengkap/.test(e.message),
  );
});

test('muatKonfigurasi: http hanya untuk localhost', async () => {
  const ok = await muatKonfigurasi({ env: { NINEROUTER_URL: 'http://127.0.0.1:20128', NINEROUTER_KEY: 'sk-x' }, berkasEnv: 'Z:\\tidak\\ada' });
  assert.equal(ok.baseUrl, 'http://127.0.0.1:20128');
  await assert.rejects(
    () => muatKonfigurasi({ env: { NINEROUTER_URL: 'http://router.example', NINEROUTER_KEY: 'sk-x' }, berkasEnv: 'Z:\\tidak\\ada' }),
    /wajib https/,
  );
  await assert.rejects(
    () => muatKonfigurasi({ env: { NINEROUTER_URL: 'bukan url', NINEROUTER_KEY: 'sk-x' }, berkasEnv: 'Z:\\tidak\\ada' }),
    /bukan URL/,
  );
});

test('sensor: kunci dan Bearer tidak lolos', () => {
  const s = sensor('gagal dengan sk-abcdef1234567890 dan Bearer abc.def.ghi123456');
  assert.ok(!/sk-abcdef/.test(s));
  assert.ok(!/abc\.def\.ghi/.test(s));
  assert.match(s, /\[disensor\]/);
});

test('petakanGalatHttp: kode umum dan retry-after', () => {
  assert.equal(petakanGalatHttp(401, '', null).code, 'auth');
  assert.match(petakanGalatHttp(400, JSON.stringify({ error: { message: 'model salah' } }), null).message, /model salah/);
  const e503 = petakanGalatHttp(503, '', '30');
  assert.equal(e503.code, 'tidak_tersedia');
  assert.match(e503.message, /30 detik/);
  assert.equal(petakanGalatHttp(500, 'boom', null).code, 'upstream');
});

test('petakanGalatHttp: badan galat yang memuat key disensor', () => {
  const e = petakanGalatHttp(400, JSON.stringify({ error: { message: 'token sk-rahasia1234567890 salah' } }), null);
  assert.ok(!/sk-rahasia/.test(e.message));
});
