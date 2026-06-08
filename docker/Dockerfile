# Akıllı Tahta — Flutter Linux Build Container
# Bu Dockerfile, Pardus/Linux hedefi için Flutter uygulamasını derler.
#
# Kullanım:
#   docker-compose -f docker/docker-compose.yml up --build
#
# Çıktı:
#   build/linux/x64/release/bundle/ dizininde çalıştırılabilir dosya

FROM ubuntu:22.04 AS builder

# Zaman dilimi etkileşimli sorulmasın
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Istanbul

# Sistem bağımlılıklarını kur
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    clang \
    cmake \
    ninja-build \
    pkg-config \
    libgtk-3-dev \
    liblzma-dev \
    libstdc++-12-dev \
    && rm -rf /var/lib/apt/lists/*

# Flutter SDK kur (stable kanal)
RUN git clone https://github.com/flutter/flutter.git -b stable /flutter
ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Linux desktop desteğini etkinleştir
RUN flutter config --enable-linux-desktop
RUN flutter doctor -v

# Proje bağımlılıklarını önceden indir (cache optimizasyonu)
WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Proje dosyalarını kopyala ve derle
COPY . .
RUN flutter build linux --release

# ─── Sonuç ───
# Derlenmiş uygulama: /app/build/linux/x64/release/bundle/
# Bu dizin doğrudan Pardus'a kopyalanabilir.
