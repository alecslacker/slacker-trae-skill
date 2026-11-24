// dci-tts — tes audio.js dan folders.js.
// Author: Mas Wondho — Duta Corpora Indonesia (DCI)
// Copyright © 2026 Duta Corpora Indonesia

import test from 'node:test';
import assert from 'node:assert/strict';
import { kenaliAudio } from '../src/audio.js';
import { tentukanFolder, NAMA_SUBFOLDER } from '../src/folders.js';
import { DciError } from '../src/errors.js';

const mp3 = Buffer.concat([Buffer.from([0xff, 0xf3, 0x84, 0xc4]), Buffer.alloc(8)]);
const mp3id3 = Buffer.concat([Buffer.from('ID3'), Buffer.alloc(8)]);
const wav = Buffer.concat([Buffer.from('RIFFxxxxWAVE'), Buffer.alloc(8)]);
const ogg = Buffer.concat([Buffer.from('OggS'), Buffer.alloc(8)]);
const flac = Buffer.concat([Buffer.from('fLaC'), Buffer.alloc(8)]);
const sampah = Buffer.from('bukan audio sama sekali');

test('kenaliAudio: mp3, id3, wav, ogg, flac, dan sampah', () => {
  assert.equal(kenaliAudio(mp3).ext, 'mp3');
  assert.equal(kenaliAudio(mp3id3).ext, 'mp3');
  assert.equal(kenaliAudio(wav).ext, 'wav');
  assert.equal(kenaliAudio(ogg).ext, 'ogg');
  assert.equal(kenaliAudio(flac).ext, 'flac');
  assert.equal(kenaliAudio(sampah), null);
  assert.equal(kenaliAudio(Buffer.alloc(2)), null);
});

const ENV_MIN = { WINDIR: 'C:\\Windows', ProgramFiles: 'C:\\Program Files', 'ProgramFiles(x86)': 'C:\\Program Files (x86)' };
const HOME_UJI = 'C:\\Users\\uji';

test('tentukanFolder: output_dir absolut dipakai apa adanya', () => {
  const h = tentukanFolder({ outputDir: 'D:\\proyek\\x', env: ENV_MIN, cwd: 'C:\\ elsewhere', home: HOME_UJI });
  assert.equal(h.folder, 'D:\\proyek\\x');
  assert.equal(h.cadangan, false);
});

test('tentukanFolder: output_dir relatif dan folder sistem ditolak', () => {
  assert.throws(() => tentukanFolder({ outputDir: 'relatif', env: ENV_MIN, cwd: 'C:\\p', home: HOME_UJI }), (e) => e instanceof DciError && e.code === 'output_dir');
  assert.throws(() => tentukanFolder({ outputDir: 'C:\\Windows\\temp', env: ENV_MIN, cwd: 'C:\\p', home: HOME_UJI }), (e) => e.code === 'output_dir');
  assert.throws(() => tentukanFolder({ outputDir: 'C:\\', env: ENV_MIN, cwd: 'C:\\p', home: HOME_UJI }), (e) => e.code === 'output_dir');
});

test('tentukanFolder: CLAUDE_PROJECT_DIR dipakai dengan subfolder generated-audio', () => {
  const h = tentukanFolder({ env: { ...ENV_MIN, CLAUDE_PROJECT_DIR: 'D:\\proyek' }, cwd: 'C:\\p', home: HOME_UJI });
  assert.equal(h.folder, 'D:\\proyek\\' + NAMA_SUBFOLDER);
});

test('tentukanFolder: cwd bukan home -> cwd/generated-audio; home -> cadangan Music/dci-tts', () => {
  const a = tentukanFolder({ env: ENV_MIN, cwd: 'D:\\proyek', home: HOME_UJI });
  assert.equal(a.folder, 'D:\\proyek\\' + NAMA_SUBFOLDER);
  const b = tentukanFolder({ env: ENV_MIN, cwd: HOME_UJI, home: HOME_UJI });
  assert.equal(b.cadangan, true);
  assert.ok(b.folder.includes('Music') && b.folder.includes('dci-tts'));
});
