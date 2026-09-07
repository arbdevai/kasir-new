# Android Signing & CI/CD Keystore Guide

Dokumentasi ini menjelaskan langkah-langkah aman untuk membuat, mengonfigurasi, dan menggunakan release signing keystore Android pada alur CI/CD GitHub Actions menggunakan GitHub Repository Secrets.

---

## 1. Keamanan & Prinsip Utama
- **JANGAN PERNAH** melakukan commit file keystore (`.jks` / `.keystore`) atau file `key.properties` ke dalam git repository.
- Selalu pastikan file keystore dan `key.properties` terdaftar di `.gitignore`.
- Simpan kredensial keystore secara aman pada GitHub Secrets (`Settings -> Secrets and variables -> Actions`).
- Build branch non-release di CI memproduksi APK release unsigned tanpa fallback ke debug key untuk mencegah kebingungan artifact release.
- Rilis resmi bertanda tangan digital (signed release) hanya dipicu pada git tag (`v*.*.*`) atau `workflow_dispatch` dengan input `create_release: true`.

---

## 2. Membuat Keystore Lokal (Generate Keystore)

Jalankan perintah berikut di terminal lokal Anda untuk membuat keystore release baru:

```bash
keytool -genkey -v \
  -keystore upload-keystore.jks \
  -storetype JKS \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias kasir-key
```

Isi data-data yang diminta (password, nama organisasi, dll) dan catat informasi berikut:
1. `Keystore Password` (`storePassword`)
2. `Key Alias` (`keyAlias`, contoh: `kasir-key`)
3. `Key Password` (`keyPassword`)

---

## 3. Melakukan Encode Keystore ke Base64

Agar file binary keystore dapat disimpan sebagai teks di GitHub Secrets, lakukan encoding ke Base64:

### Linux / macOS:
```bash
base64 -w 0 upload-keystore.jks > upload-keystore.jks.base64.txt
# atau di macOS:
# base64 -i upload-keystore.jks -o upload-keystore.jks.base64.txt
```

### Windows (PowerShell):
```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks")) | Out-File -Encoding ASCII upload-keystore.jks.base64.txt
```

Salin seluruh isi dari file `upload-keystore.jks.base64.txt`.

---

## 4. Menambahkan Secret ke GitHub Repository

Buka repositori GitHub Anda:
1. Navigasi ke **Settings** > **Secrets and variables** > **Actions**.
2. Klik **New repository secret**.
3. Tambahkan 4 secret berikut:

| Secret Name | Deskripsi | Contoh / Nilai |
|---|---|---|
| `KEYSTORE_BASE64` | String base64 dari file `upload-keystore.jks` | *(String base64 panjang)* |
| `KEYSTORE_PASSWORD` | Password keystore Anda | `your_store_password` |
| `KEY_ALIAS` | Alias kunci yang dibuat | `kasir-key` |
| `KEY_PASSWORD` | Password kunci alias | `your_key_password` |

---

## 5. Konfigurasi Gradle Android di Project Flutter

File `android/app/build.gradle` membaca konfigurasi signing dari `android/key.properties`. Jika file `key.properties` tidak ditemukan (seperti pada push build biasa di branch utama), release build tidak akan menggunakan fallback ke debug signing key (`signingConfig = signingConfigs.debug` ditiadakan), melainkan tetap unsigned murni:

### File `android/app/build.gradle`:
```groovy
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.withReader("UTF-8") { reader -> keystoreProperties.load(reader) }
}

android {
    ...
    signingConfigs {
        release {
            if (keystoreProperties.containsKey("storeFile")) {
                storeFile = file(keystoreProperties["storeFile"])
                storePassword = keystoreProperties["storePassword"]
                keyAlias = keystoreProperties["keyAlias"]
                keyPassword = keystoreProperties["keyPassword"]
            }
        }
    }

    buildTypes {
        release {
            if (keystoreProperties.containsKey("storeFile")) {
                signingConfig = signingConfigs.release
            }
        }
    }
}
```

---

## 6. Cara Kerja di GitHub Actions Workflow

Pada workflow `.github/workflows/build-apk.yml`:
1. **Pemisahan Izin (Least Privilege)**:
   - Job `build` berjalan dengan `permissions: contents: read`.
   - Job `release` terpisah secara modular dengan `permissions: contents: write` hanya saat tag rilis atau dispatch release aktif.
2. **Penyediaan Toolchain Terpinning**:
   - Menyiapkan JDK 17 (Temurin).
   - Menyiapkan Android SDK Command-line Tools via `android-actions/setup-android@v3`.
   - Menginstal platform Android 36 (`platforms;android-36`), build-tools 36.0.0 (`build-tools;36.0.0`), dan NDK 28.2.13676358 (`ndk;28.2.13676358`) sesuai target `android/app/build.gradle`.
3. **Validasi Kredensial Signing**:
   - Pada release trigger (tag `v*.*.*` atau manual flag `create_release: true`), workflow memvalidasi keberadaan seluruh 4 secrets sebelum provisioning keystore.
4. **Provisioning Keystore**:
   - Melakukan decode base64 kembali menjadi file binary `android/app/upload-keystore.jks`.
   - Menulis file `android/key.properties` dengan parameter dari secrets.
5. **Build APK**:
   - Menjalankan `flutter build apk --debug --android-skip-build-dependency-validation`.
   - Menjalankan `flutter build apk --release --android-skip-build-dependency-validation`.
   - Pada commit branch biasa (tanpa tag/flag release), `key.properties` sengaja tidak di-generate sehingga APK release yang dihasilkan tetap berstatus unsigned murni tanpa fallback ke debug keys.
6. **Publishing Artifacts & Draft Release**:
   - Mengunggah artifact `app-debug` dan `app-release` (retensi 14 hari).
   - Membuat draft GitHub Release berisikan artifact APK resmi.

---

## 7. Rilis Versi Otomatis (GitHub Releases on Tag)

Untuk mempublikasikan rilis APK otomatis ke GitHub Releases:
1. Buat git tag baru sesuai format semver:
   ```bash
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin v1.0.0
   ```
2. GitHub Actions akan secara otomatis mendeteksi tag `v*.*.*`, memvalidasi secrets signing, mem-build `app-debug.apk` dan signed `app-release.apk`, lalu membuat GitHub Release draft dengan kedua file APK terlampir.
