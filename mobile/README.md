# SmartFA Mobil Uygulaması

SmartFA (Akıllı Finans Asistanı), kişisel finans yönetimi için tasarlanmış Flutter tabanlı mobil uygulamadır. Kullanıcıların hesaplarını, gelir ve giderlerini takip etmelerine, bütçe oluşturmalarına ve finansal durumlarını analiz etmelerine yardımcı olur.

## Özellikler

- **Hesap Yönetimi**: Banka hesapları, nakit, kredi kartları ve diğer finansal varlıkların takibi
- **İşlem Takibi**: Gelir ve giderlerin kategori bazlı kaydı ve analizi
- **Bütçe Planlaması**: Kategori bazlı bütçe oluşturma ve takip etme
- **Borç Yönetimi**: Borçların ve ödeme planlarının takibi
- **Dashboard**: Finansal durumun genel görünümü ve özet istatistikler

## Kurulum

### Gereksinimler

- Flutter SDK (sürüm 3.6.0 veya üzeri)
- Dart SDK (sürüm 3.0.0 veya üzeri)
- Android Studio / VS Code
- iOS için: macOS ve Xcode
- Android için: Android SDK

### Adımlar

1. Repository'yi klonlayın
```bash
git clone https://github.com/yourusername/SmartFA.git
cd SmartFA/mobile
```

2. Bağımlılıkları yükleyin
```bash
flutter pub get
```

3. Uygulamayı başlatın
```bash
flutter run
```

## Mimari

SmartFA, modern bir yazılım mimarisi ve tasarım desenlerini takip eden, modüler ve test edilebilir bir yapıya sahiptir.

### Kullanılan Teknolojiler

- **GetX**: State yönetimi, rota yönetimi ve dependency injection
- **Dio**: HTTP istekleri için RESTful API istemcisi
- **flutter_secure_storage**: Hassas verilerin güvenli depolanması
- **freezed & json_serializable**: JSON veri modelleri için immutable class'lar

### Proje Yapısı

```
lib/
  ├── app/
  │    ├── bindings/            # Bağımlılık enjeksiyonu için GetX binding'ler
  │    ├── data/                # Veri katmanı
  │    │    ├── datasources/    # Uzak ve yerel veri kaynaklari
  │    │    ├── models/         # Veri modelleri (request/response)
  │    │    ├── network/        # API ve ağ bileşenleri
  │    │    └── repositories/   # Repository implementasyonları
  │    ├── domain/              # Domain katmanı
  │    │    └── repositories/   # Repository arayüzleri
  │    ├── modules/             # Uygulama modülleri (ekranlar)
  │    │    ├── accounts/       # Hesaplar modülü
  │    │    ├── auth/           # Kimlik doğrulama modülü
  │    │    ├── dashboard/      # Dashboard modülü
  │    │    ├── home/           # Ana sayfa modülü
  │    │    ├── settings/       # Ayarlar modülü
  │    │    └── transactions/   # İşlemler modülü
  │    ├── navigation/          # Rota tanımları
  │    ├── theme/               # Tema ve stil tanımları
  │    ├── utils/               # Yardımcı sınıflar
  │    └── widgets/             # Yeniden kullanılabilir widget'lar
  └── main.dart                 # Uygulama girdi noktası
```

### Mimari Katmanlar

Uygulama Clean Architecture prensiplerinden esinlenerek tasarlanmıştır:

1. **Presentation Katmanı** (`app/modules`): 
   - Ekranlar (`screens`)
   - Controller'lar ve state yönetimi
   - UI bileşenleri

2. **Domain Katmanı** (`app/domain`):
   - Repository arayüzleri
   - İş mantığı

3. **Data Katmanı** (`app/data`):
   - Repository implementasyonları
   - Veri kaynakları (API, yerel depolama)
   - Veri modelleri

### Bağımlılık Enjeksiyonu

Uygulama, GetX'in dependency injection mekanizması kullanılarak yazılmıştır:

- `InitialBinding`: Uygulama başlangıcında tüm servis ve repository'leri kaydeder
- Modül-Specifik Binding'ler: Her modül için özel controller'ları kaydeder

## Katkıda Bulunma

1. Bir branch oluşturun (`git checkout -b feature/amazing-feature`)
2. Değişikliklerinizi commit edin (`git commit -m 'Add some amazing feature'`)
3. Branch'inizi push edin (`git push origin feature/amazing-feature`)
4. Pull Request oluşturun

## Lisans

Bu proje [MIT lisansı](LICENSE) altında lisanslanmıştır.
