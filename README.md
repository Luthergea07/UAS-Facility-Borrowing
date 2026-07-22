# SIPAS - Sistem Peminjaman Fasilitas Kampus

Aplikasi mobile (berbasis Flutter) untuk mempermudah proses peminjaman fasilitas dan ruangan di lingkungan kampus. Proyek ini dibangun sebagai Tugas Akhir Semester (UAS).

## Fitur Utama
- **Mahasiswa**: Dapat melihat katalog fasilitas, mengecek ketersediaan stok, dan mengajukan peminjaman secara *real-time*.
- **Admin**: Dapat mengelola data inventaris (Tambah/Edit/Hapus), menyetujui atau menolak permohonan pinjaman, serta memverifikasi pengembalian barang (stok otomatis bertambah).
- **Backend & Keamanan**: Menggunakan **Supabase** untuk autentikasi *login* dan *database*.

---

## Panduan Akses (Login & Register)

Sistem ini memisahkan hak akses menjadi dua peran utama, yaitu Administrator dan Mahasiswa.

### 1. Masuk sebagai Admin
Untuk menguji fitur-fitur panel kendali Administrator (seperti mengelola barang dan memberikan persetujuan), Anda dapat langsung masuk (*login*) menggunakan kredensial berikut:
- **Email:** `ther@gmail.com`
- **Password:** `password12345`

### 2. Masuk sebagai Mahasiswa (User Biasa)
Jika Anda ingin mencoba aplikasi dari sudut pandang peminjam (melihat katalog barang dan mengajukan pinjaman), **Anda diwajibkan untuk membuat akun baru terlebih dahulu.**
- Klik tombol **"Belum punya akun? Daftar di sini"** pada halaman awal aplikasi.
- Lengkapi formulir pendaftaran dengan nama, email, dan password pilihan Anda.
- Setelah registrasi berhasil, silakan *login* menggunakan akun yang baru saja Anda buat tersebut. Anda akan secara otomatis diarahkan ke Dasbor Mahasiswa.

---

## Persiapan Menjalankan Proyek (Setup)
1. Kloning repositori ini: `git clone https://github.com/Luthergea07/UAS-Facility-Borrowing.git`
2. Buka terminal di dalam folder proyek dan jalankan `flutter pub get` untuk mengunduh semua *package*.
3. Jalankan `flutter run` untuk memulai aplikasi.
