// dci-tts — pembantu tes: stub fetch, env sementara, dan konstanta umum.
// Author: Mas Wondho — Duta Corpora Indonesia (DCI)
// Copyright © 2026 Duta Corpora Indonesia

import { mkdtemp, writeFile, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { setTimeout as tunggu } from 'node:timers/promises';

export const KEY_UJI = 'sk-uji-1234567890abcdef';
export const URL_UJI = 'https://9router-uji.example.com';

// Entri MP3 minimal yang valid: frame sync FF F3 + beberapa byte, atau header ID3.
export const MP3_PALSU = Buffer.concat([Buffer.from([0xff, 0xf3, 0x84, 0xc4]), Buffer.alloc(32, 0x55)]);

export async function buatEnvSementara({ url = URL_UJI, key = KEY_UJI } = {}) {
  const folder = await mkdtemp(join(tmpdir(), 'dci-tts-uji-'));
  const path = join(folder, 'env');
  await writeFile(path, `NINEROUTER_URL=${url}\nNINEROUTER_KEY=${key}\n`, 'utf8');
  return { path, bersih: () => rm(folder, { recursive: true, force: true }) };
}

// Stub fetch dengan antrean balasan; mencatat setiap permintaan untuk diperiksa.
export function stubFetch(balasan) {
  const antrean = [...balasan];
  const permintaan = [];
  const fn = async (url, init = {}) => {
    permintaan.push({ url, init });
    const b = antrean.shift();
    if (!b) return { status: 500, headers: new Map(), arrayBuffer: async () => Buffer.from('{}') };
    if (b.jeda) await tunggu(b.jeda);
    return {
      status: b.status ?? 200,
      headers: new Map([['retry-after', b.retryAfter ?? null]]),
      arrayBuffer: async () => (b.body ?? MP3_PALSU).buffer.slice((b.body ?? MP3_PALSU).byteOffset, (b.body ?? MP3_PALSU).byteOffset + (b.body ?? MP3_PALSU).byteLength),
    };
  };
  fn.permintaan = permintaan;
  return fn;
}

export const folderKerja = () => mkdtemp(join(tmpdir(), 'dci-tts-proyek-'));
