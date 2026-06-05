// screen-extras.jsx — Graph, History, Units, Settings screens

// ─────────────── GRAPH ────────────────────────────
function GraphScreen({ dark = true, lang = 'en', onClose, platform='ios' }) {
  const t = window.theme(dark);
  const isAr = lang === 'ar';
  const fontUI = isAr ? NUMINA.font.uiAr : NUMINA.font.ui;
  const L = isAr ? { title: 'الرسم البياني', add: 'دالة جديدة', xrange: 'مدى x', yrange: 'مدى y' }
                 : { title: 'Graph', add: 'Add function', xrange: 'x range', yrange: 'y range' };

  const fns = [
    { tex: 'f(x) = \\frac{2x^3}{3} + \\frac{3x^2}{2} - 5x', color: t.accent, raw: x => (2*x*x*x)/3 + (3*x*x)/2 - 5*x },
    { tex: 'g(x) = 2x^2 + 3x - 5', color: dark ? '#ff7a6b' : '#d14a3b', raw: x => 2*x*x + 3*x - 5 },
  ];

  const W = 360, H = 320;
  const xMin = -5, xMax = 5, yMin = -10, yMax = 10;
  const sx = x => ((x - xMin) / (xMax - xMin)) * W;
  const sy = y => H - ((y - yMin) / (yMax - yMin)) * H;
  const path = (fn) => {
    const pts = []; let started = false;
    for (let i = 0; i <= 200; i++) {
      const x = xMin + (i/200)*(xMax-xMin);
      const y = fn(x); if (!isFinite(y) || Math.abs(y) > 50) { started = false; continue; }
      pts.push((started?'L':'M') + sx(x).toFixed(1)+' '+sy(y).toFixed(1));
      started = true;
    }
    return pts.join(' ');
  };

  return (
    <div style={{ width:'100%', height:'100%', background: t.bg, color: t.text, fontFamily: fontUI,
      direction: isAr?'rtl':'ltr', position:'relative', overflow:'hidden', display:'flex', flexDirection:'column' }}>
      <Aurora dark={dark} intensity={0.4}/>
      <div style={{ position:'relative', zIndex: 2,
        padding: platform==='ios'?'54px 16px 8px':'46px 16px 8px',
        display:'flex', alignItems:'center', gap: 8 }}>
        <button onClick={onClose} style={{ width:36,height:36,borderRadius:10,border:`1px solid ${t.border}`,
          background: t.surface, color: t.textDim, display:'grid', placeItems:'center', cursor:'pointer'}}>
          <Icon name={isAr?'chevR':'chevL'} size={18} color={t.textDim}/></button>
        <div style={{ flex:1, fontSize:17, fontWeight:600 }}>{L.title}</div>
        <button style={{ width:36,height:36,borderRadius:10,border:`1px solid ${t.border}`,
          background: t.surface, color: t.textDim, display:'grid', placeItems:'center', cursor:'pointer'}}>
          <Icon name="share" size={18} color={t.textDim}/></button>
      </div>

      {/* Plot */}
      <div style={{ position:'relative', zIndex: 2, padding: '8px 16px' }}>
        <div style={{ position:'relative', borderRadius:18, overflow:'hidden',
          background: dark ? '#08130e' : '#fff',
          border: `1px solid ${t.border}`, padding: 8 }}>
          <svg width="100%" viewBox={`0 0 ${W} ${H}`} style={{ display:'block', borderRadius: 10 }}>
            {/* grid */}
            {Array.from({length: 11}).map((_,i)=>(
              <line key={'v'+i} x1={i*W/10} y1={0} x2={i*W/10} y2={H} stroke={t.border} strokeWidth="0.5"/>
            ))}
            {Array.from({length: 11}).map((_,i)=>(
              <line key={'h'+i} x1={0} y1={i*H/10} x2={W} y2={i*H/10} stroke={t.border} strokeWidth="0.5"/>
            ))}
            {/* axes */}
            <line x1={sx(0)} y1={0} x2={sx(0)} y2={H} stroke={t.textDim} strokeWidth="1"/>
            <line x1={0} y1={sy(0)} x2={W} y2={sy(0)} stroke={t.textDim} strokeWidth="1"/>
            {/* curves */}
            {fns.map((f, i) => (
              <path key={i} d={path(f.raw)} fill="none" stroke={f.color} strokeWidth="2.5"
                strokeLinecap="round" strokeLinejoin="round"
                style={{ filter: dark ? `drop-shadow(0 0 6px ${f.color})` : 'none' }}/>
            ))}
            {/* roots / intercepts dots */}
            <circle cx={sx(0)} cy={sy(0)} r="3" fill={t.accent} stroke={t.bg} strokeWidth="1.5"/>
          </svg>
        </div>
      </div>

      {/* Function list */}
      <div style={{ position:'relative', zIndex:2, padding: '8px 16px', flex: 1, overflow:'auto' }}>
        {fns.map((f, i) => (
          <div key={i} style={{
            background: t.surface, border:`1px solid ${t.border}`, borderRadius:14,
            padding: 12, marginBottom: 8, display:'flex', alignItems:'center', gap: 10,
          }}>
            <div style={{ width: 8, height: 28, borderRadius: 4, background: f.color, boxShadow: dark?`0 0 12px ${f.color}`:'none' }}/>
            <div style={{ flex: 1, fontFamily: NUMINA.font.math, fontSize: 16, direction:'ltr' }}>
              <Tex>{f.tex}</Tex>
            </div>
            <Icon name="settings" size={16} color={t.textMute}/>
          </div>
        ))}
        <button style={{
          width: '100%', padding: 14, borderRadius: 14, border: `1.5px dashed ${t.border}`,
          background: 'transparent', color: t.textDim, fontFamily: fontUI, fontSize: 13,
          fontWeight: 600, cursor:'pointer', display:'flex', alignItems:'center', justifyContent:'center', gap: 6,
        }}><Icon name="plus" size={16} color={t.textDim}/>{L.add}</button>
      </div>
    </div>
  );
}

// ─────────────── HISTORY ────────────────────────────
function HistoryScreen({ dark = true, lang = 'en', onClose, platform='ios' }) {
  const t = window.theme(dark);
  const isAr = lang === 'ar';
  const fontUI = isAr ? NUMINA.font.uiAr : NUMINA.font.ui;
  const L = isAr ? { title:'السجل', search:'ابحث في السجل…', today:'اليوم', yesterday:'الأمس', clear:'مسح الكل' }
                 : { title:'History', search:'Search history…', today:'Today', yesterday:'Yesterday', clear:'Clear all' };

  const groups = [
    { label: L.today, items: [
      { tex: '\\int (2x^{2} + 3x - 5)\\, dx', res: '\\frac{2x^{3}}{3} + \\frac{3x^{2}}{2} - 5x + C', tag: 'AI', pinned: true },
      { tex: '\\sin(45) + \\cos(30)^{2}', res: '1.457', tag: 'sci' },
      { tex: 'x^{2} - 5x + 6 = 0', res: 'x = 2,\\ x = 3', tag: 'AI' },
    ]},
    { label: L.yesterday, items: [
      { tex: '\\sqrt{144} + \\log(100)', res: '14', tag: 'sci' },
      { tex: '5! \\cdot 3!', res: '720', tag: 'sci' },
      { tex: '\\frac{d}{dx}(\\sin(x^{2}))', res: '2x\\cos(x^{2})', tag: 'AI' },
    ]},
  ];

  return (
    <div style={{ width:'100%', height:'100%', background: t.bg, color: t.text, fontFamily: fontUI,
      direction: isAr?'rtl':'ltr', position:'relative', overflow:'hidden', display:'flex', flexDirection:'column' }}>
      <Aurora dark={dark} intensity={0.4}/>
      <div style={{ position:'relative', zIndex:2,
        padding: platform==='ios'?'54px 16px 8px':'46px 16px 8px',
        display:'flex', alignItems:'center', gap:8 }}>
        <button onClick={onClose} style={{ width:36,height:36,borderRadius:10,border:`1px solid ${t.border}`,
          background: t.surface, color: t.textDim, display:'grid', placeItems:'center', cursor:'pointer'}}>
          <Icon name={isAr?'chevR':'chevL'} size={18} color={t.textDim}/></button>
        <div style={{ flex:1, fontSize:17, fontWeight:600 }}>{L.title}</div>
        <button style={{ padding:'6px 10px', fontSize:12, fontWeight:600, color: t.danger,
          background:'transparent', border:`1px solid ${t.border}`, borderRadius: 10, cursor:'pointer', fontFamily: fontUI,
        }}>{L.clear}</button>
      </div>

      {/* Search */}
      <div style={{ position:'relative', zIndex:2, padding:'4px 16px 8px' }}>
        <div style={{
          background: t.surface, border:`1px solid ${t.border}`, borderRadius:12,
          padding:'10px 12px', display:'flex', alignItems:'center', gap:8,
        }}>
          <Icon name="search" size={16} color={t.textMute}/>
          <span style={{ color: t.textMute, fontSize: 14 }}>{L.search}</span>
        </div>
      </div>

      <div style={{ position:'relative', zIndex:2, flex:1, overflow:'auto', padding:'4px 16px 16px' }}>
        {groups.map((g, gi) => (
          <div key={gi}>
            <div style={{ fontSize:11, fontWeight:700, letterSpacing:0.6, color:t.textMute,
              padding:'12px 4px 8px' }}>{g.label.toUpperCase()}</div>
            {g.items.map((it, i) => (
              <div key={i} style={{
                background: t.surface, border:`1px solid ${t.border}`, borderRadius:14,
                padding: '12px 14px', marginBottom: 6, display:'flex', alignItems:'center', gap:12,
              }}>
                <div style={{
                  width: 36, height: 36, borderRadius: 10,
                  background: it.tag==='AI' ? t.accentSoft : t.surface2,
                  color: it.tag==='AI' ? t.accent : t.textDim,
                  display:'grid', placeItems:'center', flexShrink:0,
                }}>
                  <Icon name={it.tag==='AI' ? 'sparkle' : 'fx'} size={16} color={it.tag==='AI' ? t.accent : t.textDim}/>
                </div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontFamily: NUMINA.font.math, fontSize: 14, direction:'ltr',
                    color: t.text, overflow:'hidden', textOverflow:'ellipsis', whiteSpace:'nowrap' }}>
                    <Tex>{it.tex}</Tex>
                  </div>
                  <div style={{ fontFamily: NUMINA.font.math, fontSize: 13, color: t.accent,
                    direction:'ltr', marginTop: 2, overflow:'hidden', textOverflow:'ellipsis', whiteSpace:'nowrap' }}>
                    = <Tex>{it.res}</Tex>
                  </div>
                </div>
                {it.pinned && <Icon name="pin" size={14} color={t.accent}/>}
              </div>
            ))}
          </div>
        ))}
      </div>
    </div>
  );
}

// ─────────────── UNITS ────────────────────────────
function UnitsScreen({ dark = true, lang = 'en', onClose, platform='ios' }) {
  const t = window.theme(dark);
  const isAr = lang === 'ar';
  const fontUI = isAr ? NUMINA.font.uiAr : NUMINA.font.ui;
  const L = isAr ? { title:'محول الوحدات', cat:'الفئة', from:'من', to:'إلى',
    length:'الطول', mass:'الكتلة', temp:'الحرارة', time:'الوقت', currency:'العملات', area:'المساحة' }
                 : { title:'Unit converter', cat:'Category', from:'From', to:'To',
    length:'Length', mass:'Mass', temp:'Temperature', time:'Time', currency:'Currency', area:'Area' };

  const cats = [
    { k:'length', i:'units' }, { k:'mass', i:'shapes' },
    { k:'temp', i:'sun' }, { k:'time', i:'history' },
    { k:'currency', i:'globe' }, { k:'area', i:'crop' },
  ];

  return (
    <div style={{ width:'100%', height:'100%', background: t.bg, color: t.text, fontFamily: fontUI,
      direction: isAr?'rtl':'ltr', position:'relative', overflow:'hidden', display:'flex', flexDirection:'column' }}>
      <Aurora dark={dark} intensity={0.4}/>
      <div style={{ position:'relative', zIndex:2,
        padding: platform==='ios'?'54px 16px 8px':'46px 16px 8px',
        display:'flex', alignItems:'center', gap:8 }}>
        <button onClick={onClose} style={{ width:36,height:36,borderRadius:10,border:`1px solid ${t.border}`,
          background: t.surface, color: t.textDim, display:'grid', placeItems:'center', cursor:'pointer'}}>
          <Icon name={isAr?'chevR':'chevL'} size={18} color={t.textDim}/></button>
        <div style={{ flex:1, fontSize:17, fontWeight:600 }}>{L.title}</div>
        <div style={{ width: 36 }}/>
      </div>

      {/* From / To Cards */}
      <div style={{ position:'relative', zIndex:2, padding:'8px 16px 4px' }}>
        <div style={{
          background: t.surface, border:`1px solid ${t.border}`, borderRadius: 18,
          padding: 16, marginBottom: 10,
        }}>
          <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: 0.5, color: t.textMute, marginBottom: 6 }}>
            {L.from.toUpperCase()}
          </div>
          <div style={{ display:'flex', alignItems:'baseline', gap: 8 }}>
            <div style={{ fontFamily: NUMINA.font.mono, fontSize: 32, fontWeight: 600, color: t.text, direction:'ltr' }}>
              1,000
            </div>
            <div style={{ flex: 1 }}/>
            <div style={{ padding:'6px 12px', borderRadius: 999, background: t.accentSoft, color: t.accent,
              fontSize: 13, fontWeight: 600, display:'flex', alignItems:'center', gap: 4,
            }}>{isAr?'متر':'meter'}<Icon name="chevD" size={12} color={t.accent}/></div>
          </div>
        </div>

        {/* Swap */}
        <div style={{ display:'flex', justifyContent:'center', margin:'-22px 0', position:'relative', zIndex: 3 }}>
          <button style={{
            width: 40, height: 40, borderRadius: 999,
            background: t.bg, border: `1px solid ${t.border}`, cursor:'pointer',
            display:'grid', placeItems:'center', boxShadow: dark?'0 4px 12px rgba(0,0,0,0.4)':'0 4px 12px rgba(0,0,0,0.06)',
          }}><Icon name="rotate" size={18} color={t.accent}/></button>
        </div>

        <div style={{
          background: `linear-gradient(135deg, ${dark?'rgba(63,224,154,0.10)':'rgba(10,164,106,0.06)'}, ${t.surface})`,
          border:`1px solid ${dark?'rgba(63,224,154,0.25)':'rgba(10,164,106,0.20)'}`,
          borderRadius: 18, padding: 16, marginTop: 10,
        }}>
          <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: 0.5, color: t.accent, marginBottom: 6 }}>
            {L.to.toUpperCase()}
          </div>
          <div style={{ display:'flex', alignItems:'baseline', gap: 8 }}>
            <div style={{ fontFamily: NUMINA.font.mono, fontSize: 32, fontWeight: 600, color: t.text, direction:'ltr' }}>
              0.6214
            </div>
            <div style={{ flex: 1 }}/>
            <div style={{ padding:'6px 12px', borderRadius: 999, background: t.bgRaised, color: t.text,
              fontSize: 13, fontWeight: 600, display:'flex', alignItems:'center', gap: 4, border: `1px solid ${t.border}`,
            }}>{isAr?'ميل':'mile'}<Icon name="chevD" size={12} color={t.textDim}/></div>
          </div>
        </div>
      </div>

      {/* Categories */}
      <div style={{ position:'relative', zIndex:2, padding:'16px 16px', flex:1, overflow:'auto' }}>
        <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: 0.6, color: t.textMute, padding:'4px 4px 10px' }}>
          {L.cat.toUpperCase()}
        </div>
        <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr 1fr', gap: 8 }}>
          {cats.map((c, i) => (
            <div key={i} style={{
              background: i === 0 ? t.accentSoft : t.surface,
              border: `1px solid ${i===0 ? 'transparent' : t.border}`,
              borderRadius: 14, padding: '14px 8px',
              display:'flex', flexDirection:'column', alignItems:'center', gap: 6, cursor:'pointer',
            }}>
              <Icon name={c.i} size={20} color={i===0 ? t.accent : t.textDim}/>
              <div style={{ fontSize: 12, fontWeight: 600, color: i===0 ? t.accent : t.text }}>{L[c.k]}</div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

// ─────────────── SETTINGS ────────────────────────────
function SettingsScreen({ dark = true, lang = 'en', onClose, onToggleDark, onToggleLang, platform='ios' }) {
  const t = window.theme(dark);
  const isAr = lang === 'ar';
  const fontUI = isAr ? NUMINA.font.uiAr : NUMINA.font.ui;
  const L = isAr ? { title:'الإعدادات', appearance:'المظهر', dark:'الوضع الداكن', lang:'اللغة',
    angle:'وحدة الزاوية', precision:'الدقة', haptics:'اللمس الاهتزازي',
    ai:'الذكاء الاصطناعي', model:'النموذج', stream:'بث الإجابة',
    privacy:'الخصوصية', store:'حفظ الصور', sync:'مزامنة سحابية',
    about:'حول', version:'الإصدار', tos:'الشروط' }
                 : { title:'Settings', appearance:'Appearance', dark:'Dark mode', lang:'Language',
    angle:'Angle unit', precision:'Precision', haptics:'Haptic feedback',
    ai:'AI', model:'Model', stream:'Stream answers',
    privacy:'Privacy', store:'Save photos', sync:'Cloud sync',
    about:'About', version:'Version', tos:'Terms' };

  const Toggle = ({ on, onChange }) => (
    <div onClick={onChange} style={{
      width: 44, height: 26, borderRadius: 999, padding: 2, cursor:'pointer',
      background: on ? t.accent : (dark?'#2a3a32':'#d6dcd6'), transition: 'background .2s',
    }}>
      <div style={{
        width: 22, height: 22, borderRadius: 999, background: '#fff',
        transform: `translateX(${on ? (isAr ? -18 : 18) : 0}px)`, transition: 'transform .2s',
        boxShadow: '0 2px 4px rgba(0,0,0,0.2)',
      }}/>
    </div>
  );

  const Row = ({ icon, title, sub, right, last }) => (
    <div style={{
      display:'flex', alignItems:'center', gap: 12, padding: '12px 14px',
      borderBottom: last ? 'none' : `1px solid ${t.border}`,
    }}>
      <div style={{ width: 32, height: 32, borderRadius: 9, background: t.surface2,
        display:'grid', placeItems:'center' }}>
        <Icon name={icon} size={16} color={t.textDim}/>
      </div>
      <div style={{ flex: 1 }}>
        <div style={{ fontSize: 14, fontWeight: 500 }}>{title}</div>
        {sub && <div style={{ fontSize: 12, color: t.textMute, marginTop: 1 }}>{sub}</div>}
      </div>
      {right}
    </div>
  );

  const Section = ({ title, children }) => (
    <div style={{ marginBottom: 18 }}>
      <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: 0.6, color: t.textMute, padding: '0 4px 8px' }}>
        {title.toUpperCase()}
      </div>
      <div style={{ background: t.surface, border: `1px solid ${t.border}`, borderRadius: 16, overflow:'hidden' }}>
        {children}
      </div>
    </div>
  );

  return (
    <div style={{ width:'100%', height:'100%', background: t.bg, color: t.text, fontFamily: fontUI,
      direction: isAr?'rtl':'ltr', position:'relative', overflow:'hidden', display:'flex', flexDirection:'column' }}>
      <Aurora dark={dark} intensity={0.4}/>
      <div style={{ position:'relative', zIndex:2,
        padding: platform==='ios'?'54px 16px 8px':'46px 16px 8px',
        display:'flex', alignItems:'center', gap:8 }}>
        <button onClick={onClose} style={{ width:36,height:36,borderRadius:10,border:`1px solid ${t.border}`,
          background: t.surface, color: t.textDim, display:'grid', placeItems:'center', cursor:'pointer'}}>
          <Icon name={isAr?'chevR':'chevL'} size={18} color={t.textDim}/></button>
        <div style={{ flex:1, fontSize:17, fontWeight:600 }}>{L.title}</div>
        <div style={{ width: 36 }}/>
      </div>

      {/* Profile-ish header */}
      <div style={{ position:'relative', zIndex:2, padding: '8px 16px 16px' }}>
        <div style={{
          background: `linear-gradient(135deg, ${t.accent} 0%, ${dark?'#1ec98a':'#0d8a5a'} 100%)`,
          borderRadius: 20, padding: 18, color: dark?'#03130c':'#fff',
          display:'flex', alignItems:'center', gap: 14,
          boxShadow: `0 14px 40px ${dark?'rgba(63,224,154,0.25)':'rgba(10,164,106,0.25)'}`,
        }}>
          <div style={{ width: 50, height: 50, borderRadius: 14, background: 'rgba(0,0,0,0.18)',
            display:'grid', placeItems:'center' }}>
            <Icon name="sparkle" size={24} color={dark?'#03130c':'#fff'}/>
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 16, fontWeight: 700 }}>NUMINA Pro</div>
            <div style={{ fontSize: 12, opacity: 0.8 }}>{isAr?'حلول AI غير محدودة':'Unlimited AI solves'}</div>
          </div>
          <Icon name={isAr?'chevL':'chevR'} size={18} color={dark?'#03130c':'#fff'}/>
        </div>
      </div>

      <div style={{ position:'relative', zIndex:2, flex:1, overflow:'auto', padding:'0 16px 16px' }}>
        <Section title={L.appearance}>
          <Row icon="moon" title={L.dark} right={<Toggle on={dark} onChange={onToggleDark}/>}/>
          <Row icon="lang" title={L.lang} sub={isAr?'العربية':'English'} right={
            <button onClick={onToggleLang} style={{ padding:'4px 10px', borderRadius:8, fontSize:12,
              background: t.accentSoft, color: t.accent, border:'none', cursor:'pointer', fontWeight:600,
            }}>{isAr?'EN':'AR'}</button>
          } last/>
        </Section>
        <Section title={L.ai}>
          <Row icon="sparkle" title={L.model} sub="GPT-4o Vision"
            right={<Icon name={isAr?'chevL':'chevR'} size={14} color={t.textMute}/>}/>
          <Row icon="bolt" title={L.stream} right={<Toggle on={true}/>} last/>
        </Section>
        <Section title={L.privacy}>
          <Row icon="gallery" title={L.store} right={<Toggle on={false}/>}/>
          <Row icon="globe" title={L.sync} right={<Toggle on={true}/>} last/>
        </Section>
        <Section title={L.about}>
          <Row icon="settings" title={L.version} sub="2.0.1"
            right={<Icon name={isAr?'chevL':'chevR'} size={14} color={t.textMute}/>}/>
          <Row icon="book" title={L.tos}
            right={<Icon name={isAr?'chevL':'chevR'} size={14} color={t.textMute}/>} last/>
        </Section>
      </div>
    </div>
  );
}

window.GraphScreen = GraphScreen;
window.HistoryScreen = HistoryScreen;
window.UnitsScreen = UnitsScreen;
window.SettingsScreen = SettingsScreen;
