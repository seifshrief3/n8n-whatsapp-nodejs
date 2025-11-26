# استخدم صورة Node.js رسمية وأكثر ثباتاً
FROM node:20

# تثبيت متطلبات Puppeteer/Chromium الأساسية 
# (تمت إضافة libgbm.so.2 وتوابعها لحل مشكلة Shared Libraries)
RUN apt-get update \
    && apt-get install -y \
    ca-certificates \
    fonts-liberation \
    libappindicator3-1 \
    libasound2 \
    libatk-bridge2.0-0 \
    libcurl4 \
    libgdk-pixbuf2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libxss1 \
    libxtst6 \
    xdg-utils \
    libgbm-dev \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# وضع الأكواد وتسطيب المكتبات
WORKDIR /app

COPY package.json .
COPY index.js .

# تثبيت المكتبات (هنا بيتم تنزيل Puppeteer و Chromium)
RUN npm install

# الأمر اللي بيشغل السيرفر
CMD ["npm", "start"]