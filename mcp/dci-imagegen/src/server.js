// dci-imagegen — definisi server MCP (dua tool: list_image_models, generate_image).
// Author: Mas Wondho — Duta Corpora Indonesia (DCI)
// Copyright © 2026 Duta Corpora Indonesia

import { homedir } from 'node:os';
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { z } from 'zod';
import { muatKonfigurasi } from './config.js';
import { DciError, sensor } from './errors.js';
import { BATAS_LANGSUNG, BATAS_MUTLAK, MAKS_REFERENSI, MODEL_BAWAAN, buatGambar } from './generate.js';
import { buatKlienRouter } from './router-client.js';

const DESKRIPSI_GENERATE =
  'Membuat atau mengedit gambar (logo, ilustrasi, mockup, hero) dengan GPT Image lewat 9router milik Duta Corpora Indonesia. ' +
  'Memakai kuota akun ChatGPT; satu gambar sekitar 30 detik. ' +
  'ATURAN: (1) Selalu isi output_dir dengan path absolut "<folder project aktif>/generated-images". ' +
  `(2) Biarkan n=1 kecuali pengguna meminta beberapa varian; maksimal ${BATAS_LANGSUNG} tanpa konfirmasi. ` +
  `(3) Untuk n di atas ${BATAS_LANGSUNG} (maksimal ${BATAS_MUTLAK}) TANYAKAN pengguna lebih dulu, lalu set confirmed=true. ` +
  `(4) Untuk mengedit atau memakai acuan, isi reference_images dengan path lokal absolut (maksimal ${MAKS_REFERENSI}). ` +
  '(5) Hasil berupa path berkas di disk; beri tahu pengguna lokasinya dan jangan menampilkan isi gambar.';

function jawab(teks, galat = false) {
  return { content: [{ type: 'text', text: teks }], isError: galat };
}

function jawabGalat(e) {
  const pesan = e instanceof DciError ? e.message : `Kesalahan tak terduga (${sensor(e?.code || e?.name || 'tak dikenal')}).`;
  return jawab(`Error: ${pesan}`, true);
}

function formatHasil(h) {
  const baris = [`${h.berhasil.length} dari ${h.jumlah_diminta} gambar tersimpan di: ${h.folder}`];
  if (h.folder_cadangan) {
    baris.push('PERHATIAN: folder project tidak terdeteksi, hasil masuk folder cadangan. Beri tahu pengguna lokasi ini.');
  }
  baris.push(JSON.stringify({ model: h.model, berhasil: h.berhasil, gagal: h.gagal }, null, 2));
  return baris.join('\n');
}

export function buatServer({
  env = process.env,
  berkasEnv,
  fetchImpl = fetch,
  cwd = process.cwd(),
  home = homedir(),
  batasWaktuMs = 120_000,
} = {}) {
  const server = new McpServer({ name: 'dci-imagegen', version: '0.1.0' });

  async function klienBaru() {
    const konfig = await muatKonfigurasi({ env, berkasEnv });
    return buatKlienRouter({ ...konfig, fetchImpl, batasWaktuMs });
  }

  server.registerTool(
    'list_image_models',
    {
      description: 'Menampilkan model gambar yang tersedia di 9router DCI beserta kemampuannya (edit, multi-referensi) dan parameternya.',
      inputSchema: {},
    },
    async (_args, extra) => {
      try {
        const klien = await klienBaru();
        const ids = await klien.daftarModel(extra?.signal);
        const info = await Promise.allSettled(ids.map((id) => klien.infoModel(id, extra?.signal)));
        const baris = ids.map((id, i) => {
          const m = info[i].status === 'fulfilled' ? info[i].value : null;
          return m
            ? `${id} | ${m.nama} | kemampuan: ${m.kemampuan.join(',') || '-'} | parameter: ${m.params.join(',') || '-'}`
            : `${id} | (info tidak tersedia)`;
        });
        return jawab([`Model bawaan: ${MODEL_BAWAAN}`, ...baris].join('\n'));
      } catch (e) {
        return jawabGalat(e);
      }
    },
  );

  server.registerTool(
    'generate_image',
    {
      description: DESKRIPSI_GENERATE,
      inputSchema: {
        prompt: z.string().min(3).max(4000).describe('Deskripsi gambar, atau instruksi edit bila reference_images diisi.'),
        model: z.string().optional().describe(`ID model dari list_image_models. Bawaan: ${MODEL_BAWAAN}.`),
        n: z.number().int().min(1).max(BATAS_MUTLAK).optional().describe('Jumlah gambar. Bawaan 1.'),
        reference_images: z.array(z.string()).max(MAKS_REFERENSI).optional().describe('Path lokal absolut gambar acuan (PNG/JPEG/WEBP).'),
        quality: z.string().optional().describe('Kualitas bila model mendukung, misalnya low, medium, high.'),
        output_dir: z.string().optional().describe('Path absolut folder simpan: "<project>/generated-images".'),
        confirmed: z.boolean().optional().describe(`Set true hanya setelah pengguna setuju n di atas ${BATAS_LANGSUNG}.`),
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
                    params: { progressToken: token, progress: selesai, total, message: `${selesai}/${total} gambar selesai` },
                  })
                  .catch(() => {});
        const hasil = await buatGambar({
          klien,
          parameter: {
            prompt: args.prompt,
            model: args.model,
            n: args.n,
            referensi: args.reference_images,
            quality: args.quality,
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

  return server;
}
