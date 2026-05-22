# Flutter Frontend - Booking Lapangan Futsal

Frontend mobile untuk user/customer aplikasi booking lapangan futsal.

Aplikasi ini digunakan user untuk register, login, melihat availability lapangan, membuat booking, melakukan pembayaran via QR, upload bukti pembayaran, melihat booking, membaca notifikasi, dan mengelola profile.

## Tech Stack

- Flutter
- Dart
- Riverpod
- Go Router
- Dio
- Firebase Auth
- Firebase Messaging
- Firebase Core
- Flutter Secure Storage
- Image Picker
- QR Flutter
- Intl
- Google Fonts
- Flutter Local Notifications

## Struktur Folder

```bash
lib
├── firebase_options.dart
├── main.dart
└── src
    ├── app
    │   ├── app.dart
    │   └── router.dart
    ├── core
    │   ├── config
    │   ├── errors
    │   ├── network
    │   ├── notifications
    │   ├── providers
    │   ├── storage
    │   ├── theme
    │   └── utils
    ├── features
    │   ├── auth
    │   ├── availability
    │   ├── bookings
    │   ├── home
    │   ├── notifications
    │   ├── payments
    │   └── profile
    └── shared
        └── widgets
```

## Fitur

### Auth

- Register user menggunakan Firebase Auth.
- Login user menggunakan Firebase Auth.
- Validasi email verified.
- Kirim ulang email verification.
- Forgot password.
- Logout.
- Simpan session token backend di secure storage.

### Home / Availability

- Pilih tanggal booking.
- Ambil availability field dari backend.
- Tampilkan list field.
- Tampilkan harga per jam.
- Tampilkan jam buka/tutup field.
- Tampilkan status field:
  - tersedia,
  - penuh,
  - tutup full day,
  - unavailable.

### Schedule Field

Frontend memakai data schedule dari response availability backend.

Data yang dipakai:

- `open_time`
- `close_time`
- `is_closed`
- `booked_slots`

Behavior:

- Kalau `is_closed = true`, field ditampilkan tutup dan tidak bisa dipilih.
- Kalau field available, card menampilkan jam buka/tutup.
- Pilihan jam booking dibuat berdasarkan `open_time` dan `close_time`.
- Slot yang sudah booked tidak bisa dipilih.
- User tidak bisa submit booking di luar jam operasional schedule.
- Jika tidak ada schedule khusus dari admin, backend mengirim default `08:00-23:00`.

### Booking

- Buat booking.
- Pilih jam mulai.
- Pilih jam selesai.
- Validasi overlap dengan booked slot.
- Lihat booking milik user.
- Lihat detail booking.
- Cancel booking pending.

### Payment

- Ambil QR pembayaran.
- Tampilkan QR.
- Upload bukti pembayaran.
- Tambahkan note bukti pembayaran.

### Notification

- Lihat notifikasi user.
- FCM token dikirim ke backend.

### Profile

- Lihat profile.
- Update nama dan nomor telepon.
- Logout.

## Requirements

- Flutter SDK
- Firebase project
- Backend API berjalan
- Android/iOS/Web target sesuai kebutuhan
- File Firebase config sudah tersedia

## Environment / API Base URL

API base URL diatur melalui Dart define.

Default untuk Android emulator:

```bash
http://10.0.2.2:8080/api/v1
```

Jika backend memakai Ngrok:

```bash
flutter run --dart-define=API_BASE_URL=https://your-ngrok-domain.ngrok-free.app/api/v1
```

Jika memakai device fisik dengan backend lokal, pakai IP laptop:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8080/api/v1
```

## Instalasi

```bash
flutter pub get
```

## Menjalankan Aplikasi

Android emulator:

```bash
flutter run
```

Dengan custom API URL:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
```

Dengan Ngrok:

```bash
flutter run --dart-define=API_BASE_URL=https://your-ngrok-domain.ngrok-free.app/api/v1
```

## Build Android

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://your-production-api.com/api/v1
```

Untuk App Bundle:

```bash
flutter build appbundle --release --dart-define=API_BASE_URL=https://your-production-api.com/api/v1
```

## Firebase Setup

Pastikan file berikut tersedia:

```bash
lib/firebase_options.dart
```

Jika perlu generate ulang:

```bash
flutterfire configure
```

Firebase digunakan untuk:

- Register
- Login
- Email verification
- Password reset
- Firebase Messaging / FCM

## Routing

Routing utama berada di:

```bash
lib/src/app/router.dart
```

Route yang tersedia:

```bash
/splash
/login
/register
/forgot-password
/
/bookings
/profile
/notifications
/create-booking
/payment/:bookingId
/booking/:bookingId
```

## API Integration

Dio client berada di:

```bash
lib/src/core/network/dio_client.dart
```

Base URL berada di:

```bash
lib/src/core/config/app_config.dart
```

Token backend dibaca dari secure storage dan otomatis ditambahkan ke header:

```http
Authorization: Bearer <token>
```

## Endpoint yang Dipakai

### Auth

```http
POST /auth/login
```

### Availability

```http
GET /fields/availability?date=YYYY-MM-DD
```

### Bookings

```http
POST  /bookings
GET   /bookings
GET   /bookings/:bookingId
PATCH /bookings/:bookingId/cancel
```

### Payments

```http
GET  /payments/:bookingId/qr
POST /payments/:bookingId/proof
```

### Notifications

```http
GET /user/notifications
```

### Profile

```http
GET   /user/profile
PATCH /user/profile
```

## Availability Model

Response availability dari backend dipetakan ke model:

```bash
lib/src/features/availability/data/models/field_availability.dart
```

Field utama:

```bash
field_id
field_name
field_type
price_per_hour
date
open_time
close_time
is_available
is_closed
booked_slots
```

## Flow Booking

1. User login.
2. App menyimpan token backend di secure storage.
3. User pilih tanggal di home.
4. App request availability ke backend.
5. App menampilkan field beserta jam buka/tutup.
6. User pilih field.
7. App membuka halaman create booking.
8. App generate pilihan jam berdasarkan `open_time` dan `close_time`.
9. App disable jam yang overlap dengan `booked_slots`.
10. User submit booking.
11. Backend membuat booking dan payment.
12. User diarahkan ke pembayaran QR.
13. User upload bukti pembayaran.
14. Admin melakukan validasi pembayaran dari admin panel.

## File Penting

### Config

```bash
lib/src/core/config/app_config.dart
```

### Network

```bash
lib/src/core/network/dio_client.dart
lib/src/core/network/api_response.dart
```

### Auth

```bash
lib/src/features/auth
```

### Availability & Schedule

```bash
lib/src/features/availability/data/availability_repository.dart
lib/src/features/availability/data/models/field_availability.dart
lib/src/features/availability/presentation/screens/create_booking_screen.dart
lib/src/features/availability/presentation/widgets/field_card.dart
```

### Booking

```bash
lib/src/features/bookings
```

### Payment

```bash
lib/src/features/payments
```

### Profile

```bash
lib/src/features/profile
```

### Notification

```bash
lib/src/features/notifications
```

## Troubleshooting

### API tidak connect di Android emulator

Gunakan:

```bash
http://10.0.2.2:8080/api/v1
```

Bukan:

```bash
http://localhost:8080/api/v1
```

### API tidak connect di device fisik

Gunakan IP laptop atau Ngrok.

Contoh:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8080/api/v1
```

### Login gagal

Cek:

- Firebase config benar.
- Email sudah verified.
- Backend berjalan.
- Endpoint `/auth/login` bisa diakses.
- Firebase ID token berhasil dikirim ke backend.

### Field selalu tutup

Cek dari admin panel:

```bash
Fields -> pilih field -> Jadwal Khusus
```

Pastikan tidak ada schedule dengan `is_closed = true` pada tanggal yang dipilih.

### Jam booking tidak muncul

Cek response availability:

- `open_time`
- `close_time`
- `is_closed`
- `booked_slots`

Jika `is_closed = true`, booking memang tidak bisa dibuat.
