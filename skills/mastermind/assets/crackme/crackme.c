/* crackme minimal untuk latihan patch.
 *
 * Build:
 *   gcc -O0 -o crackme crackme.c
 *
 * Aturan: jalankan tanpa argumen -> "akses ditolak".
 * Kunci benar -> "akses diterima". Tugas: temukan cek dan patch.
 *
 * Variabel kunci sengaja tidak dioptimalkan (volatile) supaya -O0
 * menghasilkan perbandingan yang jelas dan mudah dipetakan.
 */
#include <stdio.h>
#include <string.h>

static volatile int benar = 0;

static void periksa(const char *sandi)
{
    /* pembanding sederhana, bukan kriptografi */
    if (strcmp(sandi, "slackercoder") == 0) {
        benar = 1;
    }
}

int main(int argc, char **argv)
{
    if (argc < 2) {
        puts("akses ditolak");
        return 1;
    }

    periksa(argv[1]);

    if (benar) {
        puts("akses diterima");
        return 0;
    }

    puts("akses ditolak");
    return 1;
}
