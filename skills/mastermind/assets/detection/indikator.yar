/* Templat YARA. Sesuaikan string dengan hasil analisis, bukan dugaan.
 * Uji: yara -r indikator.yar sasaran/
 * Aturan: tiap string wajib punya alasan (dari evidence mana). */
rule MM_Contoh_Implan
{
    meta:
        penulis   = "Slackercoder Family"
        versi     = "0"
        rujukan   = "isi Evidence ID"
        tanggal   = "YYYY-MM-DD"

    strings:
        $jalur   = "/tmp/.mm-cache" ascii wide
        $mutex   = "mm_lock_2026" ascii
        $domain  = ".contoh-c2.tld" ascii
        $pola    = { 6A 00 68 ?? ?? ?? ?? E8 }   // contoh, verifikasi dulu

    condition:
        uint16(0) == 0x5A4D and 2 of them
}
