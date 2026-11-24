// dci-imagegen — klien HTTP tipis untuk 9router (/v1/models/*, /v1/images/generations).
// Author: Mas Wondho — Duta Corpora Indonesia (DCI)
// Copyright © 2026 Duta Corpora Indonesia

import { DciError, petakanGalatHttp } from './errors.js';
import { kenaliGambar } from './images.js';

function uraiJson(buf) {
  try {
    return JSON.parse(buf.toString('utf8'));
  } catch {
    throw new DciError('respons', '9router membalas data yang bukan JSON valid.');
  }
}

export function buatKlienRouter({ baseUrl, key, fetchImpl = fetch, batasWaktuMs = 120_000 }) {
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
    async daftarModel(sinyal) {
      const j = uraiJson(wajibOk(await minta('/v1/models/image', {}, sinyal)).buf);
      return (j.data ?? []).map((m) => m.id);
    },

    async infoModel(id, sinyal) {
      const j = uraiJson(wajibOk(await minta(`/v1/models/info?id=${encodeURIComponent(id)}`, {}, sinyal)).buf);
      return { id: j.id ?? id, nama: j.name ?? id, kemampuan: j.capabilities ?? [], params: j.params ?? [] };
    },

    // Satu panggilan = satu gambar. Mengembalikan { bytes, jenis } dengan jenis dari byte asli.
    async buatGambar({ model, prompt, referensi = [], quality }, sinyal) {
      const badan = { model, prompt };
      if (referensi.length) badan.images = referensi;
      if (quality) badan.quality = quality;
      const r = wajibOk(
        await minta(
          '/v1/images/generations?response_format=binary',
          { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(badan) },
          sinyal,
        ),
      );
      let bytes = r.buf;
      let jenis = kenaliGambar(bytes);
      if (!jenis) {
        // Cadangan: sebagian penyedia membalas JSON { data: [{ b64_json }] } meski diminta biner.
        try {
          const b64 = JSON.parse(r.buf.toString('utf8'))?.data?.[0]?.b64_json;
          if (typeof b64 === 'string') {
            bytes = Buffer.from(b64, 'base64');
            jenis = kenaliGambar(bytes);
          }
        } catch {
          // Biarkan jatuh ke galat di bawah.
        }
      }
      if (!jenis) throw new DciError('respons', '9router membalas data yang bukan gambar PNG/JPEG/WEBP.');
      return { bytes, jenis };
    },
  };
}
