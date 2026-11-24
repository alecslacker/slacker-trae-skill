// Pembantu uji: server 9router palsu + pembuat PNG minimal. Tanpa jaringan nyata, tanpa kuota.
// Author: Mas Wondho — Duta Corpora Indonesia (DCI)
// Copyright © 2026 Duta Corpora Indonesia

import { createServer } from 'node:http';
import { mkdtemp, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

export const KEY_UJI = 'sk-uji-1234567890abcdef';

// PNG minimal: tanda tangan + potongan IHDR berisi lebar dan tinggi. Cukup untuk dikenali dan diukur.
export function buatPng(lebar = 64, tinggi = 32) {
  const b = Buffer.alloc(33);
  Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]).copy(b, 0);
  b.writeUInt32BE(13, 8);
  b.write('IHDR', 12, 'latin1');
  b.writeUInt32BE(lebar, 16);
  b.writeUInt32BE(tinggi, 20);
  return b;
}

export function buatJpeg(lebar = 40, tinggi = 20) {
  // SOI + segmen SOF0 minimal.
  const b = Buffer.alloc(20);
  b[0] = 0xff; b[1] = 0xd8; b[2] = 0xff; b[3] = 0xc0;
  b.writeUInt16BE(11, 4);
  b[6] = 8;
  b.writeUInt16BE(tinggi, 7);
  b.writeUInt16BE(lebar, 9);
  return b;
}

export async function folderSementara() {
  const dir = await mkdtemp(join(tmpdir(), 'dci-imagegen-uji-'));
  return { dir, bersihkan: () => rm(dir, { recursive: true, force: true }) };
}

// opsi: models, info (id -> {name,capabilities,params}), generate(callIndex, body, req) -> {status,body,headers}
export async function mulaiRouterPalsu({ models = ['cx/gpt-image-2.6-sunburst'], info = {}, generate } = {}) {
  const panggilan = [];
  let urutanGenerate = 0;
  const server = createServer((req, res) => {
    const potong = [];
    req.on('data', (c) => potong.push(c));
    req.on('end', async () => {
      const badan = Buffer.concat(potong).toString('utf8');
      const url = new URL(req.url, 'http://x');
      panggilan.push({ metode: req.method, path: url.pathname, query: url.search, auth: req.headers.authorization, badan });
      if (req.headers.authorization !== `Bearer ${KEY_UJI}`) {
        res.writeHead(401, { 'content-type': 'application/json' });
        res.end(JSON.stringify({ error: { message: 'Invalid API key' } }));
        return;
      }
      if (url.pathname === '/v1/models/image') {
        res.writeHead(200, { 'content-type': 'application/json' });
        res.end(JSON.stringify({ data: models.map((id) => ({ id })) }));
        return;
      }
      if (url.pathname === '/v1/models/info') {
        const id = url.searchParams.get('id');
        const m = info[id] ?? { name: id, capabilities: ['text2img', 'edit', 'multiImage'], params: ['size', 'quality'] };
        res.writeHead(200, { 'content-type': 'application/json' });
        res.end(JSON.stringify({ id, ...m }));
        return;
      }
      if (url.pathname === '/v1/images/generations' && req.method === 'POST') {
        const i = urutanGenerate++;
        // generate boleh mengembalikan Promise (untuk mensimulasikan respons yang tertahan).
        const r = generate ? await generate(i, JSON.parse(badan || '{}'), req) : { status: 200, body: buatPng() };
        if (!r) return;
        res.writeHead(r.status, { 'content-type': r.status === 200 ? 'image/png' : 'application/json', ...(r.headers || {}) });
        res.end(r.body);
        return;
      }
      res.writeHead(404, { 'content-type': 'application/json' });
      res.end(JSON.stringify({ error: { message: 'tidak ada' } }));
    });
  });
  await new Promise((ok) => server.listen(0, '127.0.0.1', ok));
  const { port } = server.address();
  return {
    url: `http://127.0.0.1:${port}`,
    panggilan,
    jumlahGenerate: () => panggilan.filter((p) => p.path === '/v1/images/generations').length,
    // closeAllConnections: koneksi yang sengaja ditahan (uji timeout) tidak boleh menggantung penutupan.
    tutup: () => new Promise((ok) => { server.close(ok); server.closeAllConnections(); }),
  };
}
