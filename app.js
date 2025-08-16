const express = require('express');
const db = require('./db');

const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
    res.send('Hello from Backend');
});

app.get('/db', async (req, res) => {
    try {
        const result = await db.query('SELECT NOW() AS current_time');
        res.json({
            message: 'DB connection successful!',
            current_time: result.rows[0].current_time
        });
    } catch (err) {
        console.error('DB connection error:', err);
        res.status(500).json({ error: 'Database connection failed' });
    }
});

app.listen(port, () => {
    console.log(`Backend running on port ${port}`);
});
