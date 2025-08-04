baku, jam operasional, dan pembayaran. Pemilik restoran dapat memberikan jawaban yang akurat dan cepat, memastikan layanan lebih personal dan 

## Dataset
Kami menggunakan dataset dari [Dataset Kuliner Yogyakarta](https://docs.google.com/spreadsheets/d/1LelYSWyIbtKYAdcubHRHUZLkp7jnfJAlvegf-s0BD8c/edit?gid=1296951064#gid=1296951064) untuk informasi terkait lokasi restoran dan jenis kuliner di Jogjakarta.

## Jenis Pengguna (_Role_)

Pada aplikasi kami, terdapat dua jenis pengguna:

- Pemilik Toko
- Pengguna Umum

Penjelasan lebih rinci tentang setiap jenis pengguna dan hak aksesnya dalam aplikasi disampaikan pada deskripsi masing-masing modul.

## Alur Pengintegrasian dengan Aplikasi Web

Saat menghubungkan Django dengan Flutter, kami akan melakukan beberapa langkah berikut:

1. Menambahkan Library HTTP: Untuk memungkinkan aplikasi Flutter terhubung dan berkomunikasi dengan aplikasi web Django, kami akan menambahkan library http ke proyek.
2. Menggunakan Sistem Autentikasi: Fitur login, logout, dan registrasi yang sudah dibuat sebelumnya akan diterapkan. Sistem ini memastikan setiap pengguna mendapatkan akses sesuai dengan perannya, apakah sebagai pembaca atau penulis.
3. Mengelola Cookie dengan pbp_django_auth: Library ini akan membantu mengatur cookie autentikasi, sehingga setiap permintaan yang dikirim ke server berasal dari pengguna yang sudah terverifikasi dan punya izin yang benar.
4. Membuat Kelas Katalog di Flutter: Kami akan membuat kelas Katalog menggunakan data produk makanan dari API. Untuk mempermudah, kami akan menggunakan alat https://app.quicktype.io/ untuk mengonversi data JSON menjadi objek Dart yang siap digunakan.
