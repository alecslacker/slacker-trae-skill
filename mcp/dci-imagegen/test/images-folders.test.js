// Uji: pengenalan gambar dari byte, gambar referensi, penentuan folder.
// Author: Mas Wondho — Duta Corpora Indonesia (DCI)
// Copyright © 2026 Duta Corpora Indonesia

import assert from 'node:assert/strict';
import { lstat, symlink, writeFile } from 'node:fs/promises';
import { join } from 'node:path';
import test from 'node:test';
import { tentukanFolder } from '../src/folders.js';
import { MAKS_BYTE_REFERENSI, bacaReferensi, kenaliGambar, pasangLstatUji, ukuranPiksel } from '../src/images.js';
import { buatJpeg, buatPng, folderSementara } from './helpers.js';

test('kenaliGambar: PNG, JPEG, WEBP dikenali; teks ditolak', () => {
  assert.equal(kenaliGambar(buatPng()).ext, 'png');
  assert.equal(kenaliGambar(buatJpeg()).ext, 'jpg');
  const webp = Buffer.concat([Buffer.from('RIFF'), Buffer.alloc(4), Buffer.from('WEBP')]);
  assert.equal(kenaliGambar(webp).ext, 'webp');
  assert.equal(kenaliGambar(Buffer.from('ini bukan gambar sama sekali')), null);
});

test('ukuranPiksel: PNG dan JPEG', () => {
  assert.equal(ukuranPiksel(buatPng(1774, 887), { ext: 'png' }), '1774x887');
  assert.equal(ukuranPiksel(buatJpeg(40, 20), { ext: 'jpg' }), '40x20');
});

test('bacaReferensi: gambar asli lolos, teks berekstensi .png ditolak', async () => {
  const t = await folderSementara();
  try {
    const asli = join(t.dir, 'a.png');
    const palsu = join(t.dir, 'rahasia.png');
    await writeFile(asli, buatPng());
    await writeFile(palsu, 'password=abc123');
    const r = await bacaReferensi(asli);
    assert.match(r.dataUrl, /^data:image\/png;base64,/);
    await assert.rejects(() => bacaReferensi(palsu), /bukan gambar/);
  } finally {
    await t.bersihkan();
  }
});

test('bacaReferensi: berkas gambar di atas 10 MB ditolak, tepat 10 MB diterima', async () => {
  const t = await folderSementara();
  try {
    const kepala = buatPng();
    const pas = join(t.dir, 'pas.png');
    const besar = join(t.dir, 'besar.png');
    await writeFile(pas, Buffer.concat([kepala, Buffer.alloc(MAKS_BYTE_REFERENSI - kepala.length)]));
    await writeFile(besar, Buffer.concat([kepala, Buffer.alloc(MAKS_BYTE_REFERENSI + 1 - kepala.length)]));
    assert.equal((await bacaReferensi(pas)).byte, MAKS_BYTE_REFERENSI);
    await assert.rejects(() => bacaReferensi(besar), /melebihi 10 MB/);
  } finally {
    await t.bersihkan();
  }
});

test('bacaReferensi: path relatif, UNC, dan berkas tak ada ditolak', async () => {
  await assert.rejects(() => bacaReferensi('relatif.png'), /absolut/);
  await assert.rejects(() => bacaReferensi('\\\\server\\share\\a.png'), /UNC/);
  await assert.rejects(() => bacaReferensi(join('Z:\\', 'tidak', 'ada.png')), /tidak ditemukan/);
});

test('bacaReferensi: symlink ditolak (lstat dipalsukan, tidak butuh hak Administrator)', async () => {
  const t = await folderSementara();
  const lepas = pasangLstatUji(async (p) => {
    const st = await lstat(p);
    return new Proxy(st, { get: (o, k) => (k === 'isSymbolicLink' ? () => true : typeof o[k] === 'function' ? o[k].bind(o) : o[k]) });
  });
  try {
    const berkas = join(t.dir, 'a.png');
    await writeFile(berkas, buatPng());
    await assert.rejects(() => bacaReferensi(berkas), /Symlink/);
  } finally {
    lepas();
    await t.bersihkan();
  }
  // Setelah dilepas, berkas yang sama kembali diterima: bukti pemalsuan tidak bocor ke tes lain.
  const t2 = await folderSementara();
  try {
    const berkas = join(t2.dir, 'b.png');
    await writeFile(berkas, buatPng());
    assert.equal((await bacaReferensi(berkas)).ext, 'png');
  } finally {
    await t2.bersihkan();
  }
});

test('bacaReferensi: symlink asli ditolak bila OS mengizinkan membuatnya', async (ctx) => {
  const t = await folderSementara();
  try {
    const asli = join(t.dir, 'a.png');
    const tautan = join(t.dir, 'tautan.png');
    await writeFile(asli, buatPng());
    try {
      await symlink(asli, tautan);
    } catch {
      ctx.skip('Windows tanpa hak Administrator tidak bisa membuat symlink; ditutup oleh uji lstat di atas');
      return;
    }
    await assert.rejects(() => bacaReferensi(tautan), /Symlink/);
  } finally {
    await t.bersihkan();
  }
});

test('tentukanFolder: output_dir eksplisit dipakai apa adanya', () => {
  const r = tentukanFolder({ outputDir: 'D:\\Proyek\\a\\generated-images', env: {}, cwd: 'C:\\Users\\x', home: 'C:\\Users\\x' });
  assert.equal(r.folder, 'D:\\Proyek\\a\\generated-images');
  assert.equal(r.cadangan, false);
});

test('tentukanFolder: output_dir relatif, akar drive, dan folder sistem ditolak', () => {
  const env = { WINDIR: 'C:\\Windows', ProgramFiles: 'C:\\Program Files' };
  assert.throws(() => tentukanFolder({ outputDir: 'gambar', env }), /absolut/);
  assert.throws(() => tentukanFolder({ outputDir: 'C:\\', env }), /akar drive/);
  assert.throws(() => tentukanFolder({ outputDir: 'C:\\Windows\\System32', env }), /sistem/);
  assert.throws(() => tentukanFolder({ outputDir: 'C:\\Program Files\\App', env }), /sistem/);
});

test('tentukanFolder: urutan env proyek, cwd aman, lalu folder cadangan', () => {
  const home = 'C:\\Users\\x';
  const env = { WINDIR: 'C:\\Windows' };
  const a = tentukanFolder({ env: { ...env, CLAUDE_PROJECT_DIR: 'D:\\P' }, cwd: 'D:\\Lain', home });
  assert.equal(a.folder, 'D:\\P\\generated-images');
  const b = tentukanFolder({ env, cwd: 'D:\\Lain', home });
  assert.equal(b.folder, 'D:\\Lain\\generated-images');
  const c = tentukanFolder({ env, cwd: home, home });
  assert.equal(c.cadangan, true);
  assert.equal(c.folder, 'C:\\Users\\x\\Pictures\\dci-imagegen');
  const d = tentukanFolder({ env, cwd: 'C:\\Windows\\System32', home });
  assert.equal(d.cadangan, true);
});
