// Uji: orkestrasi buatGambar terhadap server 9router palsu (tanpa kuota).
// Author: Mas Wondho — Duta Corpora Indonesia (DCI)
// Copyright © 2026 Duta Corpora Indonesia

import assert from 'node:assert/strict';
import { readFile, readdir, writeFile } from 'node:fs/promises';
import { join } from 'node:path';
import test from 'node:test';
import { DciError } from '../src/errors.js';
import { MODEL_BAWAAN, buatGambar, buatSlug, periksaJumlah } from '../src/generate.js';
import { buatKlienRouter } from '../src/router-client.js';
import { KEY_UJI, buatPng, folderSementara, mulaiRouterPalsu } from './helpers.js';

async function siapkan(opsi = {}) {
  const router = await mulaiRouterPalsu(opsi);
  const t = await folderSementara();
  const klien = buatKlienRouter({ baseUrl: router.url, key: opsi.key ?? KEY_UJI, batasWaktuMs: 5000 });
  const lingkungan = { env: { WINDIR: 'C:\\Windows' }, cwd: t.dir, home: 'C:\\Users\\tidak-dipakai' };
  return { router, t, klien, lingkungan, tutup: async () => { await router.tutup(); await t.bersihkan(); } };
}

test('periksaJumlah: batas 4 langsung, 5-8 butuh konfirmasi, di atas 8 mutlak ditolak', () => {
  assert.doesNotThrow(() => periksaJumlah(1));
  assert.doesNotThrow(() => periksaJumlah(4));
  assert.throws(() => periksaJumlah(5), (e) => e instanceof DciError && e.code === 'perlu_konfirmasi');
  assert.throws(() => periksaJumlah(5, false), /konfirmasi/);
  assert.doesNotThrow(() => periksaJumlah(5, true));
  assert.doesNotThrow(() => periksaJumlah(8, true));
  assert.throws(() => periksaJumlah(9, true), (e) => e.code === 'jumlah');
  assert.throws(() => periksaJumlah(0), (e) => e.code === 'jumlah');
  assert.throws(() => periksaJumlah(2.5), (e) => e.code === 'jumlah');
});

test('buatSlug: aman untuk nama berkas', () => {
  assert.equal(buatSlug('Logo "Duta Corpora" / Indonesia!!'), 'logo-duta-corpora-indonesia');
  assert.equal(buatSlug('???'), 'gambar');
  assert.equal(buatSlug('../../etc/passwd'), 'etc-passwd');
  assert.ok(buatSlug('a'.repeat(200)).length <= 40);
});

test('n=5 tanpa confirmed ditolak dan TIDAK ada panggilan ke 9router sama sekali', async () => {
  const s = await siapkan();
  try {
    await assert.rejects(
      () => buatGambar({ klien: s.klien, parameter: { prompt: 'logo uji', n: 5 }, lingkungan: s.lingkungan }),
      (e) => e.code === 'perlu_konfirmasi',
    );
    assert.equal(s.router.panggilan.length, 0);
  } finally {
    await s.tutup();
  }
});

test('n=1: satu gambar tersimpan, model bawaan dipakai, ukuran terbaca, key terkirim', async () => {
  const s = await siapkan({ generate: () => ({ status: 200, body: buatPng(1774, 887) }) });
  try {
    const h = await buatGambar({ klien: s.klien, parameter: { prompt: 'Logo Duta Corpora', outputDir: join(s.t.dir, 'keluar') }, lingkungan: s.lingkungan });
    assert.equal(h.berhasil.length, 1);
    assert.equal(h.gagal.length, 0);
    assert.equal(h.model, MODEL_BAWAAN);
    assert.equal(h.berhasil[0].ukuran_px, '1774x887');
    assert.match(h.berhasil[0].path, /logo-duta-corpora_\d{8}-\d{6}_1\.png$/);
    assert.deepEqual((await readFile(h.berhasil[0].path)).subarray(0, 4), Buffer.from([0x89, 0x50, 0x4e, 0x47]));
    const gen = s.router.panggilan.find((p) => p.path === '/v1/images/generations');
    assert.equal(gen.auth, `Bearer ${KEY_UJI}`);
    assert.match(gen.query, /response_format=binary/);
    assert.equal(JSON.parse(gen.badan).model, MODEL_BAWAAN);
  } finally {
    await s.tutup();
  }
});

test('n=3 varian: tiga berkas berbeda dan tidak pernah menimpa berkas lama', async () => {
  const s = await siapkan();
  try {
    const tetap = new Date(2026, 10, 24, 10, 0, 0);
    const param = { prompt: 'varian logo', n: 3, outputDir: join(s.t.dir, 'v') };
    const a = await buatGambar({ klien: s.klien, parameter: param, lingkungan: s.lingkungan, sekarang: () => tetap });
    assert.equal(a.berhasil.length, 3);
    assert.equal(new Set(a.berhasil.map((x) => x.path)).size, 3);
    const b = await buatGambar({ klien: s.klien, parameter: param, lingkungan: s.lingkungan, sekarang: () => tetap });
    assert.equal(b.berhasil.length, 3);
    assert.equal((await readdir(join(s.t.dir, 'v'))).length, 6);
    assert.ok(b.berhasil.some((x) => /_1-1\.png$/.test(x.path)), 'nama bentrok harus diberi akhiran');
  } finally {
    await s.tutup();
  }
});

test('kegagalan sebagian: yang sukses tetap tersimpan, yang gagal dilaporkan per nomor', async () => {
  const s = await siapkan({
    generate: (i) => (i === 1 ? { status: 503, body: JSON.stringify({ error: { message: 'semua akun habis' } }), headers: { 'retry-after': '45' } } : { status: 200, body: buatPng() }),
  });
  try {
    const h = await buatGambar({ klien: s.klien, parameter: { prompt: 'uji sebagian', n: 3, outputDir: join(s.t.dir, 'p') }, lingkungan: s.lingkungan });
    assert.equal(h.berhasil.length, 2);
    assert.equal(h.gagal.length, 1);
    assert.match(h.gagal[0].alasan, /45 detik/);
    assert.equal((await readdir(join(s.t.dir, 'p'))).length, 2);
  } finally {
    await s.tutup();
  }
});

test('key salah: galat auth, gambar berikutnya dilewati (tidak membakar kuota percuma)', async () => {
  const s = await siapkan({ key: 'sk-salah-salah-salah' });
  try {
    await assert.rejects(
      () => buatGambar({ klien: s.klien, parameter: { prompt: 'uji auth', n: 3, outputDir: join(s.t.dir, 'x') }, lingkungan: s.lingkungan }),
      (e) => e.code === 'auth',
    );
    assert.equal(s.router.jumlahGenerate(), 0);
  } finally {
    await s.tutup();
  }
});

test('key ditolak saat generate: sisa antrean dilewati, tidak membakar kuota percuma', async () => {
  // Daftar model lolos, tetapi setiap generate dibalas 401 (misalnya akun penyedia dicabut di tengah jalan).
  const s = await siapkan({ generate: () => ({ status: 401, body: JSON.stringify({ error: { message: 'token dicabut' } }) }) });
  try {
    const h = await buatGambar({ klien: s.klien, parameter: { prompt: 'uji antrean', n: 4, outputDir: join(s.t.dir, 'a') }, lingkungan: s.lingkungan });
    assert.equal(h.berhasil.length, 0);
    assert.equal(h.gagal.length, 4);
    assert.equal(h.gagal.filter((g) => /Dilewati/.test(g.alasan)).length, 2);
    assert.ok(s.router.jumlahGenerate() <= 2, `generate terpanggil ${s.router.jumlahGenerate()} kali, seharusnya paling banyak 2 (jumlah paralel)`);
  } finally {
    await s.tutup();
  }
});

test('model tidak ada di 9router: ditolak sebelum generate, tidak diganti diam-diam', async () => {
  const s = await siapkan();
  try {
    await assert.rejects(
      () => buatGambar({ klien: s.klien, parameter: { prompt: 'uji model', model: 'cx/tidak-ada' }, lingkungan: s.lingkungan }),
      (e) => e.code === 'model' && /Tersedia/.test(e.message),
    );
    assert.equal(s.router.jumlahGenerate(), 0);
  } finally {
    await s.tutup();
  }
});

test('edit: gambar referensi dikirim sebagai data URL pada field images', async () => {
  const s = await siapkan();
  try {
    const ref = join(s.t.dir, 'ref.png');
    await writeFile(ref, buatPng());
    const h = await buatGambar({ klien: s.klien, parameter: { prompt: 'ganti warna jadi emas', referensi: [ref], outputDir: join(s.t.dir, 'e') }, lingkungan: s.lingkungan });
    assert.equal(h.berhasil.length, 1);
    const badan = JSON.parse(s.router.panggilan.find((p) => p.path === '/v1/images/generations').badan);
    assert.equal(badan.images.length, 1);
    assert.match(badan.images[0], /^data:image\/png;base64,/);
  } finally {
    await s.tutup();
  }
});

test('edit: model tanpa kemampuan edit ditolak sebelum generate', async () => {
  const s = await siapkan({ info: { [MODEL_BAWAAN]: { name: 'Tanpa edit', capabilities: ['text2img'], params: [] } } });
  try {
    const ref = join(s.t.dir, 'ref.png');
    await writeFile(ref, buatPng());
    await assert.rejects(
      () => buatGambar({ klien: s.klien, parameter: { prompt: 'edit', referensi: [ref] }, lingkungan: s.lingkungan }),
      (e) => e.code === 'model' && /tidak mendukung edit/.test(e.message),
    );
    assert.equal(s.router.jumlahGenerate(), 0);
  } finally {
    await s.tutup();
  }
});

test('referensi lebih dari 4 berkas ditolak; referensi bukan gambar ditolak tanpa jaringan', async () => {
  const s = await siapkan();
  try {
    await assert.rejects(
      () => buatGambar({ klien: s.klien, parameter: { prompt: 'x banyak', referensi: ['a', 'b', 'c', 'd', 'e'] }, lingkungan: s.lingkungan }),
      /maksimal 4/,
    );
    const palsu = join(s.t.dir, 'bukan.png');
    await writeFile(palsu, 'isi rahasia');
    await assert.rejects(() => buatGambar({ klien: s.klien, parameter: { prompt: 'x palsu', referensi: [palsu] }, lingkungan: s.lingkungan }), /bukan gambar/);
    assert.equal(s.router.panggilan.length, 0);
  } finally {
    await s.tutup();
  }
});

test('respons bukan gambar dilaporkan sebagai kegagalan, tidak ada berkas tertulis', async () => {
  const s = await siapkan({ generate: () => ({ status: 200, body: Buffer.from('<html>halaman galat</html>') }) });
  try {
    const h = await buatGambar({ klien: s.klien, parameter: { prompt: 'uji bukan gambar', outputDir: join(s.t.dir, 'b') }, lingkungan: s.lingkungan });
    assert.equal(h.berhasil.length, 0);
    assert.match(h.gagal[0].alasan, /bukan gambar/);
    assert.equal((await readdir(join(s.t.dir, 'b'))).length, 0);
  } finally {
    await s.tutup();
  }
});

test('timeout: respons yang tertahan dilaporkan sebagai kegagalan dengan pesan jelas', async () => {
  const router = await mulaiRouterPalsu({ generate: () => new Promise(() => {}) });
  const t = await folderSementara();
  try {
    // Server palsu menahan respons selamanya; batas waktu klien dibuat sangat pendek.
    const klien = buatKlienRouter({ baseUrl: router.url, key: KEY_UJI, batasWaktuMs: 300 });
    const h = await buatGambar({
      klien,
      parameter: { prompt: 'uji timeout', outputDir: join(t.dir, 't') },
      lingkungan: { env: { WINDIR: 'C:\\Windows' }, cwd: t.dir, home: 'C:\\x' },
    });
    assert.equal(h.berhasil.length, 0);
    assert.equal(h.gagal.length, 1);
    assert.match(h.gagal[0].alasan, /tidak merespons/);
  } finally {
    await router.tutup();
    await t.bersihkan();
  }
});
