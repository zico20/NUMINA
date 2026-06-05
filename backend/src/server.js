import 'dotenv/config';
import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import { rateLimit } from 'express-rate-limit';
import { solveRouter } from './routes/solve.js';

const app = express();

const PORT = parseInt(process.env.PORT ?? '5000', 10);
const ORIGINS = (process.env.CORS_ORIGINS ?? '*').split(',').map(s => s.trim());
const WINDOW = parseInt(process.env.RATE_LIMIT_WINDOW_MS ?? '60000', 10);
const MAX = parseInt(process.env.RATE_LIMIT_MAX ?? '20', 10);

app.use(helmet());
app.use(cors({
  origin: ORIGINS.includes('*') ? true : ORIGINS,
}));
app.use(express.json({ limit: '12mb' })); // base64 images can be large

app.use(rateLimit({
  windowMs: WINDOW,
  max: MAX,
  standardHeaders: true,
  legacyHeaders: false,
}));

app.get('/', (_req, res) => res.json({
  name: 'smart-calc-backend',
  endpoints: ['GET /health', 'POST /solve'],
}));
app.get('/health', (_req, res) => res.json({ ok: true }));

app.use('/solve', solveRouter);

app.use((err, _req, res, _next) => {
  console.error('[ERR]', err);
  res.status(500).json({ error: 'internal_error' });
});

app.listen(PORT, () => {
  console.log(`smart-calc-backend listening on :${PORT}`);
});
