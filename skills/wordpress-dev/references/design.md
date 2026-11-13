# Standar Tampilan — Anti-Datar

Tujuan: antarmuka terasa dibangun, bukan dihasilkan generator. Datar boleh jadi bagian dari komposisi, tetapi tidak boleh jadi satu-satunya bahasa visual.

## 1. Sistem, Bukan Perasaan

Definisikan token sekali. Nilai yang sama dipakai di seluruh plugin/tema.

```css
:root {
	--dci-radius-sm: 6px;
	--dci-radius-md: 12px;
	--dci-radius-lg: 20px;
	--dci-space-1: 4px;
	--dci-space-2: 8px;
	--dci-space-3: 12px;
	--dci-space-4: 16px;
	--dci-space-5: 24px;
	--dci-space-6: 32px;
	--dci-space-7: 48px;
	--dci-space-8: 64px;
	--dci-shadow-1: 0 1px 2px rgb(15 23 42 / 0.08);
	--dci-shadow-2: 0 6px 16px -6px rgb(15 23 42 / 0.18);
	--dci-shadow-3: 0 24px 48px -24px rgb(15 23 42 / 0.35);
	--dci-border: 1px solid rgb(15 23 42 / 0.10);
	--dci-ease: cubic-bezier(0.22, 1, 0.36, 1);
}
```

Pada tema blok, token yang sama diletakkan di `theme.json` (`settings.color.palette`, `settings.spacing.spacingSizes`, `settings.custom`). Jangan menulis hex berulang di widget.

## 2. Tiga Tingkat Permukaan

| Tingkat | Pemakaian | Perlakuan |
|---|---|---|
| Surface | latar halaman/section | warna dasar, boleh gradient tipis 2–4% |
| Raised | card, panel, widget | shadow level 2, border halus, radius medium |
| Overlay | modal, dropdown, tooltip | shadow level 3, backdrop blur/blur gelap, radius besar |

Setiap tingkat punya jarak visual yang jelas. Card tanpa elevasi di atas latar identik = datar.

## 3. Komposisi

- Grid asimetris bila konten mendukung; jangan semua section dua kolom sama rata.
- Satu titik fokus per layar. Ukuran, kontras, atau isolasi ruang dipakai untuk menunjuk fokus.
- Variasikan irama vertical spacing (48 → 24 → 64), bukan 40 di semua tempat.
- Gunakan divider, garis aksen, atau bidang warna untuk memisahkan; hindari kotak-kotak seragam.
- Beri ruang negatif yang berani pada hero dan CTA.

## 4. Tipografi

- Maksimal dua keluarga font; satu untuk display, satu untuk teks. Skala 1.25–1.333.
- Bobot dan tracking eksplisit pada judul besar (tracking negatif tipis).
- Panjang baris 60–75 karakter; `max-width` pada paragraf.
- Angka harga memakai `font-variant-numeric: tabular-nums` agar sejajar.

## 5. Warna dan Kedalaman

- Palet: netral 9 langkah + satu aksen + satu semantik (sukses/peringatan/bahaya).
- Kedalaman dari perbedaan luminance, bukan garis tebal.
- Gradient hanya untuk aksen atau latar luas, dengan dua stop berdekatan.
- Mode gelap: naikkan luminance permukaan seiring elevasi, jangan sekadar membalik warna.

## 6. State

```css
.dci-tombol {
	transition: transform 180ms var(--dci-ease), box-shadow 180ms var(--dci-ease);
}
.dci-tombol:hover { transform: translateY(-1px); box-shadow: var(--dci-shadow-2); }
.dci-tombol:focus-visible { outline: 3px solid var(--dci-aksen); outline-offset: 2px; }
.dci-tombol[disabled] { opacity: 0.55; transform: none; box-shadow: none; }
```

- Loading: skeleton atau spinner, bukan tombol diam.
- Empty: ilustrasi/ikon + satu kalimat + aksi.
- Error: warna semantik, ikon, teks penyebab, dan jalan keluar.
- `@media (prefers-reduced-motion: reduce)` mematikan transform dan animasi panjang.

## 7. WooCommerce

- Kartu produk: gambar rasio tetap, elevasi saat hover, harga tegas, tombol tidak tenggelam.
- Grid toko memakai `woocommerce_before_shop_loop_item` dsb.; jangan menimpa template untuk urusan kosmetik.
- Checkout: field dengan label di atas, state fokus jelas, ringkasan order sebagai panel raised.
- Notifikasi toko memakai warna semantik, bukan abu seragam.
- Sticky add-to-cart dan filter memakai overlay/shadow agar terpisah dari konten.

## 8. Elementor

- Kontrol style wajib mengisi default yang sudah enak dilihat, bukan kosong.
- Gunakan `selectors` + `{{WRAPPER}}`; jangan menyuntik CSS global dari widget.
- Sediakan kontrol radius, shadow, dan spacing agar pengguna tidak terjebak satu tampilan.
- Widget harus terlihat selesai di dalam preview editor, bukan hanya setelah disetel manual.
- Hormati container/flexbox; jangan memaksa lebar piksel tetap.

## 9. Aksesibilitas Visual

- Kontras teks 4.5:1 minimum, 7:1 untuk teks utama.
- Fokus keyboard tidak boleh dihilangkan tanpa pengganti.
- Target sentuh 44×44 px; beri jarak antar target.
- Jangan menyampaikan status hanya dengan warna; tambahkan ikon atau teks.
- `alt` deskriptif untuk gambar produk; dekorasi memakai `alt=""`.

## 10. Uji Visual

- Screenshot 320, 768, 1280, 1440 px; periksa reflow dan hierarki.
- Cek mode gelap dan `prefers-reduced-motion`.
- Cek state kosong, loading, error, dan disabled.
- Cek fokus keyboard berurutan tanpa mouse.
- Bandingkan dengan tampilan default plugin: bila hampir sama, belum selesai.

## 11. Anti-Pola Visual

- Semua card identik, tanpa elevasi, radius 0.
- Abu-abu di atas abu-abu tanpa pembeda.
- Tombol dan latar berkontras rendah.
- Shadow hitam pekat dan blur besar di semua elemen.
- Gradient pelangi, atau gradient di teks kecil.
- Animasi bounce di setiap elemen.
- Font sistem tanpa skala dan tanpa hierarki.
- Spacing seragam 16 px di seluruh halaman.
