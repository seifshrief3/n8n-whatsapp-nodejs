// index.js

const express = require('express');
const axios = require('axios');
const qrcode = require('qrcode-terminal');
const { Client, LocalAuth } = require('whatsapp-web.js');
const { setTimeout } = require('timers/promises'); // لتأخير الرسالة

const app = express();
app.use(express.json());

const PORT = process.env.PORT || 3000;
const N8N_WEBHOOK_URL = process.env.N8N_WEBHOOK_URL;

// إعدادات العميل (ضرورية لـ Railway)
const client = new Client({
  authStrategy: new LocalAuth({ clientId: "whatsapp-n8n" }),
  puppeteer: {
    headless: true,
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--single-process',
      '--disable-dev-shm-usage',
      '--disable-accelerated-2d-canvas',
      '--no-first-run',
      '--no-zygote',
      '--disable-gpu',
    ],
    executablePath: process.env.PUPPETEER_EXECUTABLE_PATH,
  },
});

client.on('qr', (qr) => {
  // بيطبع الـ QR Code في Logs Railway
  console.log('\n--- SCAN THIS QR CODE (whatapp-web.js) ---\n');
  qrcode.generate(qr, { small: true });
  console.log('\n---------------------------\n');
});

client.on('ready', () => {
  console.log('Client is ready! WhatsApp connection opened successfully!');
});

client.on('message', async message => {
  const text = message.body;
  const sender = message.from;

  if (text && N8N_WEBHOOK_URL) {
    try {
      // إرسال الرسالة إلى n8n Webhook
      await axios.post(N8N_WEBHOOK_URL, {
        senderId: sender,
        messageContent: text
      });
      await setTimeout(2000); // تأخير للأمان
    } catch (error) {
      console.error('Failed to send to n8n:', error.message);
    }
  }
});

client.initialize();

// سيرفر Express API للردود من n8n
app.post('/send-reply', async (req, res) => {
  const { chatId, replyText } = req.body;

  if (!chatId || !replyText) {
    return res.status(400).send({ error: 'Missing chat ID or text' });
  }

  try {
    await client.sendMessage(chatId, replyText);
    console.log(`Reply sent to ${chatId}`);
    res.status(200).send({ status: 'Message sent' });
  } catch (e) {
    console.error('Error sending message:', e);
    res.status(500).send({ status: 'Internal server error', details: e.message });
  }
});

// تشغيل السيرفر
app.listen(PORT, () => {
  console.log(`Custom API server running on port ${PORT}`);
});