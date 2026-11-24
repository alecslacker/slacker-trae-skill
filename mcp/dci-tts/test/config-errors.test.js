// dci-tts — tes config.js dan errors.js.
// Author: Mas Wondho — Duta Corpora Indonesia (DCI)
// Copyright © 2026 Duta Corpora Indonesia

import test from 'node:test';
import assert from 'node:assert/strict';
import { muatKonfigurasi, uraiTeksEnv } from '../src/config.js';
import { DciError, sensor, petakanGalatHttp } from '../src/errors.js';
import { buatEnvSementara, KEY_UJI, URL_UJI } from './helpers.js';

test('uraiTeksEnv: biasa, kutip, komentar, BOM', () => {
  const teks = '\uFEFF# komentar\nNINEROUTER_URL=https://a.b\nNINEROUTER_KEY="abc"\n\nX=\'y\'\n';
  const h = uraiTeksEnv(teks);
  assert.equal(h.NINEROUTER_URL, 'https://a.b');
  assert.equal(h.NINEROUTER_KEY, 'abc');
  assert.equal(h.X, 'y');
});

test('muatKonfigurasi: berkas lengkap menghasilkan baseUrl + key', async () => {
  const env = await buatEnvSementara();
  try {
    const k = await muatKonfigurasi({ berkasEnv: env.path });
    assert.equal(k.baseUrl, URL_UJI);
    assert.equal(k.key, KEY_UJI);
  } finally {
    await env.bersih();
  }
});

test('muatKonfigurasi: env menimpa berkas; berkas hilang tetap jalan bila env ada', async () => {
  const k = await muatKonfigurasi({ berkasEnv: 'z:/tak/ada/env', env: { NINEROUTER_URL: URL_UJI, NINEROUTER_KEY: KEY_UJI } });
  assert.equal(k.key, KEY_UJI);
});

test('muatKonfigurasi: tanpa kredensial -> DciError konfigurasi', async () => {
  await assert.rejects(() => muatKonfigurasi({ berkasEnv: 'z:/tak/ada/env', env: {} }), (e) => e instanceof DciError && e.code === 'konfigurasi');
});

test('muatKonfigurasi: URL http non-lokal ditolak', async () => {
  const env = await buatEnvSementara({ url: 'http://9router-uji.example.com' });
  try {
    await assert.rejects(() => muatKonfigurasi({ berkasEnv: env.path }), (e) => e instanceof DciError && e.code === 'konfigurasi');
  } finally {
    await env.bersih();
  }
});

test('muatKonfigurasi: http localhost diperbolehkan; trailing slash dirapikan', async () => {
  const env = await buatEnvSementara({ url: 'http://localhost:9999/' });
  try {
    const k = await muatKonfigurasi({ berkasEnv: env.path });
    assert.equal(k.baseUrl, 'http://localhost:9999');
  } finally {
    await env.bersih();
  }
});

test('sensor: menyembunyikan pola key', () => {
  const t = sensor('gagal dengan sk-abcdef1234567890 dan Bearer xyz987654321');
  assert.ok(!t.includes('sk-abcdef1234567890'));
  assert.ok(t.includes('[disensor]'));
});

test('petakanGalatHttp: 400 memuat contoh suara valid', () => {
  const e = petakanGalatHttp(400, '{"error":{"message":"bad voice"}}', null);
  assert.equal(e.code, 'permintaan');
  assert.ok(e.message.includes('edge-tts/id-ID-ArdiNeural'));
  assert.ok(e.message.includes('bad voice'));
});

test('petakanGalatHttp: 429 memuat retry-after bila angka', () => {
  const e = petakanGalatHttp(429, '', '7');
  assert.equal(e.code, 'tidak_tersedia');
  assert.ok(e.message.includes('7 detik'));
});
