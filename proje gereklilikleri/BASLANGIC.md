# 🚀 Antigravity — Başlangıç Talimatı

## Senden İstenilenler (Sırayla)

**1. Önce bu dosyaları oku:**
- `PROJECT_CONTEXT.md` → Projeyi anla
- `ANTIGRAVITY_PROMPT.md` → Teknik detaylar ve kod şablonları

**2. Sonra şu dosyaları oluştur (eksiksiz, çalışır kod):**

```
src/main.ts
src/preload.ts  
src/renderer.tsx
src/App.tsx
src/App.css
src/components/Toolbar.tsx
src/components/PdfViewer.tsx
src/components/QuestionModal.tsx
src/components/DrawingCanvas.tsx
src/components/AnswerPanel.tsx
src/services/claude.ts
src/types/index.ts
package.json
tsconfig.json
.env.example
.gitignore
```

**3. Kod yazarken dikkat et:**
- TypeScript strict mode
- Tüm yorumlar Türkçe
- Hata yönetimi (try/catch) her async fonksiyonda
- `contextIsolation: true`, `nodeIntegration: false` (güvenlik)
- Fabric.js + pdf.js canvas bindirme doğru yapılmalı

**4. Stil:**
- Koyu tema (akıllı tahta = karanlık arka plan)
- Büyük butonlar (dokunmatik ekran için ≥48px)
- Türkçe arayüz metinleri

---

## Teknoloji Özeti
| Katman | Teknoloji |
|--------|-----------|
| Masaüstü | Electron 28 |
| UI | React 18 + TypeScript |
| PDF | pdfjs-dist 4.x |
| Çizim | Fabric.js 5.x |
| AI | @anthropic-ai/sdk (claude-sonnet-4-6) |
| Paket | electron-forge + maker-deb |

Hazır olduğunda `npm start` ile çalışmalı!
