import { Router } from 'express';
import { z } from 'zod';
import { solveImage } from '../services/openai_solver.js';

export const solveRouter = Router();

const Body = z.object({
  imageBase64: z.string().min(64, 'image too small'),
  mode: z.enum(['quick', 'detailed']).default('quick'),
  lang: z.enum(['en', 'ar']).default('en'),
});

solveRouter.post('/', async (req, res) => {
  const parsed = Body.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({
      error: 'invalid_body',
      details: parsed.error.flatten(),
    });
  }
  try {
    const out = await solveImage(parsed.data);
    // Lightweight token logging for cost tracking.
    if (out.usage) {
      const tag = out.isMath ? 'solve' : 'refused';
      console.log(`[${tag}] in=${out.usage.prompt_tokens} out=${out.usage.completion_tokens} total=${out.usage.total_tokens}`);
    }
    // Don't ship internal usage to the client.
    const { usage: _u, ...payload } = out;
    res.json(payload);
  } catch (e) {
    if (e?.status === 429) return res.status(429).json({ error: 'rate_limited' });
    if (e?.status === 400) return res.status(400).json({ error: 'bad_image' });
    console.error(e);
    res.status(502).json({ error: 'upstream_error' });
  }
});
