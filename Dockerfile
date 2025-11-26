# استخدم صورة Node.js رسمية وأكثر ثباتاً
FROM node:20

# تثبيت متطلبات Puppeteer/Chromium الأساسية 
# (مهمة لـ whatsapp-web.js)
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
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# وضع الأكواد وتسطيب المكتبات
WORKDIR /app

COPY package.json .
COPY index.js .

# نستخدم التثبيت النظيف للمكتبات (هنا هيتم تنزيل Puppeteer و Chromium)
RUN npm install

# الأمر اللي بيشغل السيرفر
CMD ["npm", "start"]