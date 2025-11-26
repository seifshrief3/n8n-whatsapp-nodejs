FROM node:20-slim

# تثبيت متطلبات Puppeteer/Chromium الأساسية لـ whatsapp-web.js
RUN apt-get update && apt-get install -y \
    wget unzip \
    libgbm-dev \
    libxshmfence-dev \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# تثبيت Chromium
RUN wget -q https://storage.googleapis.com/chromium-browser-snapshots/Linux_x64/1047754/chrome-linux.zip \
    && unzip chrome-linux.zip \
    && rm chrome-linux.zip

ENV CHROME_BIN /usr/bin/google-chrome
ENV PUPPETEER_EXECUTABLE_PATH /app/chrome-linux/chrome

WORKDIR /app

COPY package.json .
COPY index.js .

RUN npm install

CMD ["npm", "start"]