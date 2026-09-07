# Android Signing & CI/CD Keystore Guide

Dokumentasi ini menjelaskan langkah-langkah aman untuk membuat, mengonfigurasi, dan menggunakan signing keystore Android pada alur CI/CD GitHub Actions menggunakan GitHub Repository Secrets.

---

## 1. Keamanan & Prinsip Utama
- **JANGAN PERNAH** melakukan commit file keystore (`.jks` / `.keystore`) atau file `key.properties` ke dalam git repository.
- Selalu tambahkan file keystore dan `key.properties` ke `.gitignore`.
- Simpan kredensial keystore secara aman pada GitHub Secrets (`Settings -> Secrets and variables -> Actions`).

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

Pastikan file `android/app/build.gradle` (atau `android/app/build.gradle.kts`) membaca konfigurasi dari `android/key.properties`:

### File `android/app/build.gradle`:
```groovy
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            if (keystorePropertiesFile.exists()) {
                keyAlias keystoreProperties['keyAlias']
                keyPassword keystoreProperties['keyPassword']
                storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
                storePassword keystoreProperties['storePassword']
            }
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled false
            shrinkResources false
        }
    }
}
```

---

## 6. Cara Kerja di GitHub Actions Workflow

Pada workflow `.github/workflows/build-apk.yml`, terdapat step otomatis:
1. Membaca `KEYSTORE_BASE64` dari `secrets.KEYSTORE_BASE64`.
2. Melakukan decode base64 kembali menjadi file binary `android/app/upload-keystore.jks`.
3. Menulis file `android/key.properties` dengan parameter dari secrets.
4. Menjalankan `flutter build apk --release` sehingga APK tertanda tangani (signed) secara resmi.
5. Runner ephemeral GitHub Actions akan membersihkan lingkungan setelah workflow selesai sehingga tidak ada file rahasia yang tersisa.

---

## 7. Rilis Versi Otomatis (GitHub Releases on Tag)

Untuk mempublikasikan rilis APK otomatis ke GitHub Releases:
1. Buat git tag baru sesuai format semver:
   ```bash
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin v1.0.0
   ```
2. GitHub Actions akan secara otomatis mendeteksi tag `v*.*.*`, mem-build `app-debug.apk` dan `app-release.apk`, lalu membuat GitHub Release dengan kedua file APK terlampir.
