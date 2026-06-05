// calc-engine.jsx — Tiny but real expression evaluator
// Supports: + - * / ^ (), unary -, %, !, sin/cos/tan + inverses, ln/log/log_b,
// sqrt, cbrt, abs, exp, pi, e, deg/rad. Returns {value, error}.

(function(){
  const CONST = { pi: Math.PI, e: Math.E, phi: (1+Math.sqrt(5))/2 };
  const FNS = {
    sin: Math.sin, cos: Math.cos, tan: Math.tan,
    asin: Math.asin, acos: Math.acos, atan: Math.atan,
    sinh: Math.sinh, cosh: Math.cosh, tanh: Math.tanh,
    ln: Math.log, log: x => Math.log10(x),
    sqrt: Math.sqrt, cbrt: Math.cbrt, abs: Math.abs, exp: Math.exp,
  };

  function tokenize(s) {
    const tokens = [];
    let i = 0;
    while (i < s.length) {
      const c = s[i];
      if (c === ' ' || c === '\t') { i++; continue; }
      if (/[0-9.]/.test(c)) {
        let j = i; while (j < s.length && /[0-9.]/.test(s[j])) j++;
        tokens.push({ type: 'num', value: parseFloat(s.slice(i,j)) }); i = j; continue;
      }
      if (/[a-zA-Z_π]/.test(c)) {
        let j = i; while (j < s.length && /[a-zA-Z_]/.test(s[j])) j++;
        let name = s.slice(i,j) || c;
        if (c === 'π') { name = 'pi'; j = i+1; }
        tokens.push({ type: 'name', value: name }); i = j; continue;
      }
      if ('+-*/^()%!,'.includes(c)) {
        tokens.push({ type: 'op', value: c }); i++; continue;
      }
      if (c === '×') { tokens.push({type:'op',value:'*'}); i++; continue; }
      if (c === '÷') { tokens.push({type:'op',value:'/'}); i++; continue; }
      if (c === '−') { tokens.push({type:'op',value:'-'}); i++; continue; }
      throw new Error('Bad char: ' + c);
    }
    return tokens;
  }

  // Recursive-descent parser
  function parse(tokens, mode='deg') {
    let pos = 0;
    const peek = () => tokens[pos];
    const eat = () => tokens[pos++];

    function parseExpr() { return parseAdd(); }
    function parseAdd() {
      let left = parseMul();
      while (peek() && peek().type==='op' && (peek().value==='+' || peek().value==='-')) {
        const op = eat().value; const right = parseMul();
        left = { op, left, right };
      }
      return left;
    }
    function parseMul() {
      let left = parseUnary();
      while (peek() && peek().type==='op' && (peek().value==='*' || peek().value==='/')) {
        const op = eat().value; const right = parseUnary();
        left = { op, left, right };
      }
      return left;
    }
    function parseUnary() {
      if (peek() && peek().type==='op' && peek().value==='-') {
        eat(); return { op: 'neg', arg: parseUnary() };
      }
      if (peek() && peek().type==='op' && peek().value==='+') { eat(); return parseUnary(); }
      return parsePow();
    }
    function parsePow() {
      let base = parsePost();
      if (peek() && peek().type==='op' && peek().value==='^') {
        eat(); const exp = parseUnary();
        return { op: '^', left: base, right: exp };
      }
      return base;
    }
    function parsePost() {
      let node = parseAtom();
      while (peek() && peek().type==='op' && (peek().value==='!' || peek().value==='%')) {
        const op = eat().value; node = { op: op==='!'?'fact':'pct', arg: node };
      }
      return node;
    }
    function parseAtom() {
      const t = eat();
      if (!t) throw new Error('Unexpected end');
      if (t.type==='num') return { num: t.value };
      if (t.type==='name') {
        if (peek() && peek().type==='op' && peek().value==='(') {
          eat();
          const args = [parseExpr()];
          while (peek() && peek().type==='op' && peek().value===',') { eat(); args.push(parseExpr()); }
          if (!peek() || peek().value!==')') throw new Error('Expected )');
          eat();
          return { fn: t.value, args };
        }
        return { name: t.value };
      }
      if (t.type==='op' && t.value==='(') {
        const e = parseExpr();
        if (!peek() || peek().value!==')') throw new Error('Expected )');
        eat();
        return e;
      }
      throw new Error('Unexpected token');
    }

    const tree = parseExpr();
    if (pos < tokens.length) throw new Error('Trailing input');
    return tree;
  }

  function fact(n) {
    if (n < 0 || !Number.isInteger(n)) return NaN;
    let r = 1; for (let i=2;i<=n;i++) r*=i; return r;
  }

  function evalNode(node, mode='deg') {
    if ('num' in node) return node.num;
    if ('name' in node) {
      if (node.name in CONST) return CONST[node.name];
      throw new Error('Unknown: '+node.name);
    }
    if ('fn' in node) {
      const a = node.args.map(x=>evalNode(x,mode));
      const f = node.fn;
      if (f === 'sin' || f === 'cos' || f === 'tan') {
        const v = mode === 'deg' ? a[0] * Math.PI/180 : a[0];
        return FNS[f](v);
      }
      if (f === 'asin' || f === 'acos' || f === 'atan') {
        const v = FNS[f](a[0]);
        return mode === 'deg' ? v * 180/Math.PI : v;
      }
      if (f in FNS) return FNS[f](...a);
      if (f === 'pow') return Math.pow(a[0], a[1]);
      if (f === 'root') return Math.pow(a[1], 1/a[0]);
      throw new Error('Unknown fn '+f);
    }
    if (node.op === '+') return evalNode(node.left,mode) + evalNode(node.right,mode);
    if (node.op === '-') return evalNode(node.left,mode) - evalNode(node.right,mode);
    if (node.op === '*') return evalNode(node.left,mode) * evalNode(node.right,mode);
    if (node.op === '/') return evalNode(node.left,mode) / evalNode(node.right,mode);
    if (node.op === '^') return Math.pow(evalNode(node.left,mode), evalNode(node.right,mode));
    if (node.op === 'neg') return -evalNode(node.arg,mode);
    if (node.op === 'fact') return fact(evalNode(node.arg,mode));
    if (node.op === 'pct') return evalNode(node.arg,mode)/100;
    throw new Error('Bad node');
  }

  function evaluate(expr, mode='deg') {
    try {
      // Pre: replace common notations
      const norm = expr.replace(/×/g,'*').replace(/÷/g,'/').replace(/−/g,'-').replace(/π/g,'pi');
      const tokens = tokenize(norm);
      const tree = parse(tokens, mode);
      const value = evalNode(tree, mode);
      if (!isFinite(value)) return { error: 'Math error' };
      return { value };
    } catch(e) { return { error: e.message }; }
  }

  // Pretty number
  function fmt(n) {
    if (n === undefined || n === null || Number.isNaN(n)) return '';
    if (Math.abs(n) >= 1e10 || (Math.abs(n) > 0 && Math.abs(n) < 1e-6)) {
      return n.toExponential(6).replace('e+','×10^').replace('e-','×10⁻');
    }
    const s = +n.toPrecision(12);
    return String(s);
  }

  window.calcEval = evaluate;
  window.calcFmt = fmt;
})();
