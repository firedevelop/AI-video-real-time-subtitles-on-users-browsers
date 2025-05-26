const express = require('express');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = 3000;
const SUBS_FILE = path.join(__dirname, 'subtitles', 'subtitles.txt');

app.use(express.static(path.join(__dirname, 'public')));

app.get('/subtitles', (req, res) => {
  fs.readFile(SUBS_FILE, 'utf8', (err, data) => {
    if (err) {
      return res.status(200).send('⏳ Esperando subtítulos...');
    }
    res.send(data);
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Servidor activo en http://localhost:${PORT}`);
});
