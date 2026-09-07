# PRD (Product Requirements Document)
## Kasir New — Premium iOS-Style Offline POS System

- **Nama Aplikasi**: Kasir New
- **Versi Dokumen**: 1.0.0 (Full Feature Spec)
- **Target Platform**: Android Smartphone & Android Tablet (Adaptive UI)
- **Teknologi**: Flutter (Dart) + SQLite (Drift / sqflite) + Offline-First Architecture
- **Theme & Design Language**: iOS 2026 Premium Light Theme (Orange Accent, Cupertino Glassmorphism, Rounded Borders, High Precision Typography)
- **Build & Distribution**: GitHub Actions CI/CD (Automated APK Debug & Release Build)

---

## 1. Executive Summary & Visi Produk

**Kasir New** adalah aplikasi Point of Sale (POS / Kasir) offline-first mandiri berkinerja tinggi yang dirancang untuk berbagai jenis usaha (retail, F&B, jasa, kelontong, fashion) tanpa ketergantungan koneksi internet, akun cloud, atau biaya langganan.

Aplikasi mengusung estetika **iOS 2026 Light Theme** yang mewah dengan aksen **Hermès/Cupertino Warm Orange**, komponen kartu melengkung lembut (squircle corners), blur layer bertekstur, navigasi responsif untuk smartphone dan tablet, serta performa pencarian instan untuk katalog lebih dari 1.000 produk.

---

## 2. Target Pengguna & Karakteristik Perangkat

| Aspek | Spesifikasi |
|---|---|
| **Jenis Usaha** | Multi-Usaha: Retail/Minimarket, Cafe/Restoran/F&B, Jasa/Laundry/Barbershop, Toko Grosir/Kelontong |
| **Katalog Produk** | 1.000 – 50.000+ SKU (dengan indexing SQLite full-text search & pagination/virtualized list) |
| **Perangkat** | Smartphone Android (Layar 5.5" - 6.8") & Tablet Android (Layar 8" - 13" Landscape/Portrait Split-Screen) |
| **Konektivitas** | 100% Offline (Bluetooth, USB OTG, LAN/Wi-Fi Direct untuk Printer & Scanner lokal) |
| **Keamanan Data** | Local Encrypted SQLite / SharedPreferences, isolasi data per perangkat |

---

## 3. Brand Identity & Design System (iOS 2026 Light Style)

### 3.1 Palette Warna
- **Primary Brand**: `#FF6B00` (Warm Vibrant Orange / iOS Sunset Orange)
- **Primary Deep / Pressed**: `#E05600`
- **Primary Subtle / Glow**: `#FFF0E6` / `rgba(255, 107, 0, 0.12)`
- **Background Base**: `#F8F9FA` (Clean Apple Ceramic White)
- **Surface / Card**: `#FFFFFF` dengan border tipis `rgba(0,0,0,0.05)` dan subtle shadow
- **Text Primary**: `#1A1C1E` (Deep Charcoal)
- **Text Secondary**: `#6C757D` / `#8E8E93` (SF Muted Slate)
- **Success / Paid**: `#34C759` (iOS Mint Green)
- **Warning / Hold / Debt**: `#FF9500` (iOS Amber)
- **Danger / Void / Refund**: `#FF3B30` (iOS Coral Red)
- **Info / Transfer / Debit**: `#007AFF` (iOS System Blue)

### 3.2 Typography & Radius
- **Font**: San Francisco / Inter / Plus Jakarta Sans
- **Corner Radius**: 
  - Button & Badge: `12px - 14px`
  - Cards & Modals: `20px - 24px`
  - Floating Action Buttons / Pill Selectors: `999px` (Full Pill)
- **Visual Accents**: Glassmorphic frosted topbars, haptic-like interaction feedback, smooth micro-animations.

---

## 4. Arsitektur & Spesifikasi Modul Fitur

### Modul 1: Manajemen Produk, Kategori & Stok (Full Scope)
1. **Atribut Produk**:
   - Nama produk, SKU/Kode unik, Barcode (EAN-13, Code 128, QR Code).
   - Harga beli (HPP/Modal), Harga jual 1 (Umum), Harga grosir/bertingkat (Opsional).
   - Stok fisik, Satuan utama (Pcs, Kg, Porsi, Dus, Botol, Pack), Multi-satuan konversi (misal: 1 Dus = 24 Pcs).
   - Kategori produk (dengan warna icon & tag khusus).
   - Foto produk (dari galeri / kamera) atau generator avatar inisial warna-warni.
   - Varian / Add-on (misal: Ukuran S/M/L, Rasa, Level Pedas, Topping).
   - Minimum stok alert (peringatan stok menipis).
2. **Operasional Stok**:
   - **Stok Masuk (Inbound)**: Pembelian barang dari supplier/tambah stok manual.
   - **Stok Keluar (Outbound / Waste)**: Barang rusak, expired, retur supplier, pemakaian internal.
   - **Stok Opname (Adjustment)**: Penyesuaian stok fisik real vs sistem dengan catatan selisih.
   - **Riwayat Log Mutasi**: Audit trail pergerakan stok per SKU lengkap dengan tanggal, jam, kasir, tipe perubahan.

### Modul 2: Transaksi POS & Kasir (High Performance)
1. **Katalog & Input Cepat**:
   - Instant Search (<10ms untuk 5.000 SKU).
   - Filter Kategori pill-tab horizontal.
   - Barcode Scanner (Kamera HP autofocus + USB/Bluetooth hardware barcode scanner support).
   - Mode Grid Card Foto / Mode List Baris Cepat (untuk retail grosir).
2. **Manajemen Keranjang (Cart)**:
   - Tambah, ubah quantity (+/- atau input angka langsung), ubah varian/notes per item.
   - Diskon per item (Nominal Rp atau Persentase %).
   - Diskon total transaksi (Voucher / Promo toko).
   - Pajak (PPN % custom, inclusive/exclusive) & Biaya Layanan (Service Charge %).
   - Custom item non-katalog (input manual harga & nama di tempat).
3. **Multi-Order & Hold Transaksi**:
   - Fitur **Hold / Simpan Pesanan**: Simpan transaksi sementara dengan nama meja / nama pelanggan (misal: Meja 05, Pak Budi).
   - Multi-tab transaksi aktif (Recall transaksi tanpa kehilangan keranjang).
4. **Pembayaran Multi-Metode**:
   - **Tunai (Cash)**: Shortcut nominal uang pas (Rp 10k, 20k, 50k, 100k), hitung otomatis uang diterima & kembalian.
   - **QRIS Statis Toko**: Upload/pasang gambar QRIS toko di pengaturan. Saat checkout, gambar QRIS muncul di layar kasir/pelanggan dengan total rupiah untuk di-scan.
   - **Transfer Bank & E-Wallet**: Pilihan BCA, Mandiri, BRI, BNI, GoPay, OVO, Dana, ShopeePay (input nomor referensi/opsional).
   - **Kartu Debit / Kartu Kredit / Mesin EDC**: Input approval code / bank EDC.
   - **Kasbon / Piutang / Hutang Pelanggan**:
     - Pencatatan nama pelanggan, no HP, jatuh tempo, DP (uang muka).
     - Buku piutang terintegrasi & pelunasan kasbon bertahap/lunas.
   - **Split Payment**: Bayar sebagian tunai + sebagian QRIS/Transfer.

### Modul 3: Cetak Struk Thermal & Periferal Kasir
1. **Konektivitas Printer**:
   - **Bluetooth Thermal Printer** (Auto-scan pairing BLE & Classic SPP).
   - **USB OTG Printer** (Direct USB Host raw stream).
   - **Wi-Fi / LAN Network Printer** (ESC/POS IP Address & Port 9100).
2. **Kustomisasi Struk (58mm & 80mm)**:
   - Header: Nama Toko, Logo Toko (monokrom bit-image), Alamat, No Telepon, Media Sosial.
   - Body: No Transaksi, Tanggal/Jam, Nama Kasir, Daftar Item (Qty x Harga, Varian, Diskon, Subtotal).
   - Summary: Subtotal, Diskon, Pajak/Service, Total Akhir, Metode Bayar, Tunai, Kembalian.
   - Footer: Pesan terima kasih, Kebijakan retur, QR Code nota / Wi-Fi toko.
   - Driver Control: Trigger Cash Drawer (laci kasir), Auto Paper-Cut command.
3. **Format Struk Digital**:
   - Share struk via WhatsApp (teks rapi & gambar nota PDF/PNG).
   - Preview struk instan di layar sebelum cetak.

### Modul 4: Laporan, Rekapitulasi & Manajemen Shift (X/Z Report)
1. **Buka/Tutup Kasir (Shift Management)**:
   - Modal awal kasir (Starting Cash).
   - Rekap kas masuk, kas keluar (Petty Cash/Biaya operasional kasir).
   - Tutup shift: Perhitungan uang kas aktual vs sistem (selisih lebih/kurang).
   - Cetak laporan Shift (X-Report pertengahan shift, Z-Report tutup shift).
2. **Laporan Penjualan Lengkap**:
   - Laporan Harian, Mingguan, Bulanan, Custom Rentang Tanggal.
   - Ringkasan KPI: Total Omzet, Total Transaksi, Laba Kotor (Revenue - HPP), Rata-rata Nilai Transaksi (Basket Size).
   - Rekap per Metode Pembayaran (Berapa Tunai, QRIS, Transfer, Kasbon).
   - Rekap per Kategori & Produk Terlaris (Top Selling Items & Dead Stock).
   - Rekap Transaksi Batal (Void) & Pengembalian Dana (Refund).
3. **Ekspor & Cetak Laporan**:
   - Cetak ringkasan laporan langsung ke printer thermal.
   - Ekspor laporan detail ke file Excel (.xlsx / .csv) & Dokumen PDF.

### Modul 5: Multi-Pengguna, Role & Keamanan PIN
1. **Level Akses / Role**:
   - **Owner / Super Admin**: Akses penuh ke seluruh menu, ubah harga, hapus data, lihat laba, reset database.
   - **Manager**: Akses kasir, stok opname, laporan harian (tanpa reset sistem).
   - **Kasir (Cashier)**: Hanya akses menu transaksi POS, riwayat transaksi harian, dan tutup shift miliknya.
2. **Fitur Keamanan**:
   - Akses ganti kasir instan via 4-6 digit PIN.
   - Otorisasi PIN Admin untuk aksi sensitif (Void transaksi, Hapus item pesanan yang sudah dicetak, Diskon khusus melebihi limit).
   - Audit Trail / Log Aktivitas: Catatan siapa yang melakukan void, ubah stok, atau ubah harga.

### Modul 6: Backup, Restore & Keandalan Data
1. **Full Database Backup**:
   - Backup 1-klik ke file arsip `.kasir` / `.json` / `.db` terenkripsi.
   - Simpan ke penyimpanan lokal, kartu SD, atau langsung Share ke WhatsApp / Google Drive / Email.
2. **Restore**:
   - Restore database instan dengan validasi integritas data.
3. **Proteksi & Maintenance**:
   - Auto-backup reminder setiap tutup toko / berkala.
   - Fitur Reset Data Kasir / Bersihkan Data Transaksi Dummy untuk siap pakai.

---

## 5. Struktur Layar & User Interface (Responsive Phone & Tablet)

```text
[ Root Navigation Bar / Rail (iOS Style) ]
  ├── 1. Kasir / POS (Katalog + Floating Cart / Split Screen di Tablet)
  │      ├── Search & Scan Barcode Bar
  │      ├── Horizontal Category Pill Filter
  │      ├── Grid/List SKU Catalog Cards
  │      └── Checkout Drawer / Sheet:
  │            ├── Cart Items & Modifiers
  │            ├── Discount / Tax Selectors
  │            ├── Payment Method Selector (Cash with quick nominals, QRIS popup, Transfer, Kasbon)
  │            └── Success Screen: Auto-print, WhatsApp Share, New Transaction
  │
  ├── 2. Riwayat & Transaksi
  │      ├── Tab: Selesai, Hold/Tertunda, Kasbon/Piutang, Dibatalkan/Void
  │      └── Detail Transaksi: Cetak Ulang, Kirim WA, Void (Perlu PIN Admin), Refund
  │
  ├── 3. Produk & Stok
  │      ├── Tab Katalog Produk (Tambah, Edit, Hapus, Multi-satuan, Varian, Barcode)
  │      ├── Tab Kategori
  │      ├── Tab Stok Masuk / Keluar
  │      └── Tab Stok Opname & Log Mutasi
  │
  ├── 4. Laporan & Keuangan
  │      ├── Ringkasan Omzet, Laba, & Grafik Tren Penjualan
  │      ├── Laporan Produk & Kategori
  │      ├── Buku Kasbon & Piutang Pelanggan
  │      ├── Shift Kasir & Tutup Buku (Cetak Z-Report)
  │      └── Ekspor Laporan (PDF / Excel)
  │
  └── 5. Pengaturan (Settings)
         ├── Profil Toko (Nama, Logo, Alamat, Kontak, Struk Header/Footer)
         ├── Konfigurasi QRIS Toko (Upload Gambar QRIS & Preview)
         ├── Manajemen Printer (Bluetooth Scan, USB, Network IP, Test Print 58/80mm)
         ├── Manajemen Pengguna & PIN (Owner, Manager, Kasir)
         ├── Aturan Pajak & Diskon Global
         └── Backup, Restore & Reset Database
```

---

## 6. Pipeline CI/CD GitHub Actions

Build APK dilakukan otomatis di GitHub Actions setiap kali push ke repository:
- Workflow file: `.github/workflows/build-apk.yml`
- Menjalankan environment Flutter & Android SDK
- Memproduksi file output:
  1. `app-debug.apk` (Artifact untuk uji coba cepat)
  2. `app-release.apk` (Release APK siap install di tablet & smartphone toko)
  3. GitHub Release draft/tag otomatis saat rilis versi baru.

---

## 7. Tahapan Implementasi Teknis

1. **Inisialisasi Project**: Setup struktur Flutter, dependencies offline (sqlite/drift, esc_pos_utils, flutter_bluetooth_serial/usb, pdf, excel, fl_chart, riverpod/bloc).
2. **Asset & Icon Branding**: Pembuatan aset ikon app vector oranye premium iOS 2026.
3. **Database Schema & Data Access Layer**: SQLite schema relasional (Products, Categories, Variants, StockMutations, Orders, OrderItems, Payments, Shifts, Users, Debts).
4. **Design System & Reusable Components**: Cupertino card squircle, frosted glass header, orange accent buttons, responsive split layout.
5. **Implementasi Seluruh Modul Core**: POS, Produk, Stok, Transaksi, Kasbon, Shift, Laporan, Printer Engine.
6. **Workflow GitHub Actions CI**: Script build APK otomatis siap pakai.
7. **Git Repository Setup**: Inisialisasi git commit awal dan instruksi push ke GitHub.
