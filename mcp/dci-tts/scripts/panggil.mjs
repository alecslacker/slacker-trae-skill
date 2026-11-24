// dci-tts — pemanggil manual tanpa agent: node scripts/panggil.mjs "teks naskah"
// Author: Mas Wondho — Duta Corpora Indonesia (DCI)
// Copyright © 2026 Duta Corpora Indonesia

import { muatKonfigurasi } from '../src/config.js';
import { buatKlienRouter } from '../src/router-client.js';
import { buatSuaraBatch } from '../src/speech.js';

const teks = process.argv[2];
const voice = process.argv[3] || 'edge-tts/id-ID-ArdiNeural';
const outputDir = process.argv[4];
if (!teks) {
  console.error('Pemakaian: node scripts/panggil.mjs "<teks>" [suara] [folder_output]');
  process.exit(1);
}
const konfig = await muatKonfigurasi();
const klien = buatKlienRouter(konfig);
const hasil = await buatSuaraBatch({
  klien,
  parameter: { voice, segments: teks, output_dir: outputDir },
});
console.log(`${hasil.berhasil.length}/${hasil.jumlah_diminta} tersimpan di ${hasil.folder}`);
for (const b of hasil.berhasil) console.log(`  #${b.nomor} ${b.path} (${b.ukuran_kb} KB, ${b.detik} dtk)`);
for (const g of hasil.gagal) console.error(`  #${g.nomor} GAGAL: ${g.alasan}`);
