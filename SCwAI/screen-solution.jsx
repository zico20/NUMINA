// screen-solution.jsx — Step-by-step solution view with LaTeX
function SolutionScreen({ dark = true, lang = 'en', mode = 'step', onClose, onGraph, platform='ios' }) {
  const t = window.theme(dark);
  const isAr = lang === 'ar';
  const fontUI = isAr ? NUMINA.font.uiAr : NUMINA.font.ui;

  const L = isAr ? {
    title: 'الحل', problem: 'المسألة', answer: 'الإجابة',
    steps: 'خطوات الحل', explanation: 'الشرح',
    quick: 'حل سريع', step: 'خطوة بخطوة', graph: 'عرض بياني',
    share: 'مشاركة', save: 'حفظ', copy: 'نسخ LaTeX',
    why: 'لماذا؟', confidence: 'دقة عالية',
    s1t: 'فصل التكامل', s1d: 'نطبّق خاصية الخطية للتكامل لفصل كل حد على حدة.',
    s2t: 'تكامل كل حد', s2d: 'نستخدم قاعدة القوة: ∫xⁿ dx = xⁿ⁺¹/(n+1).',
    s3t: 'الجمع وإضافة الثابت', s3d: 'نجمع النتائج ونضيف ثابت التكامل C.',
  } : {
    title: 'Solution', problem: 'Problem', answer: 'Answer',
    steps: 'Step-by-step', explanation: 'Explanation',
    quick: 'Quick', step: 'Step-by-step', graph: 'Graph',
    share: 'Share', save: 'Save', copy: 'Copy LaTeX',
    why: 'Why?', confidence: 'High confidence',
    s1t: 'Split the integral', s1d: 'Apply linearity of integration to split each term.',
    s2t: 'Integrate each term', s2d: 'Use the power rule: ∫xⁿ dx = xⁿ⁺¹/(n+1).',
    s3t: 'Combine + add constant', s3d: 'Sum the antiderivatives and add the integration constant C.',
  };

  const steps = [
    { title: L.s1t, desc: L.s1d, tex: '\\int 2x^{2}\\,dx + \\int 3x\\,dx - \\int 5\\,dx' },
    { title: L.s2t, desc: L.s2d, tex: '\\frac{2x^{3}}{3} + \\frac{3x^{2}}{2} - 5x' },
    { title: L.s3t, desc: L.s3d, tex: '\\frac{2x^{3}}{3} + \\frac{3x^{2}}{2} - 5x + C' },
  ];

  return (
    <div style={{
      width: '100%', height: '100%', position: 'relative',
      background: t.bg, color: t.text, fontFamily: fontUI,
      direction: isAr ? 'rtl' : 'ltr', overflow: 'hidden',
      display: 'flex', flexDirection: 'column',
    }}>
      <Aurora dark={dark} intensity={0.6}/>

      {/* Top bar */}
      <div style={{
        position: 'relative', zIndex: 2,
        padding: platform === 'ios' ? '54px 16px 8px' : '46px 16px 8px',
        display: 'flex', alignItems: 'center', gap: 8,
      }}>
        <button onClick={onClose} style={{
          width: 36, height: 36, borderRadius: 10, border: `1px solid ${t.border}`,
          background: t.surface, color: t.textDim, display:'grid', placeItems:'center', cursor:'pointer',
        }}><Icon name={isAr?'chevR':'chevL'} size={18} color={t.textDim} /></button>
        <div style={{ flex: 1, fontSize: 17, fontWeight: 600 }}>{L.title}</div>
        <button style={{
          width: 36, height: 36, borderRadius: 10, border: `1px solid ${t.border}`,
          background: t.surface, color: t.textDim, display:'grid', placeItems:'center', cursor:'pointer',
        }}><Icon name="share" size={18} color={t.textDim} /></button>
      </div>

      {/* Mode toggle */}
      <div style={{ position: 'relative', zIndex: 2, padding: '4px 16px 12px' }}>
        <div style={{
          display: 'flex', background: t.surface, borderRadius: 12,
          padding: 3, border: `1px solid ${t.border}`,
        }}>
          {[{k:'quick',l:L.quick,i:'bolt'}, {k:'step',l:L.step,i:'book'}].map(it => (
            <button key={it.k} style={{
              flex: 1, padding: '10px 14px', borderRadius: 9, border: 'none', cursor: 'pointer',
              fontSize: 13, fontWeight: 600, fontFamily: fontUI,
              background: mode === it.k ? t.accent : 'transparent',
              color: mode === it.k ? (dark ? '#03130c' : '#fff') : t.textDim,
              display:'flex', alignItems:'center', justifyContent:'center', gap: 6,
            }}>
              <Icon name={it.i} size={14} color={mode===it.k ? (dark?'#03130c':'#fff') : t.textDim}/>
              {it.l}
            </button>
          ))}
        </div>
      </div>

      {/* Scrollable content */}
      <div style={{ position: 'relative', zIndex: 2, flex: 1, overflow: 'auto', padding: '4px 16px 16px' }}>
        {/* Problem card */}
        <div style={{
          background: t.surface, border: `1px solid ${t.border}`, borderRadius: 18,
          padding: 16, marginBottom: 12, position: 'relative', overflow: 'hidden',
        }}>
          <div style={{ display:'flex', alignItems:'center', gap: 8, marginBottom: 10 }}>
            <span style={{ fontSize: 11, fontWeight: 700, letterSpacing: 0.6, color: t.textMute }}>
              {L.problem.toUpperCase()}
            </span>
            <div style={{ flex: 1, height: 1, background: t.border }}/>
            <div style={{ display: 'flex', alignItems: 'center', gap: 4,
              padding: '3px 8px', borderRadius: 999, background: t.accentSoft,
              fontSize: 10, fontWeight: 600, color: t.accent,
            }}>
              <div style={{ width: 5, height: 5, borderRadius: 999, background: t.accent }}/>
              {L.confidence} · 98%
            </div>
          </div>
          <div style={{
            fontFamily: NUMINA.font.math, fontSize: 26, color: t.text,
            textAlign: 'center', direction: 'ltr', padding: '8px 0',
          }}>
            <Tex block>{`\\int (2x^{2} + 3x - 5)\\, dx`}</Tex>
          </div>
        </div>

        {/* Answer card */}
        <div style={{
          background: `linear-gradient(135deg, ${dark?'rgba(63,224,154,0.10)':'rgba(10,164,106,0.06)'} 0%, ${t.surface} 60%)`,
          border: `1px solid ${dark?'rgba(63,224,154,0.25)':'rgba(10,164,106,0.20)'}`,
          borderRadius: 18, padding: 16, marginBottom: 16, position: 'relative', overflow: 'hidden',
        }}>
          <div style={{ display:'flex', alignItems:'center', gap: 8, marginBottom: 10 }}>
            <Icon name="check" size={14} color={t.accent}/>
            <span style={{ fontSize: 11, fontWeight: 700, letterSpacing: 0.6, color: t.accent }}>
              {L.answer.toUpperCase()}
            </span>
          </div>
          <div style={{
            fontFamily: NUMINA.font.math, fontSize: 28, color: t.text,
            textAlign: 'center', direction: 'ltr', padding: '8px 0',
          }}>
            <Tex block>{`\\frac{2x^{3}}{3} + \\frac{3x^{2}}{2} - 5x + C`}</Tex>
          </div>
          <div style={{ display: 'flex', gap: 6, marginTop: 12 }}>
            <button onClick={onGraph} style={{
              flex: 1, padding: '8px 12px', borderRadius: 10, border: `1px solid ${t.border}`,
              background: t.bgRaised, color: t.text, fontSize: 12, fontWeight: 600,
              fontFamily: fontUI, cursor:'pointer', display:'flex', alignItems:'center', justifyContent:'center', gap:6,
            }}><Icon name="chart" size={14} color={t.text}/>{L.graph}</button>
            <button style={{
              flex: 1, padding: '8px 12px', borderRadius: 10, border: `1px solid ${t.border}`,
              background: t.bgRaised, color: t.text, fontSize: 12, fontWeight: 600,
              fontFamily: fontUI, cursor:'pointer', display:'flex', alignItems:'center', justifyContent:'center', gap:6,
            }}><Icon name="copy" size={14} color={t.text}/>{L.copy}</button>
            <button style={{
              flex: 1, padding: '8px 12px', borderRadius: 10, border: `1px solid ${t.border}`,
              background: t.bgRaised, color: t.text, fontSize: 12, fontWeight: 600,
              fontFamily: fontUI, cursor:'pointer', display:'flex', alignItems:'center', justifyContent:'center', gap:6,
            }}><Icon name="pin" size={14} color={t.text}/>{L.save}</button>
          </div>
        </div>

        {/* Steps */}
        {mode === 'step' && (
          <>
            <div style={{ fontSize: 12, fontWeight: 700, letterSpacing: 0.5, color: t.textMute,
              padding: '4px 4px 10px',
            }}>{L.steps.toUpperCase()}</div>
            {steps.map((s, i) => (
              <div key={i} style={{
                background: t.surface, border: `1px solid ${t.border}`, borderRadius: 16,
                padding: 14, marginBottom: 10, position: 'relative',
              }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 8 }}>
                  <div style={{
                    width: 26, height: 26, borderRadius: 999,
                    background: t.accentSoft, color: t.accent,
                    display: 'grid', placeItems: 'center',
                    fontFamily: NUMINA.font.mono, fontSize: 12, fontWeight: 700,
                  }}>{i+1}</div>
                  <div style={{ flex: 1, fontSize: 14, fontWeight: 600 }}>{s.title}</div>
                  <button style={{
                    padding: '3px 8px', borderRadius: 999, border: `1px solid ${t.border}`,
                    background: 'transparent', color: t.textDim, fontSize: 10, cursor:'pointer',
                    fontFamily: fontUI,
                  }}>{L.why}</button>
                </div>
                <div style={{ fontSize: 12.5, color: t.textDim, lineHeight: 1.5, marginBottom: 10 }}>
                  {s.desc}
                </div>
                <div style={{
                  background: dark ? 'rgba(0,0,0,0.3)' : '#f4f7f3',
                  borderRadius: 10, padding: '14px 12px',
                  fontFamily: NUMINA.font.math, fontSize: 18, direction: 'ltr',
                  textAlign: 'center', color: t.text,
                  border: `1px solid ${t.border}`,
                }}>
                  <Tex block>{s.tex}</Tex>
                </div>
              </div>
            ))}
          </>
        )}

        <div style={{ height: 16 }}/>
      </div>
    </div>
  );
}

window.SolutionScreen = SolutionScreen;
