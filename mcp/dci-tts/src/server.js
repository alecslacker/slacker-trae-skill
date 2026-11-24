// dci-tts — definisi server MCP (dua tool: text_to_speech, list_free_voices).
// Author: Mas Wondho — Duta Corpora Indonesia (DCI)
// Copyright © 2026 Duta Corpora Indonesia

import { homedir } from 'node:os';
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { z } from 'zod';
import { muatKonfigurasi } from './config.js';
import { DciError, sensor } from './errors.js';
import { BATAS_LANGSUNG, BATAS_MUTLAK, MAKS_KARAKTER, SUARA_BAWAAN, buatSuaraBatch } from './speech.js';
import { buatKlienRouter } from './router-client.js';

const DESKRIPSI_TTS =
  'Mengubah teks menjadi audio MP3 (voice over, narasi) lewat 9router milik Duta Corpora Indonesia. ' +
  'Suara gratis (tanpa kuota): edge-tts/id-ID-ArdiNeural (pria Indonesia), edge-tts/id-ID-GadisNeural (wanita Indonesia), google-tts/id (klasik, kaku). ' +
  'ATURAN: (1) Isi output_dir dengan path absolut "<folder project aktif>/generated-audio". ' +
  '(2) Untuk voice over video, kirim segments berupa array — satu elemen per adegan — agar paralel dan tertata. ' +
  `(3) Tiap adegan maksimal ${MAKS_KARAKTER} karakter; naskah lebih panjang dipecah dulu. ` +
  `(4) Lebih dari ${BATAS_LANGSUNG} adegan (maksimal ${BATAS_MUTLAK}) TANYAKAN pengguna lebih dulu, lalu set confirmed=true. ` +
  '(5) Hasil berupa path berkas MP3; beri tahu pengguna lokasinya.';

// Daftar statis suara gratis terbukti (2026-11-24) — tidak memanggil server,
// karena GET /v1/audio/voices sering 502 dan /v1/models/tts kosong di server ini.
const SUARA_GRATIS = [
  'edge-tts/id-ID-ArdiNeural  — pria Indonesia, natural (rekomendasi voice over)',
  'edge-tts/id-ID-GadisNeural — wanita Indonesia, natural',
  'edge-tts/en-US-GuyNeural   — pria Inggris AS (contoh format bahasa lain)',
  'google-tts/id              — Indonesia klasik (kualitas datar)',
  'google-tts/en              — Inggris klasik (kualitas datar)',
  'Catatan: provider premium (OpenAI/ElevenLabs/Deepgram/Gemini TTS) baru bisa dipakai setelah koneksi provider tersebut ditambahkan di dashboard 9router. Cukup isi voice dengan ID suaranya, tidak perlu update MCP.',
];

function jawab(teks, galat = false) {
  return { content: [{ type: 'text', text: teks }], isError: galat };
}

function jawabGalat(e) {
  const pesan = e instanceof DciError ? e.message : `Kesalahan tak terduga (${sensor(e?.code || e?.name || 'tak dikenal')}).`;
  return jawab(`Error: ${pesan}`, true);
}

function formatHasil(h) {
  const baris = [`${h.berhasil.length} dari ${h.jumlah_diminta} audio tersimpan di: ${h.folder}`];
  if (h.folder_cadangan) {
    baris.push('PERHATIAN: folder project tidak terdeteksi, hasil masuk folder cadangan. Beri tahu pengguna lokasi ini.');
  }
  baris.push(JSON.stringify({ voice: h.voice, berhasil: h.berhasil, gagal: h.gagal }, null, 2));
  return baris.join('\n');
}

export function buatServer({
  env = process.env,
  berkasEnv,
  fetchImpl = fetch,
  cwd = process.cwd(),
  home = homedir(),
  batasWaktuMs = 180_000,
} = {}) {
  const server = new McpServer({ name: 'dci-tts', version: '0.1.0' });

  async function klienBaru() {
    const konfig = await muatKonfigurasi({ env, berkasEnv });
    return buatKlienRouter({ ...konfig, fetchImpl, batasWaktuMs });
  }

  server.registerTool(
    'text_to_speech',
    {
      description: DESKRIPSI_TTS,
      inputSchema: {
        segments: z.union([z.string(), z.array(z.string())]).describe(
          'Teks yang dibacakan, atau array teks per adegan untuk voice over (maks 10 adegan).',
        ),
        voice: z.string().optional().describe(`ID suara dari list_free_voices. Bawaan: ${SUARA_BAWAAN}.`),
        output_dir: z.string().optional().describe('Path absolut folder simpan: "<project>/generated-audio".'),
        confirmed: z.boolean().optional().describe(`Set true hanya setelah pengguna setuju lebih dari ${BATAS_LANGSUNG} adegan.`),
      },
    },
    async (args, extra) => {
      try {
        const klien = await klienBaru();
        const token = extra?._meta?.progressToken;
        const progres =
          token === undefined
            ? undefined
            : ({ selesai, total }) =>
                extra
                  .sendNotification({
                    method: 'notifications/progress',
                    params: { progressToken: token, progress: selesai, total, message: `${selesai}/${total} audio selesai` },
                  })
                  .catch(() => {});
        const hasil = await buatSuaraBatch({
          klien,
          parameter: {
            voice: args.voice,
            segments: args.segments,
            outputDir: args.output_dir,
            confirmed: args.confirmed,
          },
          lingkungan: { env, cwd, home },
          sinyal: extra?.signal,
          progres,
        });
        return jawab(formatHasil(hasil), hasil.berhasil.length === 0);
      } catch (e) {
        return jawabGalat(e);
      }
    },
  );

  server.registerTool(
    'list_free_voices',
    {
      description: 'Menampilkan suara gratis yang terbukti jalan di 9router DCI beserta contoh format suara provider lain. Tanpa panggilan server.',
      inputSchema: {},
    },
    async () => jawab(['Suara bawaan: ' + SUARA_BAWAAN, ...SUARA_GRATIS].join('\n')),
  );

  return server;
}
