# 🚀 Akıllı Tahta (Smart Board)

Pardus ve Windows uyumlu, sınıf içi etkileşimli eğitim için geliştirilmiş modern, dokunmatik optimizasyonlu, açık kaynaklı PDF ve beyaz tahta uygulaması.

> [!NOTE]
> Bu proje, geleneksel PDF okuyucularının aksine büyük dokunmatik ekranlar (65-86") ve sınıf ortamı dinamikleri göz önünde bulundurularak özel olarak tasarlanmıştır.

## ✨ Temel Özellikler

- 📄 **Akıcı PDF Görüntüleme:** `pdfrx` motoru ile yüksek çözünürlüklü sayfa renderlama.
- 🎨 **Gelişmiş Çizim Katmanı:** Sayfa bazlı izole edilmiş çizim geçmişi, limitsiz Undo/Redo desteği.
- 🛠️ **Öğretmen Araç Çantası:** Özelleştirilebilir kalemler, vurgulayıcılar (marker), silgi ve geniş renk/kalınlık paleti.
- 🔍 **Dinamik Soru Büyüteci:** Rubber-band (sürükle-bırak) seçimi ile sayfadaki herhangi bir soruyu kalite kaybı olmadan izole edip tam ekrana büyütme.
- 👆 **Dokunmatik (Touch) Optimizasyonu:** Büyük ekranlarda kolay kullanım için minimum 48x48px (Material Design standardı) temas alanları, swipe tabanlı sayfa navigasyonu.
- 🏗️ **Solid Mimari:** Kurumsal seviyede sürdürülebilirlik için SOLID prensipleri ve MVC mimarisi temel alınarak inşa edilmiştir.

---

## 📐 Mimari ve Tasarım Kararları (Architecture)

Proje, temiz kod (Clean Code) standartlarını sağlamak amacıyla sıkı bir katmanlı yapı (Layered Architecture) kullanır.

### Katmanlar

1.  **Presentation (View):** Flutter Widget'ları. Sadece UI deklarasyonlarını içerir, iş mantığı (business logic) barındırmaz.
2.  **Controller (ViewModel):** `ChangeNotifier` sınıfları. UI state'ini yönetir, repository'ler ile iletişim kurar.
3.  **Model:** Saf Dart veri sınıfları (`PdfDocumentModel`, `StrokeModel`, vb.).
4.  **Data (Repository):** Dış dünya ile iletişim (Dosya sistemi, PDF motoru). Bağımlılığın Tersine Çevrilmesi (DIP) prensibi gereği arayüzler (Interfaces) arkasına gizlenmiştir.

### Kullanılan Temel Teknolojiler

| Teknoloji | Görev | Gerekçe |
| :--- | :--- | :--- |
| **Flutter (Dart)** | UI Framework | Tek kod tabanından yüksek performanslı Windows ve Linux (Pardus) derlemesi. |
| **get_it** | Dependency Injection | Sınıflar arası sıkı bağımlılıkları (tight coupling) kırmak ve test edilebilirliği artırmak. |
| **provider** | State Management | Controller'ların (ChangeNotifier) reaktif olarak View'lara bağlanması. |
| **pdfrx** | PDF Rendering | PDFium tabanlı, performanslı ve Linux native desktop desteği. |
| **CustomPainter** | Çizim Motoru | Flutter'ın donanım hızlandırmalı tuvaline doğrudan, sıfır maliyetli (zero-overhead) erişim. |

---

## 📂 Proje Yapısı

Proje, özellik (feature) bazlı bir klasör yapısına sahiptir. Bu yaklaşım, kod tabanı büyüdükçe yatay ölçeklenebilirliği garanti eder.

```text
lib/
├── app.dart                  # Ana uygulama konfigürasyonu (Theme, Providers)
├── main.dart                 # Uygulama giriş noktası (Entry Point)
├── core/                     # Tüm projenin paylaştığı altyapı
│   ├── constants/            # Renkler, boyutlar, metinler
│   ├── di/                   # Service Locator (get_it) kurulumu
│   ├── theme/                # Global Flutter teması
│   └── utils/                # Yardımcı fonksiyonlar
├── features/                 # İzole özellik modülleri (MVC)
│   ├── drawing/              # CustomPainter, Stroke yönetimi
│   ├── home/                 # Ana sayfa layout orkestrasyonu
│   ├── pdf_viewer/           # pdfrx entegrasyonu, sayfa değişimi
│   ├── question/             # Bölge seçimi, modal yönetimi
│   └── toolbar/              # Araç çubuğu UI ve araç durumu
└── shared/                   # Yeniden kullanılabilir global widget'lar
```

---

## 🛠️ Kurulum ve Geliştirme

### Ortam Gereksinimleri
- **Flutter SDK:** 3.19.x veya daha yeni bir sürüm.
- **İşletim Sistemi:** Windows 10/11 veya Debian/Ubuntu tabanlı bir Linux (örn: Pardus 21+).

### Adımlar

1. Depoyu klonlayın ve bağımlılıkları yükleyin:
   ```bash
   flutter pub get
   ```

2. Kodu statik analize tabi tutun (Zorunlu pre-commit adımı):
   ```bash
   flutter analyze
   ```

3. Geliştirme modunda çalıştırın:
   ```bash
   # Windows için
   flutter run -d windows

   # Linux/Pardus için
   flutter run -d linux
   ```

---

## 🐳 Docker ile Linux Derlemesi (Pardus için)

Windows veya macOS üzerinde geliştirme yaparken, hedef platform olan Linux (Pardus) için izole edilmiş ve tekrarlanabilir bir yapı (build) almak amacıyla Docker kullanılır.

1. Proje kök dizininde aşağıdaki komutu çalıştırın:
   ```bash
   docker-compose -f docker/docker-compose.yml up --build
   ```

2. İşlem tamamlandığında, derlenmiş uygulama ve bağımlılıkları kök dizindeki `build/linux/x64/release/bundle/` klasörüne kopyalanacaktır.

---

## 🤖 Gelecek Planları: Opsiyonel AI Entegrasyonu (v2.0)

Mevcut mimari, ileride eklenebilecek bir AI çözümleyicisi için hazırlıklıdır.
- Öğretmenlerin tahtada seçtiği sorular, `QuestionModel` üzerindeki koordinatlar kullanılarak izole edilebilir.
- Sınıfın internet durumuna göre; yerel ağda çalışan bir **Ollama** sunucusuna (offline/gizlilik odaklı) veya doğrudan bulut tabanlı bir LLM API'sine yönlendirme yapacak `IAiRepository` soyutlaması planlanmaktadır (Bknz: `.env.example`).

---

## 📜 Lisans

Bu proje MIT Lisansı altında lisanslanmıştır. Detaylar için `LICENSE` dosyasına bakınız.
