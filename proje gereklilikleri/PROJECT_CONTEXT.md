# Akıllı Tahta — Proje Bağlamı ve Gereksinimler

## Kim İçin?
- **Kullanıcı:** Türk ilk/orta/lise öğretmenleri
- **Ortam:** Pardus (Debian tabanlı Türk Linux dağıtımı) işletim sistemli akıllı tahtalar
- **Ekran:** Dokunmatik, genellikle 65-86 inç büyük ekran (1920x1080 veya 4K)
- **Bağlantı:** İnternetsiz çalışmalı, sadece Claude API için internet kullanır

---

## Ne Yapıyor?

```
PDF Kitap → Yükle → Sayfalara Bak → Soru Seç → Büyüt → Çöz → Cevabı Gör
```

1. **PDF Yükleme**: Öğretmen test kitabı veya ders kitabını PDF olarak yükler
2. **Sayfa Görüntüleme**: Her sayfa net şekilde ekranda gösterilir
3. **Soru Seçme**: Öğretmen soruyu seçer (tıklayarak veya sürükleyerek bölge çizer)
4. **Büyütme**: Seçili soru tam ekrana açılır (büyüteç gibi)
5. **Üzerine Çizme**: Öğretmen soruyu tahta üzerinde adım adım çözer
6. **AI Cevabı**: "?" butonuna basınca Claude API soruyu otomatik çözer

---

## Referans Uygulama (Rakip/İlham)
Piyasadaki benzer akıllı tahta yazılımları:
- **EBA (MEB)**: Devlet platformu, PDF desteği kısıtlı
- **Morpa Kampüs**: Abonelik tabanlı, offline yok
- **Smart Notebook**: Pahalı, Türkçe destek zayıf

**Bizim farkımız**: Açık kaynak, ücretsiz, Pardus native, AI destekli çözüm gösterme

---

## Kullanıcı Hikayeleri

```
Olarak öğretmen:
✅ PDF kitabımı uygulamaya sürükle-bırak ile yükleyebilmeliyim
✅ Sayfalar arasında kaydırarak gezebilmeliyim
✅ Herhangi bir soruyu seçip tam ekrana açabilmeliyim
✅ Açık soruda kalemle, markerla çizim yapabilmeliyim
✅ Yanlış çizimi silgi ile silebilmeliyim
✅ Çizimimi geri alabilmeliyim (Ctrl+Z)
✅ Sorunun AI çözümünü görebilmeliyim
✅ AI cevabını kopyalayabilmeliyim
✅ Sayfanın tamamını PDF olarak kaydedebilmeliyim
```

---

## Arayüz Tasarımı

```
┌─────────────────────────────────────────────────────────────┐
│  [☰ Menü]  Akıllı Tahta  [PDF Yükle]      Sayfa: 3 / 24   │
├──────────┬──────────────────────────────────┬───────────────┤
│          │                                  │               │
│ ARAÇLAR  │     PDF SAYFA GÖRÜNTÜLEYİCİ     │  CEVAP PANELİ│
│          │                                  │               │
│ ✏️ Kalem  │  ┌─ SORU 1 ────────────────┐    │  📝 Claude   │
│ 🖊️ Marker │  │ Bir trenin hızı...      │    │  Cevabı:     │
│ ⬜ Silgi  │  │                     [?] │    │              │
│ 🔤 Metin  │  └─────────────────────────┘    │  1. Adım...  │
│          │                                  │  2. Adım...  │
│ RENKLER  │  ┌─ SORU 2 ────────────────┐    │              │
│ ⬛⬜🔴   │  │ x + 5 = 12 ise x=?     │    │  Sonuç: 7    │
│ 🔵🟢🟡   │  │                     [?] │    │              │
│          │  └─────────────────────────┘    │  [📋 Kopyala]│
│ Kalınlık │                                  │  [✕ Kapat]  │
│ ━━━━━    │                                  │               │
│          │                                  │               │
│ [↩ Geri] │                                  │               │
│ [↪ İleri]│                                  │               │
└──────────┴──────────────────────────────────┴───────────────┘
```

---

## Soru Büyütme Modalı (QuestionModal)

```
┌──────────────────────────────────────────────────────────────┐
│  [✕ Kapat]                           [? Claude ile Çöz]      │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│                                                              │
│    BİR TRENİN HIZI 80 KM/S'TİR. 2 SAATTE KAÇ KM              │
│    YOL ALIR?                                                 │
│                                                              │
│    (Öğretmenin çizim alanı — büyük ve net)                   │
│                                                              │
│    ✏️ h = 80 km/s                                            │
│    ✏️ t = 2 s                                                │
│    ✏️ d = h × t = 80 × 2 = 160 km ✓                         │
│                                                              │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

---

## Teknik Kısıtlar

| Kısıt | Detay |
|-------|-------|
| OS | Pardus 21+ (Debian 11 tabanlı) |
| Mimari | x86_64 (amd64) |
| Min RAM | 4 GB |
| Node.js | v20 LTS |
| Electron | v28+ |
| Ekran | 1920×1080 minimum |
| İnternet | Sadece Claude API için |

---

## Bağımlılıklar (npm)

```json
{
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "pdfjs-dist": "^4.0.0",
    "fabric": "^5.3.0",
    "@anthropic-ai/sdk": "^0.24.0",
    "dotenv": "^16.0.0"
  },
  "devDependencies": {
    "@electron-forge/cli": "^7.0.0",
    "@electron-forge/maker-deb": "^7.0.0",
    "@electron-forge/plugin-webpack": "^7.0.0",
    "electron": "^28.0.0",
    "typescript": "^5.0.0",
    "@types/react": "^18.0.0",
    "@types/react-dom": "^18.0.0",
    "@types/fabric": "^5.3.0"
  }
}
```

---

## Claude API Kullanımı

- **Model**: `claude-sonnet-4-6` (hız/kalite dengesi için)
- **Max tokens**: 2048 (uzun çözümler için)
- **Dil**: Türkçe (prompt'ta belirtiliyor)
- **Format**: Adım adım, numaralı liste
- **Hata durumu**: "API'ye bağlanılamadı" mesajı göster, uygulamayı çökertme

---

## Gelecek Özellikler (v2)

- [ ] Tesseract.js ile OCR → soruları otomatik tespit et
- [ ] Çizim kaydet (PNG/PDF olarak dışa aktar)
- [ ] Çoklu PDF sekme desteği
- [ ] Öğrenci modu (sadece görüntüleme, çizim yok)
- [ ] Beyaz tahta modu (PDF olmadan boş tahta)
- [ ] QR kod ile soruyu öğrencilerin telefonuna gönder

---

## Proje Deposu Yapısı

```
akilli-tahta/
├── README.md
├── ANTIGRAVITY_PROMPT.md    ← Ana geliştirme promptu
├── PROJECT_CONTEXT.md       ← Bu dosya
├── .env.example             ← API anahtarı şablonu
├── .gitignore               ← .env, node_modules, dist hariç
├── package.json
├── tsconfig.json
├── src/
│   ├── main.ts
│   ├── preload.ts
│   ├── renderer.tsx
│   ├── App.tsx
│   ├── App.css
│   ├── components/
│   │   ├── Toolbar.tsx
│   │   ├── PdfViewer.tsx
│   │   ├── QuestionModal.tsx
│   │   ├── DrawingCanvas.tsx
│   │   └── AnswerPanel.tsx
│   ├── services/
│   │   └── claude.ts
│   └── types/
│       └── index.ts
└── assets/
    └── icon.png
```

---

## Sık Sorulan Teknik Sorular

**S: pdf.js worker neden ayrı?**
C: pdf.js render işlemini ayrı thread'de yapar. Worker dosyasını webpack config'de `CopyPlugin` ile public klasörüne kopyala.

**S: Fabric.js ve PDF canvas çakışıyor mu?**
C: Hayır. PDF canvas `z-index: 1`, Fabric canvas `z-index: 2, pointer-events: all` olarak bindiri.

**S: API anahtarı güvenliği?**
C: `.env` sadece `main.ts`'de okunur (Node.js ortamı). Renderer'a `ipcMain.handle` üzerinden gerekirse geçilir. Asla `renderer.tsx`'e doğrudan import edilmez.

**S: Pardus'ta dokunmatik çalışır mı?**
C: Electron Chromium tabanlı olduğu için dokunmatik olaylar otomatik desteklenir. Fabric.js de touch event'leri handle eder.
