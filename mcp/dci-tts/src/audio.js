// dci-tts — mengenali jenis berkas audio dari byte asli, bukan dari nama berkas.
// Author: Mas Wondho — Duta Corpora Indonesia (DCI)
// Copyright © 2026 Duta Corpora Indonesia

// 9router membalas audio/mp3 secara bawaan, tapi penyedia lain bisa mengirim
// wav atau ogg. Kenali dari magic byte supaya ekstensi selalu benar.
export function kenaliAudio(buf) {
  if (!buf || buf.length < 4) return null;
  // MP3: ID3 tag atau frame sync 0xFFEx.
  if (buf.subarray(0, 3).toString('ascii') === 'ID3') return { ext: 'mp3' };
  if (buf[0] === 0xff && (buf[1] & 0xe0) === 0xe0) return { ext: 'mp3' };
  // WAV: "RIFF"...."WAVE".
  if (buf.subarray(0, 4).toString('ascii') === 'RIFF' && buf.subarray(8, 12).toString('ascii') === 'WAVE') {
    return { ext: 'wav' };
  }
  // OGG: "OggS".
  if (buf.subarray(0, 4).toString('ascii') === 'OggS') return { ext: 'ogg' };
  // FLAC: "fLaC".
  if (buf.subarray(0, 4).toString('ascii') === 'fLaC') return { ext: 'flac' };
  return null;
}
