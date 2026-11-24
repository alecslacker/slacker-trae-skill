// dci-tts — kesalahan terstruktur dengan pesan Bahasa Indonesia.
// Author: Mas Wondho — Duta Corpora Indonesia (DCI)
// Copyright © 2026 Duta Corpora Indonesia

export class DciError extends Error {
  constructor(code, message) {
    super(message);
    this.name = 'DciError';
    this.code = code;
  }
}

// Pola yang menyerupai kunci atau token. Selalu disensor sebelum masuk pesan atau log.
const POLA_RAHASIA = /sk-[A-Za-z0-9_-]{8,}|Bearer\s+[A-Za-z0-9._-]{8,}/gi;

export function sensor(teks) {
  return String(teks ?? '').replace(POLA_RAHASIA, '[disensor]');
}

// Mengambil pesan inti dari badan respons error 9router (JSON atau teks biasa).
function ringkasBadan(teksBadan) {
  if (!teksBadan) return '';
  let pesan = teksBadan;
  try {
    const j = JSON.parse(teksBadan);
    pesan = j?.error?.message ?? j?.error ?? j?.message ?? teksBadan;
    if (typeof pesan !== 'string') pesan = JSON.stringify(pesan);
  } catch {
    // Bukan JSON: pakai teks apa adanya.
  }
  return sensor(pesan).replace(/\s+/g, ' ').trim().slice(0, 200);
}

export function petakanGalatHttp(status, teksBadan, retryAfter) {
  const rincian = ringkasBadan(teksBadan);
  const tambah = rincian ? ` Rincian: ${rincian}` : '';
  const saranSuara =
    ' Contoh suara valid: edge-tts/id-ID-ArdiNeural, edge-tts/id-ID-GadisNeural, google-tts/id.';
  switch (status) {
    case 401:
      return new DciError('auth', 'Key 9router ditolak (401). Periksa NINEROUTER_KEY di ~/.9router/env.');
    case 403:
      return new DciError('auth', `Akses ke 9router ditolak (403).${tambah}`);
    case 400:
      // 400 pada /v1/audio/speech paling sering berarti nama suara salah atau provider belum tersambung.
      return new DciError('permintaan', `Suara atau permintaan ditolak 9router (400).${saranSuara}${tambah}`);
    case 404:
      return new DciError('tidak_ditemukan', `Endpoint suara tidak ditemukan di 9router (404).${tambah}`);
    case 429:
    case 503: {
      const tunggu = /^\d+$/.test(String(retryAfter ?? ''))
        ? ` Coba lagi dalam ${retryAfter} detik.`
        : ' Coba lagi beberapa saat lagi.';
      return new DciError('tidak_tersedia', `Penyedia suara sedang tidak tersedia atau terbatas (${status}).${tunggu}${tambah}`);
    }
    default:
      return new DciError('upstream', `9router membalas HTTP ${status}.${tambah}`);
  }
}
