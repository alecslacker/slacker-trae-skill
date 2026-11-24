// dci-tts — klien HTTP tipis untuk 9router (POST /v1/audio/speech).
// Author: Mas Wondho — Duta Corpora Indonesia (DCI)
// Copyright © 2026 Duta Corpora Indonesia

import { DciError, petakanGalatHttp } from './errors.js';
import { kenaliAudio } from './audio.js';

function uraiJson(buf) {
  try {
    return JSON.parse(buf.toString('utf8'));
  } catch {
    throw new DciError('respons', '9router membalas data yang bukan JSON valid.');
  }
}

export function buatKlienRouter({ baseUrl, key, fetchImpl = fetch, batasWaktuMs = 180_000 }) {
  async function minta(path, init = {}, sinyal) {
    const gabungan = AbortSignal.any([AbortSignal.timeout(batasWaktuMs), ...(sinyal ? [sinyal] : [])]);
    try {
      const res = await fetchImpl(`${baseUrl}${path}`, {
        ...init,
        headers: { Authorization: `Bearer ${key}`, ...init.headers },
        signal: gabungan,
      });
      const buf = Buffer.from(await res.arrayBuffer());
      return { status: res.status, retryAfter: res.headers.get('retry-after'), buf };
    } catch (e) {
      if (e?.name === 'TimeoutError') {
        throw new DciError('timeout', `9router tidak merespons dalam ${Math.round(batasWaktuMs / 1000)} detik.`);
      }
      if (e?.name === 'AbortError') throw new DciError('dibatalkan', 'Permintaan dibatalkan.');
      throw new DciError('jaringan', `Tidak bisa menghubungi 9router (${e?.cause?.code || e?.code || 'kesalahan jaringan'}).`);
    }
  }

  function wajibOk(r) {
    if (r.status !== 200) throw petakanGalatHttp(r.status, r.buf.toString('utf8'), r.retryAfter);
    return r;
  }

  return {
    // Satu panggilan = satu audio. Mengembalikan { bytes, jenis } dengan jenis dari byte asli.
    async buatSuara({ voice, input }, sinyal) {
      const badan = { model: voice, input };
      const r = wajibOk(
        await minta(
          '/v1/audio/speech',
          { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(badan) },
          sinyal,
        ),
      );
      const jenis = kenaliAudio(r.buf);
      if (!jenis) {
        throw new DciError('respons', '9router membalas data yang bukan audio MP3/WAV/OGG/FLAC.');
      }
      return { bytes: r.buf, jenis };
    },

    // Metadata satu model (dipakai opsional; daftar /v1/models/tts sering kosong di server ini).
    async infoModel(id, sinyal) {
      const j = uraiJson(wajibOk(await minta(`/v1/models/info?id=${encodeURIComponent(id)}`, {}, sinyal)).buf);
      return { id: j.id ?? id, nama: j.name ?? id, kind: j.kind ?? '' };
    },
  };
}
