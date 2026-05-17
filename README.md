<h1 align="center">
  <br>
  <img src="https://raw.githubusercontent.com/zehraheray/sat_zehra/main/assets/logo.png" alt="Kayıp Eşya Projesi" width="150" onerror="this.onerror=null; this.src='https://via.placeholder.com/150?text=Logo';">
  <br>
  Kayıp Eşya Projesi
  <br>
</h1>

<h4 align="center">Kullanıcıların kayıp ve buluntu eşyaları kolayca listeleyip arayabileceği, Supabase tabanlı modern bir Flutter uygulaması.</h4>

<p align="center">
  <a href="https://flutter.dev">
    <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" alt="Flutter">
  </a>
  <a href="https://supabase.com/">
    <img src="https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white" alt="Supabase">
  </a>
  <a href="https://dart.dev">
    <img src="https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
  </a>
</p>

---

## 🚀 Özellikler

Kayıp Eşya Projesi, kampüslerde veya topluluklarda eşyaların bulunmasını kolaylaştırmak için tasarlanmıştır.

* 🔐 **Kimlik Doğrulama:** Supabase altyapısıyla güvenli giriş ve kayıt işlemleri.
* ➕ **İlan Oluşturma:** Kameradan veya galeriden fotoğraf ekleyerek (`image_picker`) ilan oluşturma.
* 🔍 **Arama ve Filtreleme:** İlanlar arasında arama yapma ve kategorilere göre listeleme.
* 📞 **Hızlı İletişim:** `url_launcher` ile ilan sahibine tek tıkla ulaşma.
* 💰 **Reklam Entegrasyonu:** `google_mobile_ads` ile AdMob reklam desteği.

## 💻 Kullanılan Teknolojiler

| Kategori | Teknoloji / Kütüphane | Kullanım Amacı |
| :--- | :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev/) (SDK: ^3.9.2) | Çapraz platform mobil uygulama geliştirme |
| **BaaS & Veritabanı**| `supabase_flutter` | Kullanıcı doğrulama (Auth) ve gerçek zamanlı veritabanı |
| **Medya Yönetimi** | `image_picker` | İlanlara fotoğraf eklemek için kamera/galeri erişimi |
| **Araçlar** | `url_launcher` | Dış uygulamaları (Telefon araması, Mail) açma |
| **Monetizasyon** | `google_mobile_ads` | AdMob ile reklam gösterimi |
| **İkonografi** | `cupertino_icons` | iOS stili ikonlar için temel paket |


## 🛠 Kurulum

1. Repoyu klonlayın: `git clone https://github.com/sonabakhishova/sat_proje.git`
2. Paketleri yükleyin: `flutter pub get`
3. Supabase anahtarlarınızı yapılandırın.
4. Uygulamayı başlatın: `flutter run`


## 🏗 Proje Mimarisi

Projenin `lib/` klasörü, sürdürülebilirliği artırmak için modüler bir yaklaşımla organize edilmiştir:

```text
lib/
├── core/
│   └── constans/             # Renk paleti (app_colors) ve ortak widgetlar (custom_text_field)
├── models/
│   └── lost_item.dart        # Eşya veri modelleri
├── screens/
│   ├── auth/                 # Giriş, Kayıt ve Şifre Sıfırlama ekranları
│   └── home/
│       ├── main_screen.dart  # Alt navigasyon çubuğu barındıran ana iskelet
│       ├── home_screen.dart  # İlan akışının olduğu anasayfa
│       ├── add_item_screen.dart # Yeni ilan ekleme ekranı
│       ├── item_detail_screen.dart # İlan detaylarının görüntülendiği ekran
│       ├── profile/          # Profil görüntüleme ve düzenleme
│       └── search/           # Arama çubuğu ve sonuç listesi
├── widgets/
│   ├── category_filter.dart  # Kategori filtreleme çubuğu
│   └── lost_item_card.dart   # İlan listesindeki tekrar kullanılabilir kart tasarımı
└── main.dart                 # Uygulama başlangıç noktası ve tema ayarları## 🏗 Proje Mimarisi

Uygulama, sürdürülebilir bir yapı için modüler olarak organize edilmiştir:

- `lib/core/`: Renk paleti ve ortak widgetlar.
- `lib/screens/auth/`: Giriş ve kayıt ekranları.
- `lib/screens/home/`: Anasayfa, ilan ekleme ve detay ekranları.
- `lib/widgets/`: Kart tasarımları ve filtreleme araçları.

