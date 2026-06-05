// screen-calculator.jsx — Main scientific calculator screen
// Working calculator with second-function shift, deg/rad, history strip.

function CalculatorScreen({ dark = true, lang = 'en', onOpenAI, onOpenHistory, onOpenGraph, onOpenUnits, onOpenSettings, platform = 'ios' }) {
  const t = window.theme(dark);
  const isAr = lang === 'ar';
  const fontUI = isAr ? NUMINA.font.uiAr : NUMINA.font.ui;

  const [expr, setExpr] = React.useState('sin(45) + cos(30)^2');
  const [result, setResult] = React.useState(null);
  const [angle, setAngle] = React.useState('deg');
  const [shift, setShift] = React.useState(false);
  const [history, setHistory] = React.useState([
    { expr: '∫(2x + 3) dx', res: 'x² + 3x + C' },
    { expr: '√(144) + log(100)', res: '14' },
    { expr: '5! / 3!', res: '20' },
  ]);

  // live evaluate
  React.useEffect(() => {
    if (!expr.trim()) { setResult(null); return; }
    const r = window.calcEval(expr, angle);
    if (r.value !== undefined) setResult(window.calcFmt(r.value));
    else setResult(null);
  }, [expr, angle]);

  const append = (s) => setExpr(e => e + s);
  const clear = () => setExpr('');
  const back = () => setExpr(e => e.slice(0, -1));
  const equals = () => {
    const r = window.calcEval(expr, angle);
    if (r.value !== undefined) {
      const v = window.calcFmt(r.value);
      setHistory(h => [{ expr, res: v }, ...h].slice(0, 12));
      setExpr(v);
    }
  };

  // labels
  const L = isAr ? {
    ai: 'حلّ بالـ AI', deg: 'درجة', rad: 'راديان', hist: 'السجل',
    title: 'الحاسبة', placeholder: 'اكتب أو التقط معادلة',
    second: 'بديل', graph: 'رسم بياني', units: 'وحدات', settings: 'إعدادات',
  } : {
    ai: 'Solve with AI', deg: 'DEG', rad: 'RAD', hist: 'History',
    title: 'Calculator', placeholder: 'Type or capture equation',
    second: '2ND', graph: 'Graph', units: 'Units', settings: 'Settings',
  };

  // Button definitions — sci pad on top, num pad below
  const sci = shift ? [
    ['2ⁿᵈ','sinh(','cosh(','tanh(','π'],
    ['xʸ','asin(','acos(','atan(','e'],
    ['ⁿ√','log(','ln(','eˣ','('],
    ['x²','%','!','1/x',')'],
  ] : [
    ['2ⁿᵈ','sin(','cos(','tan(','π'],
    ['xʸ','x²','x³','√(','e'],
    ['log(','ln(','eˣ','10ˣ','('],
    ['(','%','!','|x|',')'],
  ];

  const numPad = [
    ['7','8','9','÷'],
    ['4','5','6','×'],
    ['1','2','3','−'],
    ['0','.','⌫','+'],
  ];

  const tokenMap = {
    '×':'*','÷':'/','−':'-','x²':'^2','x³':'^3','xʸ':'^','√(':'sqrt(','ⁿ√':'root(',
    '|x|':'abs(','1/x':'^-1','eˣ':'exp(','10ˣ':'10^','π':'π','e':'e','⌫':'BACK',
  };

  const handle = (k) => {
    if (k === '2ⁿᵈ') { setShift(s=>!s); return; }
    if (k === '⌫') { back(); return; }
    if (k === '=') { equals(); return; }
    const tok = tokenMap[k] !== undefined ? tokenMap[k] : k;
    if (tok === 'BACK') back(); else append(tok);
  };

  const Btn = ({ label, kind='default', onPress, big=false, wide=false }) => {
    const styles = {
      default: { bg: t.keyBg, fg: t.keyText, border: t.border },
      alt:     { bg: t.keyBgAlt, fg: t.keyText, border: t.border },
      op:      { bg: dark ? 'rgba(63,224,154,0.12)' : 'rgba(10,164,106,0.10)', fg: t.accent, border: 'transparent' },
      eq:      { bg: t.accent, fg: dark ? '#03130c' : '#fff', border: 'transparent' },
      mute:    { bg: 'transparent', fg: t.textDim, border: t.border },
    };
    const sty = styles[kind];
    const isMath = /^[a-z\(\)\^√π!eE0-9·×÷−+\.\|⌫=]+$/i.test(label) || label.length <= 3;
    return (
      <button onClick={onPress} style={{
        flex: wide ? 2 : 1, height: big ? 56 : 52, minHeight: 48,
        borderRadius: 16,
        background: sty.bg, color: sty.fg,
        border: `0.5px solid ${sty.border}`,
        fontSize: label.length > 3 ? 13 : 22,
        fontWeight: kind === 'eq' ? 600 : 500,
        fontFamily: NUMINA.font.mono, letterSpacing: -0.5,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        cursor: 'pointer',
        boxShadow: kind === 'eq' ? `0 6px 20px ${dark? 'rgba(63,224,154,0.3)' : 'rgba(10,164,106,0.3)'}` : 'none',
        transition: 'transform .1s, background .15s',
      }}>{label}</button>
    );
  };

  return (
    <div style={{
      width: '100%', height: '100%', position: 'relative',
      background: t.bg, color: t.text, fontFamily: fontUI,
      direction: isAr ? 'rtl' : 'ltr', overflow: 'hidden',
      display: 'flex', flexDirection: 'column',
    }}>
      <Aurora dark={dark} />

      {/* Top bar */}
      <div style={{
        position: 'relative', zIndex: 2,
        padding: platform === 'ios' ? '54px 20px 8px' : '46px 20px 8px',
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      }}>
        <button style={{
          width: 36, height: 36, borderRadius: 10, border: `1px solid ${t.border}`,
          background: t.surface, color: t.textDim, display:'grid', placeItems:'center', cursor:'pointer',
        }}><Icon name="menu" size={18} color={t.textDim} /></button>

        <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
          <div style={{
            width: 8, height: 8, borderRadius: 999, background: t.accent,
            boxShadow: `0 0 12px ${t.accent}`,
          }}/>
          <span style={{ fontSize: 13, fontWeight: 600, letterSpacing: 0.4, color: t.textDim }}>NUMINA</span>
        </div>

        <button onClick={onOpenSettings} style={{
          width: 36, height: 36, borderRadius: 10, border: `1px solid ${t.border}`,
          background: t.surface, color: t.textDim, display:'grid', placeItems:'center', cursor:'pointer',
        }}><Icon name="settings" size={18} color={t.textDim} /></button>
      </div>

      {/* Mode chips */}
      <div style={{
        position: 'relative', zIndex: 2,
        padding: '4px 20px 12px', display:'flex', gap: 8, alignItems: 'center', flexWrap: 'wrap',
      }}>
        <div style={{
          display: 'flex', background: t.surface, borderRadius: 999,
          padding: 3, border: `1px solid ${t.border}`,
        }}>
          {['deg','rad'].map(m => (
            <button key={m} onClick={() => setAngle(m)} style={{
              padding: '6px 14px', borderRadius: 999, border: 'none', cursor: 'pointer',
              fontSize: 11, fontWeight: 700, letterSpacing: 0.6, fontFamily: NUMINA.font.ui,
              background: angle === m ? t.accent : 'transparent',
              color: angle === m ? (dark ? '#03130c' : '#fff') : t.textDim,
            }}>{m === 'deg' ? L.deg : L.rad}</button>
          ))}
        </div>
        <div style={{
          padding: '6px 12px', borderRadius: 999, fontSize: 11,
          fontWeight: 600, letterSpacing: 0.4,
          background: shift ? t.accent : t.surface,
          color: shift ? (dark ? '#03130c' : '#fff') : t.textDim,
          border: `1px solid ${shift ? 'transparent' : t.border}`,
        }}>{L.second}</div>
        <div style={{ flex: 1 }}/>
        <button onClick={onOpenHistory} style={{
          padding: '6px 12px', borderRadius: 999, fontSize: 12, fontWeight: 500,
          background: t.surface, color: t.textDim, border: `1px solid ${t.border}`, cursor: 'pointer',
          display: 'flex', alignItems: 'center', gap: 6,
        }}><Icon name="history" size={14} color={t.textDim}/>{L.hist}</button>
      </div>

      {/* History strip */}
      <div style={{
        position: 'relative', zIndex: 2, padding: '0 20px 8px',
        display: 'flex', flexDirection: 'column', gap: 4, opacity: 0.55,
      }}>
        {history.slice(0, 2).map((h, i) => (
          <div key={i} style={{ fontSize: 13, color: t.textMute, fontFamily: NUMINA.font.mono,
            display: 'flex', justifyContent: 'space-between', gap: 12, direction:'ltr',
            textAlign: isAr ? 'right' : 'left',
          }}>
            <span style={{ overflow:'hidden', textOverflow:'ellipsis', whiteSpace:'nowrap' }}>{h.expr}</span>
            <span style={{ color: t.textDim }}>= {h.res}</span>
          </div>
        ))}
      </div>

      {/* Display */}
      <div style={{
        position: 'relative', zIndex: 2,
        padding: '8px 20px 12px', flex: 1,
        display: 'flex', flexDirection: 'column', justifyContent: 'flex-end',
        minHeight: 100,
      }}>
        <div style={{
          fontFamily: NUMINA.font.mono, fontSize: 30, fontWeight: 400, color: t.text,
          letterSpacing: -0.5, lineHeight: 1.2, direction:'ltr', textAlign: isAr ? 'right' : 'left',
          wordBreak: 'break-all', minHeight: 36,
        }}>{expr}<span style={{
          display: 'inline-block', width: 2, height: 28, background: t.accent,
          marginLeft: 2, verticalAlign: 'middle', animation: 'blink 1s steps(1) infinite',
        }}/></div>
        <div style={{
          fontFamily: NUMINA.font.mono, fontSize: 44, fontWeight: 600, color: t.accent,
          letterSpacing: -1, lineHeight: 1, marginTop: 8, direction:'ltr',
          textAlign: isAr ? 'right' : 'left',
          textShadow: dark ? `0 0 30px ${t.accent}30` : 'none',
        }}>{result !== null ? `= ${result}` : '\u00A0'}</div>
      </div>

      {/* AI button */}
      <div style={{ position: 'relative', zIndex: 2, padding: '4px 20px 8px' }}>
        <button onClick={onOpenAI} style={{
          width: '100%', height: 56, borderRadius: 18,
          border: 'none', cursor: 'pointer',
          background: `linear-gradient(135deg, ${t.accent} 0%, ${dark? '#1ec98a':'#0d8a5a'} 100%)`,
          color: dark ? '#03130c' : '#fff',
          fontSize: 16, fontWeight: 600, fontFamily: fontUI,
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10,
          boxShadow: `0 10px 30px ${dark? 'rgba(63,224,154,0.35)':'rgba(10,164,106,0.3)'}, inset 0 1px 0 rgba(255,255,255,0.2)`,
          position: 'relative', overflow: 'hidden',
        }}>
          <Icon name="sparkle" size={20} color={dark ? '#03130c' : '#fff'}/>
          <span>{L.ai}</span>
          <div style={{
            position: 'absolute', inset: 0, pointerEvents: 'none',
            background: 'linear-gradient(110deg, transparent 30%, rgba(255,255,255,0.25) 50%, transparent 70%)',
            backgroundSize: '200% 100%', animation: 'shimmer 3.5s linear infinite',
          }}/>
        </button>
      </div>

      {/* Sci pad */}
      <div style={{ position: 'relative', zIndex: 2, padding: '4px 16px 6px',
        display: 'flex', flexDirection: 'column', gap: 6,
      }}>
        {sci.map((row, i) => (
          <div key={i} style={{ display: 'flex', gap: 6 }}>
            {row.map((k, j) => (
              <Btn key={j} label={k} kind={k === '2ⁿᵈ' ? (shift?'eq':'mute') : 'alt'} onPress={() => handle(k)} />
            ))}
          </div>
        ))}
      </div>

      {/* Number pad */}
      <div style={{ position: 'relative', zIndex: 2, padding: '6px 16px 12px',
        display: 'flex', flexDirection: 'column', gap: 6,
      }}>
        {numPad.map((row, i) => (
          <div key={i} style={{ display: 'flex', gap: 6 }}>
            {row.map((k, j) => {
              const isOp = ['+','−','×','÷'].includes(k);
              return <Btn key={j} label={k} kind={isOp ? 'op' : k==='⌫' ? 'mute' : 'default'} onPress={() => handle(k)} />;
            })}
          </div>
        ))}
        <div style={{ display: 'flex', gap: 6 }}>
          <Btn label="C" kind="mute" onPress={clear} />
          <Btn label="ANS" kind="alt" onPress={()=>append('Ans')} />
          <Btn label="(" kind="alt" onPress={()=>append('(')} />
          <Btn label=")" kind="alt" onPress={()=>append(')')} />
          <Btn label="=" kind="eq" onPress={equals} wide />
        </div>
      </div>

      {/* Floating bottom nav */}
      <div style={{
        position: 'relative', zIndex: 3,
        margin: '0 20px 16px', padding: 6,
        background: dark ? 'rgba(15,32,26,0.7)' : 'rgba(255,255,255,0.7)',
        backdropFilter: 'blur(20px)', WebkitBackdropFilter: 'blur(20px)',
        border: `1px solid ${t.border}`,
        borderRadius: 999,
        display: 'flex', justifyContent: 'space-around', alignItems: 'center',
        boxShadow: dark ? '0 10px 30px rgba(0,0,0,0.4)' : '0 10px 30px rgba(0,0,0,0.08)',
      }}>
        {[
          { i: 'home', a: ()=>{}, on: true, label: isAr?'حاسبة':'Calc' },
          { i: 'camera', a: onOpenAI, label: isAr?'كاميرا':'Camera' },
          { i: 'chart', a: onOpenGraph, label: isAr?'رسم':'Graph' },
          { i: 'units', a: onOpenUnits, label: isAr?'وحدات':'Units' },
          { i: 'history', a: onOpenHistory, label: isAr?'السجل':'History' },
        ].map((it, idx) => (
          <button key={idx} onClick={it.a} style={{
            flex: 1, padding: '8px 6px', borderRadius: 999, border: 'none', cursor: 'pointer',
            background: it.on ? t.accent : 'transparent',
            color: it.on ? (dark ? '#03130c' : '#fff') : t.textDim,
            display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6,
            fontSize: 11, fontWeight: 600, fontFamily: fontUI,
          }}>
            <Icon name={it.i} size={18} color={it.on ? (dark ? '#03130c' : '#fff') : t.textDim} />
            {it.on && <span>{it.label}</span>}
          </button>
        ))}
      </div>

      <style>{`
        @keyframes blink { 50% { opacity: 0; } }
        @keyframes shimmer { 0% { background-position: 200% 0; } 100% { background-position: -200% 0; } }
      `}</style>
    </div>
  );
}

window.CalculatorScreen = CalculatorScreen;
