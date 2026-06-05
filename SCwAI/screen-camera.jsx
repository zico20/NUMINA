// screen-camera.jsx — AI capture flow (camera framing → analyzing → extracted)

function CameraScreen({ dark = true, lang = 'en', onClose, onExtracted, platform='ios' }) {
  const t = window.theme(dark);
  const isAr = lang === 'ar';
  const fontUI = isAr ? NUMINA.font.uiAr : NUMINA.font.ui;
  const [stage, setStage] = React.useState('framing'); // framing | analyzing | extracted
  const [flash, setFlash] = React.useState(false);

  const L = isAr ? {
    title: 'الكاميرا الذكية',
    hint: 'وجّه الكاميرا نحو المعادلة',
    sub: 'أبقِ المعادلة داخل الإطار وتجنب الانعكاسات',
    capture: 'التقاط',
    gallery: 'المعرض',
    paste: 'لصق',
    analyzing: 'جاري التحليل…',
    analyzeSub: 'النموذج يقرأ المعادلة بصيغة LaTeX',
    extracted: 'المعادلة المستخرجة',
    edit: 'تعديل',
    confirm: 'متابعة الحل',
    quickSolve: 'حل سريع',
    stepSolve: 'حل تفصيلي',
  } : {
    title: 'AI Vision',
    hint: 'Frame the equation',
    sub: 'Keep the equation inside the frame, avoid glare',
    capture: 'Capture',
    gallery: 'Gallery',
    paste: 'Paste',
    analyzing: 'Analyzing…',
    analyzeSub: 'Reading the equation as LaTeX',
    extracted: 'Extracted equation',
    edit: 'Edit',
    confirm: 'Continue',
    quickSolve: 'Quick solve',
    stepSolve: 'Step-by-step',
  };

  const capture = () => {
    setFlash(true);
    setTimeout(() => setFlash(false), 200);
    setTimeout(() => setStage('analyzing'), 250);
    setTimeout(() => setStage('extracted'), 2400);
  };

  // Hand-drawn equation on a paper background (SVG)
  const PaperWithEquation = () => (
    <div style={{
      position: 'absolute', inset: 0,
      background: 'linear-gradient(180deg, #1a2820 0%, #0c1a14 100%)',
      overflow: 'hidden',
    }}>
      {/* Mock photo */}
      <div style={{
        position: 'absolute', top: '20%', left: '10%', right: '10%', bottom: '30%',
        borderRadius: 8, transform: 'rotate(-1.5deg)',
        background: '#f4ecd8',
        boxShadow: '0 30px 60px rgba(0,0,0,0.5), inset 0 0 60px rgba(120,90,40,0.15)',
        backgroundImage: `repeating-linear-gradient(0deg, transparent 0, transparent 28px, rgba(80,120,140,0.18) 28px, rgba(80,120,140,0.18) 29px)`,
      }}>
        <div style={{
          position: 'absolute', inset: '20% 8% 20% 8%',
          fontFamily: '"Caveat", "Patrick Hand", cursive',
          color: '#1a2030', fontSize: 32, lineHeight: 1.6,
        }}>
          <div style={{ fontFamily: NUMINA.font.math, fontStyle: 'italic', fontSize: 28 }}>
            ∫(2x² + 3x − 5) dx
          </div>
          <div style={{ marginTop: 14, opacity: 0.7, fontSize: 22, fontFamily: NUMINA.font.math, fontStyle:'italic' }}>
            = ?
          </div>
        </div>
      </div>
    </div>
  );

  // Animated scan line during analyzing
  const ScanOverlay = () => (
    <div style={{ position: 'absolute', inset: 0, pointerEvents: 'none' }}>
      <div style={{
        position: 'absolute', left: 0, right: 0, height: 60,
        background: `linear-gradient(180deg, transparent, ${t.accent}40, transparent)`,
        animation: 'scan 1.6s ease-in-out infinite',
        boxShadow: `0 0 40px ${t.accent}`,
      }} />
      <style>{`@keyframes scan { 0%,100%{ top: 20%; } 50%{ top: 65%; } }`}</style>
    </div>
  );

  // Frame corners for framing stage
  const Corners = () => {
    const C = ({ style }) => (
      <div style={{
        position: 'absolute', width: 28, height: 28,
        border: `3px solid ${t.accent}`, ...style,
      }}/>
    );
    return (
      <div style={{ position: 'absolute', inset: '24% 8% 28% 8%', pointerEvents: 'none' }}>
        <C style={{ top: -2, left: -2, borderRight: 'none', borderBottom: 'none', borderTopLeftRadius: 12 }}/>
        <C style={{ top: -2, right: -2, borderLeft: 'none', borderBottom: 'none', borderTopRightRadius: 12 }}/>
        <C style={{ bottom: -2, left: -2, borderRight: 'none', borderTop: 'none', borderBottomLeftRadius: 12 }}/>
        <C style={{ bottom: -2, right: -2, borderLeft: 'none', borderTop: 'none', borderBottomRightRadius: 12 }}/>
      </div>
    );
  };

  return (
    <div style={{
      width: '100%', height: '100%', position: 'relative', overflow: 'hidden',
      background: '#000', color: '#fff', fontFamily: fontUI,
      direction: isAr ? 'rtl' : 'ltr',
    }}>
      <PaperWithEquation />

      {/* Vignette */}
      <div style={{ position: 'absolute', inset: 0,
        background: 'radial-gradient(ellipse at center, transparent 40%, rgba(0,0,0,0.6) 100%)',
      }}/>

      {/* Top bar */}
      <div style={{
        position: 'absolute', top: 0, left: 0, right: 0, zIndex: 5,
        padding: platform === 'ios' ? '54px 16px 0' : '46px 16px 0',
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      }}>
        <button onClick={onClose} style={{
          width: 40, height: 40, borderRadius: 999, border: 'none', cursor: 'pointer',
          background: 'rgba(0,0,0,0.5)', backdropFilter: 'blur(20px)',
          color: '#fff', display: 'grid', placeItems: 'center',
        }}><Icon name="close" size={20} color="#fff"/></button>

        <div style={{
          padding: '8px 14px', borderRadius: 999,
          background: 'rgba(0,0,0,0.5)', backdropFilter: 'blur(20px)',
          fontSize: 12, fontWeight: 600, letterSpacing: 0.4,
          display: 'flex', alignItems: 'center', gap: 6,
        }}>
          <Icon name="sparkle" size={14} color={t.accent}/>
          <span>{L.title}</span>
        </div>

        <button style={{
          width: 40, height: 40, borderRadius: 999, border: 'none', cursor: 'pointer',
          background: 'rgba(0,0,0,0.5)', backdropFilter: 'blur(20px)',
          color: '#fff', display: 'grid', placeItems: 'center',
        }}><Icon name="flash" size={20} color="#fff"/></button>
      </div>

      {/* Stage content */}
      {stage === 'framing' && <>
        <Corners />
        {/* hint card */}
        <div style={{
          position: 'absolute', top: '12%', left: 20, right: 20, zIndex: 4,
          textAlign: 'center',
        }}>
          <div style={{
            display: 'inline-block', padding: '10px 16px', borderRadius: 14,
            background: 'rgba(0,0,0,0.5)', backdropFilter: 'blur(20px)',
            border: `1px solid rgba(255,255,255,0.1)`,
          }}>
            <div style={{ fontSize: 14, fontWeight: 600 }}>{L.hint}</div>
            <div style={{ fontSize: 11, color: 'rgba(255,255,255,0.6)', marginTop: 2 }}>{L.sub}</div>
          </div>
        </div>
      </>}

      {stage === 'analyzing' && <>
        <ScanOverlay />
        <div style={{
          position: 'absolute', top: '50%', left: 0, right: 0, transform: 'translateY(-50%)',
          textAlign: 'center', zIndex: 4,
        }}>
          <div style={{
            margin: '0 auto', width: 80, height: 80, borderRadius: 999,
            background: `radial-gradient(circle, ${t.accent}40 0%, transparent 70%)`,
            display: 'grid', placeItems: 'center', position: 'relative',
          }}>
            <div style={{
              position: 'absolute', inset: 0, borderRadius: 999,
              border: `2px solid ${t.accent}`, borderTopColor: 'transparent',
              animation: 'spin 1s linear infinite',
            }}/>
            <Icon name="sparkle" size={32} color={t.accent}/>
          </div>
          <div style={{ marginTop: 24, fontSize: 18, fontWeight: 600 }}>{L.analyzing}</div>
          <div style={{ fontSize: 12, color: 'rgba(255,255,255,0.6)', marginTop: 4 }}>{L.analyzeSub}</div>
          <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
        </div>
      </>}

      {stage === 'extracted' && (
        <div style={{
          position: 'absolute', left: 16, right: 16, bottom: platform==='ios'?40:32, zIndex: 6,
          background: 'rgba(15,32,26,0.92)', backdropFilter: 'blur(30px)',
          border: `1px solid ${t.borderStr}`, borderRadius: 24,
          padding: 20,
        }}>
          <div style={{ display:'flex', alignItems:'center', gap:8, marginBottom: 12 }}>
            <div style={{ width: 24, height: 24, borderRadius: 8, background: t.accentSoft,
              display:'grid', placeItems:'center'}}>
              <Icon name="check" size={14} color={t.accent}/>
            </div>
            <span style={{ fontSize: 13, fontWeight: 600, color: t.accent }}>{L.extracted}</span>
            <div style={{ flex: 1 }}/>
            <button style={{
              padding: '4px 10px', borderRadius: 999, border: `1px solid ${t.border}`,
              background: 'transparent', color: t.textDim, fontSize: 11, cursor: 'pointer',
              fontFamily: fontUI,
            }}>{L.edit}</button>
          </div>

          <div style={{
            background: 'rgba(0,0,0,0.3)', borderRadius: 14, padding: '20px 16px',
            fontFamily: NUMINA.font.math, fontSize: 22, color: '#fff',
            textAlign: 'center', direction: 'ltr',
          }}>
            <Tex>{`\\int (2x^{2} + 3x - 5)\\, dx`}</Tex>
          </div>

          <div style={{ display: 'flex', gap: 8, marginTop: 12 }}>
            <button onClick={() => onExtracted && onExtracted('quick')} style={{
              flex: 1, height: 50, borderRadius: 14, border: `1px solid ${t.border}`,
              background: t.surface2, color: t.text, fontSize: 13, fontWeight: 600,
              cursor: 'pointer', fontFamily: fontUI,
              display:'flex', alignItems:'center', justifyContent:'center', gap: 6,
            }}>
              <Icon name="bolt" size={16} color={t.accent}/>{L.quickSolve}
            </button>
            <button onClick={() => onExtracted && onExtracted('step')} style={{
              flex: 1, height: 50, borderRadius: 14, border: 'none', cursor: 'pointer',
              background: `linear-gradient(135deg, ${t.accent}, ${dark?'#1ec98a':'#0d8a5a'})`,
              color: dark ? '#03130c' : '#fff', fontSize: 13, fontWeight: 700,
              fontFamily: fontUI, display:'flex', alignItems:'center', justifyContent:'center', gap: 6,
              boxShadow: `0 8px 24px ${dark?'rgba(63,224,154,0.3)':'rgba(10,164,106,0.3)'}`,
            }}>
              <Icon name="book" size={16} color={dark ? '#03130c' : '#fff'}/>{L.stepSolve}
            </button>
          </div>
        </div>
      )}

      {/* Bottom controls (framing only) */}
      {stage === 'framing' && (
        <div style={{
          position: 'absolute', bottom: platform==='ios'?40:30, left: 0, right: 0, zIndex: 5,
          display: 'flex', alignItems: 'center', justifyContent: 'space-around',
          padding: '0 30px',
        }}>
          <button style={{
            width: 56, height: 56, borderRadius: 16, border: `1px solid rgba(255,255,255,0.2)`,
            background: 'rgba(255,255,255,0.08)', backdropFilter: 'blur(20px)',
            cursor: 'pointer', display: 'grid', placeItems: 'center', color: '#fff',
          }}>
            <Icon name="gallery" size={22} color="#fff"/>
          </button>

          <button onClick={capture} style={{
            width: 78, height: 78, borderRadius: 999, border: '4px solid rgba(255,255,255,0.4)',
            background: '#fff', cursor: 'pointer', position: 'relative',
            boxShadow: '0 0 0 2px rgba(255,255,255,0.2), 0 0 40px rgba(63,224,154,0.4)',
          }}>
            <div style={{
              position: 'absolute', inset: 6, borderRadius: 999, background: t.accent,
              display: 'grid', placeItems: 'center',
            }}>
              <Icon name="sparkle" size={26} color="#03130c"/>
            </div>
          </button>

          <button style={{
            width: 56, height: 56, borderRadius: 16, border: `1px solid rgba(255,255,255,0.2)`,
            background: 'rgba(255,255,255,0.08)', backdropFilter: 'blur(20px)',
            cursor: 'pointer', display: 'grid', placeItems: 'center', color: '#fff',
            fontSize: 11, fontWeight: 600, fontFamily: fontUI,
          }}>{L.paste}</button>
        </div>
      )}

      {/* Flash effect */}
      {flash && <div style={{ position:'absolute', inset:0, background:'#fff', zIndex: 10 }}/>}

      {/* Home indicator area is in the device frame; we only fill content here. */}
    </div>
  );
}

window.CameraScreen = CameraScreen;
