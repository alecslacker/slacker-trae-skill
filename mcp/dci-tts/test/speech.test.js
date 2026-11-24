// dci-tts — tes orkestrasi speech.js (validasi, batch, paralel, gagal per adegan).
// Author: Mas Wondho — Duta Corpora Indonesia (DCI)
// Copyright © 2026 Duta Corpora Indonesia

import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { join } from 'node:path';
import { DciError } from '../src/errors.js';
import { buatKlienRouter } from '../src/router-client.js';
import { buatSuaraBatch, periksaSegments, rapikanSegments, BATAS_MUTLAK } from '../src/speech.js';
import { stubFetch, MP3_PALSU, folderKerja, KEY_UJI, URL_UJI } from './helpers.js';

const klienDengan = (balasan) => buatKlienRouter({ baseUrl: URL_UJI, key: KEY_UJI, fetchImpl: stubFetch(balasan) });

test('rapikanSegments: string tunggal dan array', () => {
  assert.deepEqual(rapikanSegments('satu'), ['satu']);
  assert.deepEqual(rapikanSegments(['a', 'b']), ['a', 'b']);
  assert.equal(rapikanSegments(42), null);
});

test('periksaSegments: menolak kosong, terlalu pendek, dan melewati batas mutlak', () => {
  assert.throws(() => periksaSegments([], true), (e) => e.code === 'segments');
  assert.throws(() => periksaSegments(['ab'], true), (e) => e.code === 'segments');
  assert.throws(() => periksaSegments(Array(BATAS_MUTLAK + 1).fill('teks cukup panjang'), true), (e) => e.code === 'segments');
});

test('periksaSegments: 7 adegan tanpa konfirmasi minta konfirmasi', () => {
  const tujuh = Array(7).fill('adegan dengan teks cukup');
  assert.throws(() => periksaSegments(tujuh), (e) => e.code === 'perlu_konfirmasi');
  periksaSegments(tujuh, true); // tidak melempar
});

test('periksaSegments: adegan di atas 5000 karakter ditolak', () => {
  assert.throws(() => periksaSegments(['x'.repeat(5001)], true), (e) => e.code === 'segments' && e.message.includes('5000'));
});

test('buatSuaraBatch: satu adegan tersimpan sebagai mp3 valid', async () => {
  const klien = klienDengan([{ body: MP3_PALSU }]);
  const proyek = await folderKerja();
  try {
    const h = await buatSuaraBatch({
      klien,
      parameter: { segments: 'Halo ini uji suara tunggal.', outputDir: proyek },
    });
    assert.equal(h.berhasil.length, 1);
    assert.equal(h.folder_cadangan, false);
    const isi = await readFile(h.berhasil[0].path);
    assert.ok(isi.subarray(0, 2).equals(MP3_PALSU.subarray(0, 2)));
    assert.ok(h.berhasil[0].path.endsWith('.mp3'));
  } finally {
    await rm(proyek, { recursive: true, force: true }).catch(() => {});
  }
});

test('buatSuaraBatch: batch 3 adegan, 1 gagal -> lainnya tetap jadi', async () => {
  const klien = klienDengan([
    { body: MP3_PALSU },
    { status: 400, body: Buffer.from('{"error":{"message":"suara aneh"}}') },
    { body: MP3_PALSU },
  ]);
  const proyek = await folderKerja();
  try {
    const h = await buatSuaraBatch({
      klien,
      parameter: { segments: ['adegan satu naskah', 'adegan dua naskah', 'adegan tiga naskah'], outputDir: proyek, confirmed: true },
    });
    assert.equal(h.berhasil.length, 2);
    assert.equal(h.gagal.length, 1);
    assert.equal(h.gagal[0].nomor, 2);
    assert.ok(h.gagal[0].alasan.includes('suara aneh'));
    assert.ok(h.gagal[0].alasan.includes('edge-tts/id-ID-ArdiNeural')); // saran suara valid
  } finally {
    await rm(proyek, { recursive: true, force: true }).catch(() => {});
  }
});

test('buatSuaraBatch: gagal auth menghentikan adegan yang belum mulai', async () => {
  const klien = klienDengan([{ status: 401, body: Buffer.from('{"error":{"message":"no"}}') }, { body: MP3_PALSU }, { body: MP3_PALSU }]);
  const proyek = await folderKerja();
  try {
    const h = await buatSuaraBatch({
      klien,
      parameter: { segments: ['a satu dua', 'b satu dua', 'c satu dua'], outputDir: proyek, confirmed: true },
    });
    // Adegan 1 gagal 401 dan menyalakan sinyal berhenti; adegan 3 harus dilewati.
    // Adegan 2 sudah mulai sebelum sinyal menyala, jadi boleh selesai (perilaku paralel yang benar).
    assert.equal(h.gagal[0].nomor, 1);
    assert.ok(h.gagal[0].alasan.includes('401'));
    const dilewati = h.gagal.find((g) => g.alasan.includes('Dilewati'));
    assert.ok(dilewati, 'harus ada adegan yang dilewati');
    assert.equal(dilewati.nomor, 3);
    assert.ok(h.berhasil.every((b) => b.nomor !== 1 && b.nomor !== 3));
  } finally {
    await rm(proyek, { recursive: true, force: true }).catch(() => {});
  }
});

test('buatSuaraBatch: tidak pernah menimpa berkas yang sudah ada', async () => {
  const klien = klienDengan([{ body: MP3_PALSU }, { body: MP3_PALSU }]);
  const proyek = await folderKerja();
  try {
    const h1 = await buatSuaraBatch({ klien, parameter: { segments: 'dua kali panggilan uji.', outputDir: proyek } });
    const h2 = await buatSuaraBatch({ klien, parameter: { segments: 'dua kali panggilan uji.', outputDir: proyek } });
    assert.notEqual(h1.berhasil[0].path, h2.berhasil[0].path);
  } finally {
    await rm(proyek, { recursive: true, force: true }).catch(() => {});
  }
});

test('buatSuaraBatch: progres dipanggil sampai total', async () => {
  const klien = klienDengan([{ body: MP3_PALSU }, { body: MP3_PALSU }]);
  const proyek = await folderKerja();
  const panggilan = [];
  try {
    await buatSuaraBatch({
      klien,
      parameter: { segments: ['pertama naskah uji', 'kedua naskah uji'], outputDir: proyek },
      progres: (p) => panggilan.push(p),
    });
    assert.equal(panggilan.at(-1).total, 2);
    assert.equal(panggilan.at(-1).selesai, 2);
  } finally {
    await rm(proyek, { recursive: true, force: true }).catch(() => {});
  }
});

test('buatSuaraBatch: output_dir relatif ditolak sebelum jaringan', async () => {
  const klien = klienDengan([]);
  await assert.rejects(
    () => buatSuaraBatch({ klien, parameter: { segments: 'teks relatif uji.', outputDir: 'folder-relatif' } }),
    (e) => e instanceof DciError && e.code === 'output_dir',
  );
});

// Pola import rm dipakai di beberapa tes di atas.
import { rm } from 'node:fs/promises';
