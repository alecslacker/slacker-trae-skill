// dci-imagegen — orkestrasi pembuatan gambar: validasi, varian paralel, simpan hasil.
// Author: Mas Wondho — Duta Corpora Indonesia (DCI)
// Copyright © 2026 Duta Corpora Indonesia

import { mkdir, open } from 'node:fs/promises';
import { join } from 'node:path';
import { DciError, sensor } from './errors.js';
import { tentukanFolder } from './folders.js';
import { bacaReferensi, ukuranPiksel } from './images.js';

export const MODEL_BAWAAN = 'cx/gpt-image-2.6-sunburst';
export const BATAS_LANGSUNG = 4;
export const BATAS_MUTLAK = 8;
export const MAKS_REFERENSI = 4;
export const PARALEL = 2;

// Batas jumlah dicek SEBELUM menyentuh jaringan, jadi pelanggaran tidak memakai kuota.
export function periksaJumlah(n, confirmed) {
  if (!Number.isInteger(n) || n < 1) throw new DciError('jumlah', 'Jumlah gambar (n) harus bilangan bulat minimal 1.');
  if (n > BATAS_MUTLAK) throw new DciError('jumlah', `Jumlah gambar maksimal ${BATAS_MUTLAK} per permintaan.`);
  if (n > BATAS_LANGSUNG && confirmed !== true) {
    throw new DciError(
      'perlu_konfirmasi',
      `Meminta ${n} gambar melebihi batas ${BATAS_LANGSUNG} tanpa konfirmasi dan memakai kuota ChatGPT lebih banyak. ` +
        'Tanyakan dulu ke pengguna, lalu panggil ulang dengan confirmed=true.',
    );
  }
}

export function buatSlug(prompt) {
  const s = String(prompt)
    .normalize('NFKD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 40)
    .replace(/-+$/, '');
  return s || 'gambar';
}

function stempel(d) {
  const p = (x) => String(x).padStart(2, '0');
  return `${d.getFullYear()}${p(d.getMonth() + 1)}${p(d.getDate())}-${p(d.getHours())}${p(d.getMinutes())}${p(d.getSeconds())}`;
}

// Mode 'wx': gagal bila berkas sudah ada, lalu coba akhiran berikutnya. Tidak pernah menimpa.
async function simpanEksklusif(folder, dasar, ext, bytes) {
  for (let i = 0; i < 100; i++) {
    const nama = i === 0 ? `${dasar}.${ext}` : `${dasar}-${i}.${ext}`;
    const path = join(folder, nama);
    let fh;
    try {
      fh = await open(path, 'wx');
    } catch (e) {
      if (e?.code === 'EEXIST') continue;
      throw new DciError('simpan', `Tidak bisa menyimpan gambar ke ${folder} (${e?.code || 'kesalahan'}).`);
    }
    try {
      await fh.writeFile(bytes);
    } finally {
      await fh.close();
    }
    return path;
  }
  throw new DciError('simpan', 'Terlalu banyak berkas dengan nama serupa di folder tujuan.');
}

async function paralel(jumlah, batas, kerja) {
  let berikut = 0;
  const pekerja = Array.from({ length: Math.min(batas, jumlah) }, async () => {
    for (;;) {
      const i = berikut++;
      if (i >= jumlah) return;
      await kerja(i);
    }
  });
  await Promise.all(pekerja);
}

export async function buatGambar({ klien, parameter, lingkungan = {}, sinyal, progres, sekarang = () => new Date() }) {
  const { prompt, model = MODEL_BAWAAN, n = 1, referensi = [], quality, outputDir, confirmed } = parameter;

  periksaJumlah(n, confirmed);
  if (referensi.length > MAKS_REFERENSI) {
    throw new DciError('referensi', `Gambar referensi maksimal ${MAKS_REFERENSI} berkas.`);
  }

  // Tahap lokal dulu (tanpa jaringan): baca referensi dan tentukan folder.
  const refs = [];
  for (const p of referensi) refs.push((await bacaReferensi(p)).dataUrl);
  const { folder, cadangan } = tentukanFolder({
    outputDir,
    env: lingkungan.env,
    cwd: lingkungan.cwd,
    home: lingkungan.home,
  });

  // Validasi model ke server (GET, tidak memakai kuota). Model tidak pernah diganti diam-diam.
  const ids = await klien.daftarModel(sinyal);
  if (!ids.includes(model)) {
    throw new DciError('model', `Model "${model}" tidak ada di 9router. Tersedia: ${ids.join(', ') || '(kosong)'}.`);
  }
  if (refs.length || quality) {
    const info = await klien.infoModel(model, sinyal);
    if (refs.length && !info.kemampuan.includes('edit')) {
      throw new DciError('model', `Model "${model}" tidak mendukung edit gambar referensi.`);
    }
    if (refs.length > 1 && !info.kemampuan.includes('multiImage')) {
      throw new DciError('model', `Model "${model}" tidak mendukung lebih dari satu gambar referensi.`);
    }
    if (quality && !info.params.includes('quality')) {
      throw new DciError('model', `Model "${model}" tidak mendukung parameter quality.`);
    }
  }

  await mkdir(folder, { recursive: true });
  const dasarNama = `${buatSlug(prompt)}_${stempel(sekarang())}`;
  const berhasil = [];
  const gagal = [];
  let berhenti = false;
  progres?.({ selesai: 0, total: n });

  await paralel(n, PARALEL, async (i) => {
    const nomor = i + 1;
    if (berhenti) {
      gagal.push({ nomor, alasan: 'Dilewati karena kesalahan otorisasi pada gambar sebelumnya.' });
      return;
    }
    const mulai = Date.now();
    try {
      const { bytes, jenis } = await klien.buatGambar({ model, prompt, referensi: refs, quality }, sinyal);
      const path = await simpanEksklusif(folder, `${dasarNama}_${nomor}`, jenis.ext, bytes);
      berhasil.push({
        nomor,
        path,
        model,
        ukuran_px: ukuranPiksel(bytes, jenis),
        ukuran_kb: Math.round(bytes.length / 1024),
        detik: Math.round((Date.now() - mulai) / 100) / 10,
      });
    } catch (e) {
      const alasan = e instanceof DciError ? e.message : `Kesalahan tak terduga (${sensor(e?.code || e?.name || 'tak dikenal')}).`;
      gagal.push({ nomor, alasan });
      if (e instanceof DciError && (e.code === 'auth' || e.code === 'konfigurasi')) berhenti = true;
    }
    progres?.({ selesai: berhasil.length + gagal.length, total: n });
  });

  berhasil.sort((a, b) => a.nomor - b.nomor);
  gagal.sort((a, b) => a.nomor - b.nomor);
  return { model, jumlah_diminta: n, folder, folder_cadangan: cadangan, berhasil, gagal };
}
