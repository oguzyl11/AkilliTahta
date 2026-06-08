# Akıllı Tahta Uygulaması — Antigravity Proje Promptu

## Görevin
Sen bir Electron + React + TypeScript masaüstü uygulaması geliştireceksin. Bu uygulama, Pardus (Debian tabanlı Linux) üzerinde çalışan, PDF formatındaki test ve ders kitaplarını etkileşimli akıllı tahta deneyimine dönüştüren bir eğitim yazılımıdır.

---

## Projenin Amacı
Türk okullardaki akıllı tahtalarda kullanılmak üzere:
- PDF kitapları yükle → her soruyu büyüteçle tam ekrana aç
- Öğretmen soruları kalem/silgi/marker ile tahta üzerinde çözsün
- Her sorunun yanında "?" butonu olsun → Claude AI cevabı göstersin
- Tamamen offline çalışsın (sadece Claude API için internet gerekli)

---

## Teknoloji Yığını
```
Electron 28+          → Masaüstü uygulama (Pardus/Linux)
React 18 + TypeScript → Arayüz
Webpack               → Bundler (electron-forge webpack-typescript şablonu)
pdf.js (pdfjs-dist)   → PDF render
Fabric.js             → Çizim canvas katmanı
@anthropic-ai/sdk     → Claude API entegrasyonu
electron-builder      → .deb paketi üretimi
```

---

## Klasör Yapısı (Oluşturulacak)
```
akilli-tahta/
├── src/
│   ├── main.ts                  ← Electron ana süreç
│   ├── preload.ts               ← IPC köprüsü (contextBridge)
│   ├── renderer.tsx             ← React entry point
│   ├── App.tsx                  ← Ana uygulama bileşeni
│   ├── components/
│   │   ├── Toolbar.tsx          ← Sol panel: araç çubuğu (kalem, silgi, renkler)
│   │   ├── PdfViewer.tsx        ← PDF sayfalarını listeleyen ana görünüm
│   │   ├── QuestionModal.tsx    ← Soruyu büyütüp tam ekrana açan modal
│   │   ├── DrawingCanvas.tsx    ← Fabric.js çizim katmanı
│   │   └── AnswerPanel.tsx      ← Claude'dan gelen cevabı gösteren sağ panel
│   ├── services/
│   │   └── claude.ts            ← Claude API çağrıları
│   └── types/
│       └── index.ts             ← Ortak TypeScript tipleri
├── assets/
│   └── icons/                   ← Uygulama ikonları
├── .env                         ← ANTHROPIC_API_KEY (git'e ekleme!)
├── .gitignore
├── package.json
├── tsconfig.json
└── webpack.*.config.js          ← electron-forge tarafından otomatik üretilir
```

---

## Kurulum Komutları (Sırayla Çalıştır)
```bash
# 1. Node.js 20 LTS kur (Pardus'ta)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
sudo apt-get install -y nodejs

# 2. Projeyi oluştur
npm create electron-app@latest akilli-tahta -- --template=webpack-typescript
cd akilli-tahta

# 3. Bağımlılıkları yükle
npm install pdfjs-dist fabric @anthropic-ai/sdk
npm install react react-dom
npm install -D @types/react @types/react-dom

# 4. API anahtarını ayarla
echo "ANTHROPIC_API_KEY=sk-ant-BURAYA_ANAHTARINI_YAZ" > .env

# 5. Geliştirme modunda çalıştır
npm start
```

---

## Dosya İçerikleri

### `src/main.ts`
```typescript
import { app, BrowserWindow, ipcMain, dialog } from 'electron';
import path from 'path';
import fs from 'fs';

declare const MAIN_WINDOW_WEBPACK_ENTRY: string;
declare const MAIN_WINDOW_PRELOAD_WEBPACK_ENTRY: string;

function createWindow() {
  const win = new BrowserWindow({
    width: 1400,
    height: 900,
    fullscreen: false,
    backgroundColor: '#1a1a2e',
    webPreferences: {
      preload: MAIN_WINDOW_PRELOAD_WEBPACK_ENTRY,
      contextIsolation: true,
      nodeIntegration: false,
    },
  });

  win.loadURL(MAIN_WINDOW_WEBPACK_ENTRY);
}

// PDF dosyası seçme dialog'u
ipcMain.handle('dialog:openPdf', async () => {
  const result = await dialog.showOpenDialog({
    filters: [{ name: 'PDF Dosyaları', extensions: ['pdf'] }],
    properties: ['openFile'],
  });
  if (result.canceled) return null;
  const filePath = result.filePaths[0];
  const buffer = fs.readFileSync(filePath);
  return buffer.toString('base64');
});

app.whenReady().then(createWindow);
app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});
```

### `src/preload.ts`
```typescript
import { contextBridge, ipcRenderer } from 'electron';

contextBridge.exposeInMainWorld('electronAPI', {
  openPdf: () => ipcRenderer.invoke('dialog:openPdf'),
});
```

### `src/services/claude.ts`
```typescript
import Anthropic from '@anthropic-ai/sdk';

const client = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
});

export interface SoruCevap {
  soru: string;
  cevap: string;
  yukleniyor: boolean;
}

export async function soruCoz(
  soruMetni: string,
  sinifSeviyesi: string = 'ortaokul'
): Promise<string> {
  const response = await client.messages.create({
    model: 'claude-sonnet-4-6',
    max_tokens: 2048,
    messages: [
      {
        role: 'user',
        content: `Sen bir ${sinifSeviyesi} öğrencisine ders veren deneyimli bir Türk öğretmenisin.
        
Aşağıdaki soruyu adım adım çöz. Açıklamaları sade ve anlaşılır Türkçe ile yaz.
Matematiksel ifadeleri açık şekilde yaz. Her adımı numaralandır.

SORU:
${soruMetni}

Cevabını şu formatta ver:
1. Soruyu anla ve ne istendiğini belirt
2. Çözüm adımları (numaralı)
3. Sonuç / Cevap (kalın yaz)`,
      },
    ],
  });

  const block = response.content[0];
  return block.type === 'text' ? block.text : 'Cevap alınamadı.';
}

export async function sayfayiAnalizeEt(
  sayfaMetni: string
): Promise<string[]> {
  const response = await client.messages.create({
    model: 'claude-sonnet-4-6',
    max_tokens: 1024,
    messages: [
      {
        role: 'user',
        content: `Aşağıdaki sayfa metninde kaç soru var ve hangi konuları kapsıyor?
Soruları listele. Her soru için kısa bir özet ver.
Yanıtı JSON formatında ver: {"sorular": [{"numara": 1, "ozet": "..."}]}

METİN:
${sayfaMetni}`,
      },
    ],
  });

  try {
    const block = response.content[0];
    const text = block.type === 'text' ? block.text : '{}';
    const data = JSON.parse(text);
    return data.sorular?.map((s: {numara: number, ozet: string}) => s.ozet) || [];
  } catch {
    return [];
  }
}
```

### `src/types/index.ts`
```typescript
export interface PDFPage {
  pageNumber: number;
  width: number;
  height: number;
}

export interface Question {
  id: string;
  pageNumber: number;
  bounds: {
    x: number;
    y: number;
    width: number;
    height: number;
  };
  text?: string;
  answered?: boolean;
}

export interface DrawingTool {
  type: 'pen' | 'eraser' | 'marker' | 'text' | 'select';
  color: string;
  size: number;
}

export interface AppState {
  pdfData: string | null;       // base64 PDF verisi
  currentPage: number;
  totalPages: number;
  selectedQuestion: Question | null;
  drawingTool: DrawingTool;
  showAnswer: boolean;
  currentAnswer: string;
  isLoading: boolean;
}
```

### `src/App.tsx`
```tsx
import React, { useState, useCallback } from 'react';
import Toolbar from './components/Toolbar';
import PdfViewer from './components/PdfViewer';
import AnswerPanel from './components/AnswerPanel';
import QuestionModal from './components/QuestionModal';
import { AppState, Question, DrawingTool } from './types';
import { soruCoz } from './services/claude';

const initialState: AppState = {
  pdfData: null,
  currentPage: 1,
  totalPages: 0,
  selectedQuestion: null,
  drawingTool: { type: 'pen', color: '#000000', size: 3 },
  showAnswer: false,
  currentAnswer: '',
  isLoading: false,
};

export default function App() {
  const [state, setState] = useState<AppState>(initialState);

  const handlePdfLoad = useCallback(async () => {
    const base64 = await (window as any).electronAPI.openPdf();
    if (base64) {
      setState(prev => ({ ...prev, pdfData: base64, currentPage: 1 }));
    }
  }, []);

  const handleQuestionSelect = useCallback((question: Question) => {
    setState(prev => ({ ...prev, selectedQuestion: question }));
  }, []);

  const handleAnswerRequest = useCallback(async (questionText: string) => {
    setState(prev => ({ ...prev, isLoading: true, showAnswer: true, currentAnswer: '' }));
    try {
      const answer = await soruCoz(questionText);
      setState(prev => ({ ...prev, currentAnswer: answer, isLoading: false }));
    } catch (err) {
      setState(prev => ({
        ...prev,
        currentAnswer: 'Hata: Claude API\'ye bağlanılamadı.',
        isLoading: false,
      }));
    }
  }, []);

  const handleToolChange = useCallback((tool: DrawingTool) => {
    setState(prev => ({ ...prev, drawingTool: tool }));
  }, []);

  return (
    <div className="app-container">
      <Toolbar
        currentTool={state.drawingTool}
        onToolChange={handleToolChange}
        onPdfLoad={handlePdfLoad}
        currentPage={state.currentPage}
        totalPages={state.totalPages}
        onPageChange={(page) => setState(prev => ({ ...prev, currentPage: page }))}
      />

      <main className="main-content">
        <PdfViewer
          pdfData={state.pdfData}
          currentPage={state.currentPage}
          drawingTool={state.drawingTool}
          onTotalPagesChange={(total) => setState(prev => ({ ...prev, totalPages: total }))}
          onQuestionSelect={handleQuestionSelect}
          onAnswerRequest={handleAnswerRequest}
        />

        {state.showAnswer && (
          <AnswerPanel
            answer={state.currentAnswer}
            isLoading={state.isLoading}
            onClose={() => setState(prev => ({ ...prev, showAnswer: false }))}
          />
        )}
      </main>

      {state.selectedQuestion && (
        <QuestionModal
          question={state.selectedQuestion}
          pdfData={state.pdfData}
          drawingTool={state.drawingTool}
          onClose={() => setState(prev => ({ ...prev, selectedQuestion: null }))}
          onAnswerRequest={handleAnswerRequest}
        />
      )}
    </div>
  );
}
```

---

## Bileşen Görevleri

### `Toolbar.tsx`
- Sol kenar çubuğu
- PDF Yükle butonu
- Araçlar: Kalem | Marker | Silgi | Metin | Seç
- Renk paleti (6-8 renk)
- Fırça kalınlığı slider
- Sayfa ileri/geri navigasyonu
- Undo/Redo butonları

### `PdfViewer.tsx`
- pdf.js ile PDF'i canvas'a render et
- Her sayfayı sırayla göster (scroll ile)
- Fabric.js çizim katmanını PDF canvas üstüne bindiri
- Kullanıcı bölge seçerse → QuestionModal aç
- Her otomatik tespit edilen soru bölgesine "?" butonu ekle

### `QuestionModal.tsx`
- Seçili soruyu tam ekrana büyüt
- Üzerine çizim yapılabilir (DrawingCanvas)
- Sağ üstte "?" → Claude cevabı al
- ESC veya X ile kapat

### `DrawingCanvas.tsx`
- Fabric.js canvas wrapper
- Kalem, marker, silgi, metin araçları
- Her araç değişiminde Fabric'i güncelle
- Çizim geçmişi (undo/redo stack)

### `AnswerPanel.tsx`
- Sağdan süzülen panel
- Claude'dan gelen markdown cevabı göster
- Yükleniyor animasyonu
- Kopyala butonu
- Kapat (X) butonu

---

## Önemli Teknik Notlar

1. **pdf.js worker**: `pdfjs-dist/build/pdf.worker.js` dosyasını webpack ile doğru kopyala
2. **Fabric.js + pdf.js**: PDF canvas'ı `position: absolute`, Fabric canvas'ı `position: absolute; pointer-events: all` olmalı
3. **IPC güvenliği**: `nodeIntegration: false`, `contextIsolation: true` — tüm Node işlemleri `ipcMain.handle` üzerinden
4. **API anahtarı**: `.env` dosyası → `dotenv` paketi main process'te yüklenecek
5. **Soru tespiti**: İlk aşamada kullanıcı manuel seçsin (rubber-band selection), 2. aşamada Tesseract.js ile OCR eklenebilir

---

## Paketleme (.deb için package.json eki)
```json
{
  "scripts": {
    "start": "electron-forge start",
    "build": "electron-forge build",
    "make": "electron-forge make"
  },
  "config": {
    "forge": {
      "makers": [
        {
          "name": "@electron-forge/maker-deb",
          "config": {
            "options": {
              "maintainer": "Akıllı Tahta Ekibi",
              "homepage": "https://github.com/projen",
              "categories": ["Education"],
              "depends": ["libgtk-3-0", "libnotify4", "libnss3", "libxss1"]
            }
          }
        }
      ]
    }
  }
}
```

---

## Geliştirme Aşamaları (Sıra ile)

### Faz 1 — Temel İskelet ✅ (Bu prompt)
- [ ] Electron pencere aç
- [ ] PDF yükle ve ekranda göster
- [ ] Temel araç çubuğu

### Faz 2 — Çizim
- [ ] Fabric.js canvas entegrasyonu
- [ ] Kalem / silgi / marker
- [ ] Undo/Redo

### Faz 3 — Soru Sistemi
- [ ] Rubber-band selection (bölge seç)
- [ ] "?" butonu her soruya
- [ ] QuestionModal (büyüteç görünümü)

### Faz 4 — Claude Entegrasyonu
- [ ] soruCoz() fonksiyonu
- [ ] AnswerPanel bileşeni
- [ ] Yükleniyor animasyonu

### Faz 5 — Pardus Paketleme
- [ ] .deb paketi
- [ ] Uygulama ikonu
- [ ] Kurulum testi

---

## Senden İstenilenler
Yukarıdaki yapıya göre **eksiksiz, çalışır TypeScript/React kodu** yaz.
Tüm bileşenleri oluştur. Yorum satırları Türkçe olsun.
Her dosyayı ayrı ayrı ver, birleştirme.
