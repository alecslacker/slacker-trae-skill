// dci-tts — membaca kredensial 9router dari ~/.9router/env (atau environment).
// Author: Mas Wondho — Duta Corpora Indonesia (DCI)
// Copyright © 2026 Duta Corpora Indonesia

import { readFile } from 'node:fs/promises';
import { homedir } from 'node:os';
import { join } from 'node:path';
import { DciError } from './errors.js';

export const berkasEnvBawaan = () => join(homedir(), '.9router', 'env');

// Format: baris "NAMA=nilai". Mendukung komentar (#), kutip, dan BOM dari Notepad.
export function uraiTeksEnv(teks) {
  const hasil = {};
  for (const mentah of teks.replace(/^\uFEFF/, '').split(/\r?\n/)) {
    const baris = mentah.trim();
    if (!baris || baris.startsWith('#')) continue;
    const m = /^([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)$/.exec(baris);
    if (!m) continue;
    let nilai = m[2].trim();
    const kutip = nilai[0];
    if ((kutip === '"' || kutip === "'") && nilai.length >= 2 && nilai.endsWith(kutip)) {
      nilai = nilai.slice(1, -1);
    }
    hasil[m[1]] = nilai;
  }
  return hasil;
}

// Dibaca di setiap panggilan, jadi mengganti key tidak perlu restart server.
// Environment NINEROUTER_URL / NINEROUTER_KEY menimpa isi berkas.
export async function muatKonfigurasi({ env = process.env, berkasEnv = berkasEnvBawaan() } = {}) {
  let dariBerkas = {};
  try {
    dariBerkas = uraiTeksEnv(await readFile(berkasEnv, 'utf8'));
  } catch (e) {
    if (e?.code !== 'ENOENT') {
      throw new DciError('konfigurasi', `Berkas kredensial tidak bisa dibaca (${e?.code || 'kesalahan'}).`);
    }
  }
  const url = (env.NINEROUTER_URL || dariBerkas.NINEROUTER_URL || '').trim();
  const key = (env.NINEROUTER_KEY || dariBerkas.NINEROUTER_KEY || '').trim();
  if (!url || !key) {
    throw new DciError('konfigurasi', 'Kredensial 9router belum lengkap. Isi NINEROUTER_URL dan NINEROUTER_KEY di ~/.9router/env.');
  }
  let u;
  try {
    u = new URL(url);
  } catch {
    throw new DciError('konfigurasi', 'NINEROUTER_URL bukan URL yang valid.');
  }
  const lokal = ['localhost', '127.0.0.1', '[::1]'].includes(u.hostname);
  if (u.protocol !== 'https:' && !(u.protocol === 'http:' && lokal)) {
    throw new DciError('konfigurasi', 'NINEROUTER_URL wajib https (http hanya untuk localhost).');
  }
  return { baseUrl: u.origin + u.pathname.replace(/\/+$/, ''), key };
}
