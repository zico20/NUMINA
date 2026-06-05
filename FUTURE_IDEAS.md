# Future Ideas / Backlog

Ideas saved for later — kept out of the main backlog so we don't lose them
but don't act on them now.

## AI Solver — Two-call "Extracted Preview" flow

Currently we make a single OpenAI call that returns both the extracted
LaTeX *and* the final answer/steps in one shot. This minimises tokens.

The original SCwAI design also had an intermediate "Extracted" stage
where the user sees the parsed equation and confirms before paying for
the solve. To enable that **without doubling token cost**, we'd need:

1. **Cheap extraction call**: a small model (gpt-4o-mini or vision) that
   only does OCR → returns LaTeX. ~50-150 output tokens.
2. **User confirmation UI**: card showing the LaTeX with an "Edit" option
   so they can correct misreads before solving.
3. **Solve call**: full GPT-4o with the user-confirmed LaTeX as text-only
   input (no image). Cheaper than re-uploading the image.

Net cost is roughly the same as today *if* the user doesn't edit (one
small + one large call vs. one large call). The win is correctness:
fewer wrong solves due to OCR errors.

Add when:
- Users start reporting "wrong equation" failures
- Or we have prompt-caching headroom to amortize the extra call
- Or we add a "save my equations" feature where editing is valuable

## AI Solver — Other future ideas

- **Manual LaTeX editor** before solving (lets user fix OCR by hand)
- **Multi-equation pages**: detect each equation, solve each separately
- **Hand-drawn equation support** (already partially works with GPT-4o)
- **OCR-only "Convert to LaTeX" mode** without solving
- **Solve history with cloud sync** (Firebase) for paid users
- **Voice input**: read out a math problem
