// dci-imagegen — pengenalan gambar dari byte asli dan pembacaan gambar referensi.
// Author: Mas Wondho — Duta Corpora Indonesia (DCI)
// Copyright © 2026 Duta Corpora Indonesia

import { lstat as lstatAsli, readFile } from 'node:fs/promises';
import { isAbsolute } from 'node:path';
import { DciError } from './errors.js';

export const MAKS_BYTE_REFERENSI = 10 * 1024 * 1024;

// Bisa diganti saat uji: di Windows symlink asli butuh hak Administrator, jadi diuji lewat lstat palsu.
let lstat = lstatAsli;
export function pasangLstatUji(fungsi) {
  const lama = lstat;
  lstat = fungsi ?? lstatAsli;
  return () => { lstat = lama; };
}

const TANDA_PNG = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);

// Jenis ditentukan dari byte awal, bukan dari ekstensi nama berkas.
export function kenaliGambar(buf) {
  if (buf.length >= 8 && buf.subarray(0, 8).equals(TANDA_PNG)) return { mime: 'image/png', ext: 'png' };
  if (buf.length >= 3 && buf[0] === 0xff && buf[1] === 0xd8 && buf[2] === 0xff) return { mime: 'image/jpeg', ext: 'jpg' };
  if (buf.length >= 12 && buf.toString('latin1', 0, 4) === 'RIFF' && buf.toString('latin1', 8, 12) === 'WEBP') {
    return { mime: 'image/webp', ext: 'webp' };
  }
  return null;
}

// Mengembalikan "LEBARxTINGGI" untuk PNG dan JPEG; WEBP dan lainnya null.
export function ukuranPiksel(buf, jenis) {
  if (jenis.ext === 'png' && buf.length >= 24) return `${buf.readUInt32BE(16)}x${buf.readUInt32BE(20)}`;
  if (jenis.ext === 'jpg') {
    let i = 2;
    while (i + 9 < buf.length) {
      if (buf[i] !== 0xff) { i += 1; continue; }
      const marker = buf[i + 1];
      if (marker === 0xff) { i += 1; continue; }
      if (marker >= 0xc0 && marker <= 0xcf && marker !== 0xc4 && marker !== 0xc8 && marker !== 0xcc) {
        return `${buf.readUInt16BE(i + 7)}x${buf.readUInt16BE(i + 5)}`;
      }
      if (marker === 0x01 || (marker >= 0xd0 && marker <= 0xd8)) { i += 2; continue; }
      i += 2 + buf.readUInt16BE(i + 2);
    }
  }
  return null;
}

// Gambar referensi: path lokal absolut, bukan UNC, bukan symlink, <= 10 MB, isi harus gambar asli.
// Catatan: ini membatasi apa yang bisa terkirim ke server (hanya gambar), bukan lokasi gambarnya.
export async function bacaReferensi(path) {
  if (typeof path !== 'string' || !isAbsolute(path)) {
    throw new DciError('referensi', 'Path gambar referensi harus absolut.');
  }
  if (path.startsWith('\\\\') || path.startsWith('//')) {
    throw new DciError('referensi', 'Path jaringan (UNC) tidak diizinkan untuk gambar referensi.');
  }
  let st;
  try {
    st = await lstat(path);
  } catch {
    throw new DciError('referensi', `Gambar referensi tidak ditemukan: ${path}`);
  }
  if (st.isSymbolicLink()) throw new DciError('referensi', `Symlink tidak diizinkan sebagai gambar referensi: ${path}`);
  if (!st.isFile()) throw new DciError('referensi', `Gambar referensi bukan berkas biasa: ${path}`);
  if (st.size > MAKS_BYTE_REFERENSI) {
    throw new DciError('referensi', `Gambar referensi melebihi 10 MB: ${path}`);
  }
  const buf = await readFile(path);
  const jenis = kenaliGambar(buf);
  if (!jenis) throw new DciError('referensi', `Berkas bukan gambar PNG/JPEG/WEBP asli: ${path}`);
  return { dataUrl: `data:${jenis.mime};base64,${buf.toString('base64')}`, ...jenis, byte: buf.length };
}
