// dci-tts — orkestrasi pembuatan suara: validasi, batch paralel, simpan hasil.
// Author: Mas Wondho — Duta Corpora Indonesia (DCI)
// Copyright © 2026 Duta Corpora Indonesia

import { mkdir, open } from 'node:fs/promises';
import { join } from 'node:path';
import { DciError, sensor } from './errors.js';
import { tentukanFolder } from './folders.js';

export const SUARA_BAWAAN = 'edge-tts/id-ID-ArdiNeural';
export const BATAS_LANGSUNG = 6; // total adegan di atas ini wajib konfirmasi (antisipasi provider premium)
export const BATAS_MUTLAK = 10;
export const PARALEL = 2;
export const MIN_KARAKTER = 3;
export const MAKS_KARAKTER = 5000;

// Normalisasi segments: string tunggal -> satu adegan; array -> tiap elemen satu adegan.
export function rapikanSegments(segments) {
  if (typeof segments === 'string') return [segments];
  if (Array.isArray(segments)) return [...segments];
  return null;
}

// Validasi seluruh adegan SEBELUM menyentuh jaringan, jadi pelanggaran tidak memanggil server.
export function periksaSegments(daftar, confirmed) {
  if (!daftar || daftar.length === 0) {
    throw new DciError('segments', 'segments kosong. Isi satu teks atau daftar teks per adegan.');
  }
  if (daftar.length > BATAS_MUTLAK) {
    throw new DciError('segments', `Jumlah adegan maksimal ${BATAS_MUTLAK} per permintaan.`);
  }
  if (daftar.length > BATAS_LANGSUNG && confirmed !== true) {
    throw new DciError(
      'perlu_konfirmasi',
      `Memproses ${daftar.length} adegan melebihi batas ${BATAS_LANGSUNG}. Bila provider suara berbayar, ini memakai kuota lebih banyak. ` +
        'Tanyakan dulu ke pengguna, lalu panggil ulang dengan confirmed=true.',
    );
  }
  for (let i = 0; i < daftar.length; i++) {
    const t = daftar[i];
    if (typeof t !== 'string' || t.trim().length < MIN_KARAKTER) {
      throw new DciError('segments', `Adegan nomor ${i + 1} terlalu pendek (minimal ${MIN_KARAKTER} karakter).`);
    }
    if (t.length > MAKS_KARAKTER) {
      throw new DciError(
        'segments',
        `Adegan nomor ${i + 1} melebihi ${MAKS_KARAKTER} karakter. Pecah naskah menjadi beberapa adegan, lalu panggil ulang.`,
      );
    }
  }
}

export function buatSlug(teks) {
  const s = String(teks)
    .normalize('NFKD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 40)
    .replace(/-+$/, '');
  return s || 'audio';
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
      throw new DciError('simpan', `Tidak bisa menyimpan audio ke ${folder} (${e?.code || 'kesalahan'}).`);
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

export async function buatSuaraBatch({ klien, parameter, lingkungan = {}, sinyal, progres, sekarang = () => new Date() }) {
  const { voice = SUARA_BAWAAN, segments, outputDir, confirmed } = parameter;

  const daftar = rapikanSegments(segments);
  periksaSegments(daftar, confirmed);

  // Tahap lokal dulu (tanpa jaringan): tentukan folder.
  const { folder, cadangan } = tentukanFolder({
    outputDir,
    env: lingkungan.env,
    cwd: lingkungan.cwd,
    home: lingkungan.home,
  });

  await mkdir(folder, { recursive: true });
  const dasarNama = `${buatSlug(daftar[0])}_${stempel(sekarang())}`;
  const berhasil = [];
  const gagal = [];
  let berhenti = false;
  progres?.({ selesai: 0, total: daftar.length });

  await paralel(daftar.length, PARALEL, async (i) => {
    const nomor = i + 1;
    if (berhenti) {
      gagal.push({ nomor, alasan: 'Dilewati karena kesalahan otorisasi pada adegan sebelumnya.' });
      return;
    }
    const mulai = Date.now();
    try {
      const { bytes, jenis } = await klien.buatSuara({ voice, input: daftar[i] }, sinyal);
      const path = await simpanEksklusif(folder, `${dasarNama}_${nomor}`, jenis.ext, bytes);
      berhasil.push({
        nomor,
        path,
        voice,
        ukuran_kb: Math.round(bytes.length / 1024),
        detik: Math.round((Date.now() - mulai) / 100) / 10,
      });
    } catch (e) {
      const alasan = e instanceof DciError ? e.message : `Kesalahan tak terduga (${sensor(e?.code || e?.name || 'tak dikenal')}).`;
      gagal.push({ nomor, alasan });
      if (e instanceof DciError && (e.code === 'auth' || e.code === 'konfigurasi')) berhenti = true;
    }
    progres?.({ selesai: berhasil.length + gagal.length, total: daftar.length });
  });

  berhasil.sort((a, b) => a.nomor - b.nomor);
  gagal.sort((a, b) => a.nomor - b.nomor);
  return { voice, jumlah_diminta: daftar.length, folder, folder_cadangan: cadangan, berhasil, gagal };
}
