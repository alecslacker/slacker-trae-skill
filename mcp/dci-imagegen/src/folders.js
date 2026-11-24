// dci-imagegen — menentukan folder tujuan hasil gambar.
// Author: Mas Wondho — Duta Corpora Indonesia (DCI)
// Copyright © 2026 Duta Corpora Indonesia

import { homedir } from 'node:os';
import { isAbsolute, join, parse, relative, resolve } from 'node:path';
import { DciError } from './errors.js';

export const NAMA_SUBFOLDER = 'generated-images';

function berada(anak, induk) {
  const r = relative(induk, anak);
  return r === '' || (!r.startsWith('..') && !isAbsolute(r));
}

function akarSistem(env) {
  return [
    env.WINDIR || env.SystemRoot || 'C:\\Windows',
    env.ProgramFiles || 'C:\\Program Files',
    env['ProgramFiles(x86)'] || 'C:\\Program Files (x86)',
  ];
}

// Mengembalikan alasan penolakan, atau null bila folder aman dipakai.
function alasanTerlarang(path, env) {
  const abs = resolve(path);
  if (parse(abs).root === abs) return 'folder akar drive';
  if (akarSistem(env).some((x) => berada(abs, x))) return 'folder sistem';
  return null;
}

// Urutan: output_dir eksplisit, env proyek Claude/ZCode, cwd server, lalu folder cadangan.
export function tentukanFolder({ outputDir, env = process.env, cwd = process.cwd(), home = homedir() } = {}) {
  if (outputDir !== undefined) {
    if (!isAbsolute(outputDir)) throw new DciError('output_dir', 'output_dir harus path absolut.');
    const sebab = alasanTerlarang(outputDir, env);
    if (sebab) throw new DciError('output_dir', `output_dir ditolak (${sebab}).`);
    return { folder: resolve(outputDir), cadangan: false };
  }
  for (const proyek of [env.CLAUDE_PROJECT_DIR, env.ZCODE_PROJECT_DIR]) {
    if (proyek && isAbsolute(proyek) && !alasanTerlarang(proyek, env)) {
      return { folder: join(resolve(proyek), NAMA_SUBFOLDER), cadangan: false };
    }
  }
  const kerja = resolve(cwd);
  if (!alasanTerlarang(kerja, env) && relative(home, kerja) !== '') {
    return { folder: join(kerja, NAMA_SUBFOLDER), cadangan: false };
  }
  return { folder: join(home, 'Pictures', 'dci-imagegen'), cadangan: true };
}
