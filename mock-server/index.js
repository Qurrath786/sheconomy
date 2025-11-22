const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');

const app = express();
app.use(cors());

const dataPath = path.join(__dirname, 'data', 'mock_insights.json');

app.get('/insights', (req, res) => {
    const from = req.query.from;
    const to = req.query.to;
    const raw = fs.readFileSync(dataPath);
    const obj = JSON.parse(raw);
    obj.range = { from: from || obj.range.from, to: to || obj.range.to };
    res.json(obj);
  });
  

app.get('/api/insights/export', (req, res) => {
  const raw = fs.readFileSync(dataPath);
  const obj = JSON.parse(raw);
  const rows = [
    'id,date,title,category,type,amount',
    ...obj.recent_activity.map(a => `${a.id},${a.date},${a.title},${a.category},${a.type},${a.amount}`)
  ].join('\n');
  res.setHeader('Content-Type', 'text/csv');
  res.setHeader('Content-Disposition', 'attachment; filename="insights_export.csv"');
  res.send(rows);
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Mock server running on http://localhost:${PORT}`));
