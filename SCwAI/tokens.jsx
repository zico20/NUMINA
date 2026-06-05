// tokens.jsx — Numina design tokens
// Theme palette + typography helpers. Exposes window.NUMINA.

const NUMINA = {
  // Brand greens
  brand: {
    50:  '#e9fbf3',
    100: '#c8f3df',
    200: '#8fe6bf',
    300: '#4fd49a',
    400: '#1fbf7d',
    500: '#0aa46a',  // primary
    600: '#068557',
    700: '#066647',
    800: '#054e38',
    900: '#053a2b',
    950: '#02201a',
  },

  // Theme objects
  light: {
    bg:        '#f4f6f3',
    bgRaised:  '#ffffff',
    surface:   '#ffffff',
    surface2:  '#eef1ec',
    border:    'rgba(20,30,25,0.08)',
    borderStr: 'rgba(20,30,25,0.14)',
    text:      '#0d1612',
    textDim:   '#475651',
    textMute:  '#7d8a85',
    accent:    '#0aa46a',
    accentSoft:'#e9fbf3',
    danger:    '#d14a3b',
    warn:      '#c98a1e',
    op:        '#0aa46a',
    keyBg:     '#ffffff',
    keyBgAlt:  '#e8ece6',
    keyText:   '#0d1612',
    glass:     'rgba(255,255,255,0.7)',
    aurora1:   'rgba(10,164,106,0.12)',
    aurora2:   'rgba(50,200,170,0.10)',
  },
  dark: {
    bg:        '#06100c',
    bgRaised:  '#0c1a14',
    surface:   '#0f201a',
    surface2:  '#15291f',
    border:    'rgba(120,200,170,0.10)',
    borderStr: 'rgba(120,200,170,0.20)',
    text:      '#eaf6f0',
    textDim:   '#9ab5aa',
    textMute:  '#5e7a72',
    accent:    '#3fe09a',
    accentSoft:'rgba(63,224,154,0.14)',
    danger:    '#ff7a6b',
    warn:      '#ffc14f',
    op:        '#3fe09a',
    keyBg:     '#15291f',
    keyBgAlt:  '#1c3528',
    keyText:   '#eaf6f0',
    glass:     'rgba(15,32,26,0.6)',
    aurora1:   'rgba(63,224,154,0.18)',
    aurora2:   'rgba(40,180,200,0.14)',
  },

  font: {
    ui:   '"Geist", "Inter", -apple-system, BlinkMacSystemFont, system-ui, sans-serif',
    uiAr: '"IBM Plex Sans Arabic", "Tajawal", system-ui, sans-serif',
    mono: '"JetBrains Mono", "Geist Mono", ui-monospace, SFMono-Regular, Menlo, monospace',
    math: '"KaTeX_Main", "Computer Modern", "Times New Roman", "Cambria Math", serif',
  },

  radius: { sm: 8, md: 12, lg: 16, xl: 20, '2xl': 28, full: 9999 },
};

window.NUMINA = NUMINA;

// Utility: theme by mode
window.theme = (dark) => dark ? NUMINA.dark : NUMINA.light;

// Inject web fonts once
if (!document.getElementById('numina-fonts')) {
  const link = document.createElement('link');
  link.id = 'numina-fonts';
  link.rel = 'stylesheet';
  link.href = 'https://fonts.googleapis.com/css2?family=Geist:wght@300;400;500;600;700&family=Geist+Mono:wght@400;500;600&family=IBM+Plex+Sans+Arabic:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500;600&display=swap';
  document.head.appendChild(link);

  // KaTeX for math rendering
  const katex = document.createElement('link');
  katex.rel = 'stylesheet';
  katex.href = 'https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.css';
  document.head.appendChild(katex);

  const ks = document.createElement('script');
  ks.src = 'https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.js';
  ks.defer = true;
  document.head.appendChild(ks);
}

// Math rendering helper
window.renderMath = (tex, displayMode = false) => {
  if (!window.katex) return tex;
  try {
    return window.katex.renderToString(tex, {
      displayMode, throwOnError: false, output: 'html',
    });
  } catch (e) { return tex; }
};

// Tiny TeX component
function Tex({ children, block = false, style = {} }) {
  const ref = React.useRef(null);
  const [, force] = React.useState(0);
  React.useEffect(() => {
    if (window.katex && ref.current) {
      try {
        window.katex.render(children, ref.current, { displayMode: block, throwOnError: false });
      } catch(e) {}
    } else {
      // retry shortly after katex loads
      const t = setTimeout(() => force(x => x+1), 200);
      return () => clearTimeout(t);
    }
  }, [children, block]);
  return <span ref={ref} style={{ display: block ? 'block' : 'inline', ...style }}>{children}</span>;
}
window.Tex = Tex;

// Shared icon set (stroke icons)
const Icon = ({ name, size = 20, color = 'currentColor', stroke = 1.6 }) => {
  const s = { width: size, height: size, fill: 'none', stroke: color, strokeWidth: stroke, strokeLinecap: 'round', strokeLinejoin: 'round' };
  switch (name) {
    case 'camera': return <svg viewBox="0 0 24 24" {...s}><path d="M3 8a2 2 0 012-2h2.5l1.5-2h6l1.5 2H19a2 2 0 012 2v10a2 2 0 01-2 2H5a2 2 0 01-2-2V8z"/><circle cx="12" cy="13" r="4"/></svg>;
    case 'sparkle': return <svg viewBox="0 0 24 24" {...s}><path d="M12 3l1.7 4.5L18 9l-4.3 1.5L12 15l-1.7-4.5L6 9l4.3-1.5L12 3z"/><path d="M19 16l.7 1.8L21 18.5l-1.3.7L19 21l-.7-1.8L17 18.5l1.3-.7L19 16z"/></svg>;
    case 'history': return <svg viewBox="0 0 24 24" {...s}><path d="M3 12a9 9 0 109-9 9.7 9.7 0 00-7 3M3 4v4h4"/><path d="M12 7v5l3 2"/></svg>;
    case 'chart': return <svg viewBox="0 0 24 24" {...s}><path d="M3 3v18h18"/><path d="M7 14l4-4 3 3 5-6"/></svg>;
    case 'units': return <svg viewBox="0 0 24 24" {...s}><path d="M7 4v16M17 4v16M4 8h6M14 16h6"/></svg>;
    case 'settings': return <svg viewBox="0 0 24 24" {...s}><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.7 1.7 0 00.4 1.8l.1.1a2 2 0 11-2.8 2.8l-.1-.1a1.7 1.7 0 00-1.8-.4 1.7 1.7 0 00-1 1.5V21a2 2 0 11-4 0v-.1a1.7 1.7 0 00-1.1-1.5 1.7 1.7 0 00-1.8.4l-.1.1a2 2 0 11-2.8-2.8l.1-.1a1.7 1.7 0 00.4-1.8 1.7 1.7 0 00-1.5-1H3a2 2 0 110-4h.1A1.7 1.7 0 004.6 9a1.7 1.7 0 00-.4-1.8l-.1-.1a2 2 0 112.8-2.8l.1.1a1.7 1.7 0 001.8.4H9a1.7 1.7 0 001-1.5V3a2 2 0 114 0v.1a1.7 1.7 0 001 1.5 1.7 1.7 0 001.8-.4l.1-.1a2 2 0 112.8 2.8l-.1.1a1.7 1.7 0 00-.4 1.8V9a1.7 1.7 0 001.5 1H21a2 2 0 110 4h-.1a1.7 1.7 0 00-1.5 1z"/></svg>;
    case 'flash': return <svg viewBox="0 0 24 24" {...s}><path d="M13 2L4 14h7l-1 8 9-12h-7l1-8z"/></svg>;
    case 'flashOff': return <svg viewBox="0 0 24 24" {...s}><path d="M13 2L4 14h4M11 22l1-7M3 3l18 18"/></svg>;
    case 'gallery': return <svg viewBox="0 0 24 24" {...s}><rect x="3" y="3" width="18" height="18" rx="3"/><circle cx="9" cy="10" r="1.5"/><path d="M3 17l5-4 4 3 3-2 6 4"/></svg>;
    case 'close': return <svg viewBox="0 0 24 24" {...s}><path d="M6 6l12 12M6 18L18 6"/></svg>;
    case 'check': return <svg viewBox="0 0 24 24" {...s}><path d="M5 12l5 5L20 7"/></svg>;
    case 'chevR': return <svg viewBox="0 0 24 24" {...s}><path d="M9 6l6 6-6 6"/></svg>;
    case 'chevL': return <svg viewBox="0 0 24 24" {...s}><path d="M15 6l-6 6 6 6"/></svg>;
    case 'chevD': return <svg viewBox="0 0 24 24" {...s}><path d="M6 9l6 6 6-6"/></svg>;
    case 'plus': return <svg viewBox="0 0 24 24" {...s}><path d="M12 5v14M5 12h14"/></svg>;
    case 'pin': return <svg viewBox="0 0 24 24" {...s}><path d="M12 17v5M9 3h6l1 4 3 3-4 1-3 4-3-4-4-1 3-3 1-4z"/></svg>;
    case 'share': return <svg viewBox="0 0 24 24" {...s}><path d="M12 3v13M7 8l5-5 5 5M5 21h14"/></svg>;
    case 'copy': return <svg viewBox="0 0 24 24" {...s}><rect x="9" y="9" width="11" height="11" rx="2"/><path d="M5 15V5a2 2 0 012-2h10"/></svg>;
    case 'mic': return <svg viewBox="0 0 24 24" {...s}><rect x="9" y="3" width="6" height="12" rx="3"/><path d="M5 11a7 7 0 0014 0M12 18v3"/></svg>;
    case 'bolt': return <svg viewBox="0 0 24 24" {...s}><path d="M13 2L4 14h7l-1 8 9-12h-7l1-8z"/></svg>;
    case 'book': return <svg viewBox="0 0 24 24" {...s}><path d="M4 4h6a4 4 0 014 4v12a3 3 0 00-3-3H4V4zM20 4h-6a4 4 0 00-4 4v12a3 3 0 013-3h7V4z"/></svg>;
    case 'search': return <svg viewBox="0 0 24 24" {...s}><circle cx="11" cy="11" r="7"/><path d="M21 21l-4.5-4.5"/></svg>;
    case 'rotate': return <svg viewBox="0 0 24 24" {...s}><path d="M3 12a9 9 0 1018 0M21 4v5h-5M3 20v-5h5"/></svg>;
    case 'sun': return <svg viewBox="0 0 24 24" {...s}><circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4 12H2M22 12h-2M5 5l1.5 1.5M17.5 17.5L19 19M5 19l1.5-1.5M17.5 6.5L19 5"/></svg>;
    case 'moon': return <svg viewBox="0 0 24 24" {...s}><path d="M21 13A9 9 0 1111 3a7 7 0 0010 10z"/></svg>;
    case 'globe': return <svg viewBox="0 0 24 24" {...s}><circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3a13 13 0 010 18M12 3a13 13 0 000 18"/></svg>;
    case 'crop': return <svg viewBox="0 0 24 24" {...s}><path d="M6 2v16h16M2 6h16v16"/></svg>;
    case 'menu': return <svg viewBox="0 0 24 24" {...s}><path d="M4 7h16M4 12h16M4 17h16"/></svg>;
    case 'home': return <svg viewBox="0 0 24 24" {...s}><path d="M3 11l9-8 9 8v9a2 2 0 01-2 2h-4v-7h-6v7H5a2 2 0 01-2-2v-9z"/></svg>;
    case 'eq': return <svg viewBox="0 0 24 24" {...s}><path d="M5 9h14M5 15h14"/></svg>;
    case 'lang': return <svg viewBox="0 0 24 24" {...s}><path d="M5 8h12M11 4v4M5 18l4-9 4 9M6 16h6M14 13c1 4 4 6 6 7M20 13c-1 4-4 6-6 7"/></svg>;
    case 'fx': return <svg viewBox="0 0 24 24" {...s}><path d="M5 4h14M5 12h10M5 20h14M16 8l4 4-4 4"/></svg>;
    case 'shapes': return <svg viewBox="0 0 24 24" {...s}><circle cx="7" cy="17" r="4"/><rect x="13" y="13" width="8" height="8" rx="1"/><path d="M12 3l5 8H7l5-8z"/></svg>;
    case 'dots': return <svg viewBox="0 0 24 24" {...s}><circle cx="5" cy="12" r="1.4" fill={color} stroke="none"/><circle cx="12" cy="12" r="1.4" fill={color} stroke="none"/><circle cx="19" cy="12" r="1.4" fill={color} stroke="none"/></svg>;
    case 'matrix': return <svg viewBox="0 0 24 24" {...s}><path d="M6 4v16M18 4v16M4 4h2M18 4h2M4 20h2M18 20h2"/><circle cx="10" cy="9" r="0.6" fill={color} stroke="none"/><circle cx="14" cy="9" r="0.6" fill={color} stroke="none"/><circle cx="10" cy="15" r="0.6" fill={color} stroke="none"/><circle cx="14" cy="15" r="0.6" fill={color} stroke="none"/></svg>;
    default: return null;
  }
};
window.Icon = Icon;

// Aurora background helper
function Aurora({ dark = false, intensity = 1 }) {
  const t = dark ? NUMINA.dark : NUMINA.light;
  return (
    <div style={{
      position: 'absolute', inset: 0, pointerEvents: 'none', overflow: 'hidden',
    }}>
      <div style={{
        position: 'absolute', top: -100, left: -50, width: 360, height: 360,
        borderRadius: '50%',
        background: `radial-gradient(circle, ${t.aurora1} 0%, transparent 70%)`,
        opacity: intensity, filter: 'blur(20px)',
      }} />
      <div style={{
        position: 'absolute', bottom: -80, right: -60, width: 320, height: 320,
        borderRadius: '50%',
        background: `radial-gradient(circle, ${t.aurora2} 0%, transparent 70%)`,
        opacity: intensity, filter: 'blur(20px)',
      }} />
      {/* grain */}
      <div style={{
        position: 'absolute', inset: 0, opacity: dark ? 0.06 : 0.04, mixBlendMode: dark ? 'screen' : 'multiply',
        backgroundImage: `url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='160' height='160'><filter id='n'><feTurbulence type='fractalNoise' baseFrequency='0.9'/></filter><rect width='100%' height='100%' filter='url(%23n)' opacity='0.7'/></svg>")`,
      }} />
    </div>
  );
}
window.Aurora = Aurora;

Object.assign(window, { NUMINA, Tex, Icon, Aurora });
