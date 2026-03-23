class Complex {
  re: number = 0;
  im: number = 0;

  constructor(re: number = 0, im: number = 0) {
    this.re = re;
    this.im = im;
  }
}

class Quaternion {
  a: number = 0;
  b: number = 0;
  c: number = 0;
  d: number = 0;

  constructor(a: number = 0, b: number = 0, c: number = 0, d: number = 0) {
    this.a = a;
    this.b = b;
    this.c = c;
    this.d = d;
  }
}

class DualQuaternion {
  primal: Quaternion = new Quaternion();
  dual: Quaternion = new Quaternion();

  constructor(primal: Quaternion, dual: Quaternion) {
    this.primal = primal;
    this.dual = dual;
  }
}

class EigDecomp {
  values: number[] = [];
  vectors: number[][] = [];

  constructor(values: number[], vectors: number[][]) {
    this.values = values;
    this.vectors = vectors;
  }
}

class SupplementSolveResult {
  lambdaS: number[] = [];
  lambdaD: number[] = [];
  primalEigenvectors: Quaternion[][] = [];
  dualEigenvectors: Quaternion[][] = [];

  constructor(lambdaS: number[], lambdaD: number[], primalEigenvectors: Quaternion[][], dualEigenvectors: Quaternion[][]) {
    this.lambdaS = lambdaS;
    this.lambdaD = lambdaD;
    this.primalEigenvectors = primalEigenvectors;
    this.dualEigenvectors = dualEigenvectors;
  }
}

class SplitResult {
  standard: Quaternion[][] = [];
  dual: Quaternion[][] = [];

  constructor(standard: Quaternion[][], dual: Quaternion[][]) {
    this.standard = standard;
    this.dual = dual;
  }
}

class AlphaBeta {
  alpha: Complex = new Complex();
  beta: Complex = new Complex();

  constructor(alpha: Complex, beta: Complex) {
    this.alpha = alpha;
    this.beta = beta;
  }
}

class IndexValue {
  value: number = 0;
  index: number = 0;

  constructor(value: number, index: number) {
    this.value = value;
    this.index = index;
  }
}

export class EigenSolveResult {
  ok: boolean = false;
  message: string = '';
  values: string[] = [];
  vectors: string[] = [];

  constructor(ok: boolean, message: string, values: string[], vectors: string[]) {
    this.ok = ok;
    this.message = message;
    this.values = values;
    this.vectors = vectors;
  }
}

export class FormationResult {
  ok: boolean = false;
  message: string = '';
  feasible: boolean = false;
  eigenvalues: string[] = [];

  constructor(ok: boolean, message: string, feasible: boolean, eigenvalues: string[]) {
    this.ok = ok;
    this.message = message;
    this.feasible = feasible;
    this.eigenvalues = eigenvalues;
  }
}

function complex(re: number = 0, im: number = 0): Complex {
  return new Complex(re, im);
}

function complexConj(x: Complex): Complex {
  return new Complex(x.re, -x.im);
}

function complexNeg(x: Complex): Complex {
  return new Complex(-x.re, -x.im);
}

function approxEqual(a: number, b: number, tol: number): boolean {
  return Math.abs(a - b) <= tol;
}

function isNegativeZero(x: number): boolean {
  return x === 0 && (1 / x) < 0;
}

function quaternionConj(q: Quaternion): Quaternion {
  return new Quaternion(q.a, -q.b, -q.c, -q.d);
}

function isQuaternionApproxEqual(x: Quaternion, y: Quaternion, tol: number): boolean {
  return approxEqual(x.a, y.a, tol) && approxEqual(x.b, y.b, tol) && approxEqual(x.c, y.c, tol) && approxEqual(x.d, y.d, tol);
}

function makeRealMatrix(n: number): number[][] {
  const m: number[][] = [];
  for (let i = 0; i < n; i++) {
    const row: number[] = [];
    for (let j = 0; j < n; j++) {
      row.push(0);
    }
    m.push(row);
  }
  return m;
}

function makeComplexMatrix(n: number): Complex[][] {
  const m: Complex[][] = [];
  for (let i = 0; i < n; i++) {
    const row: Complex[] = [];
    for (let j = 0; j < n; j++) {
      row.push(new Complex());
    }
    m.push(row);
  }
  return m;
}

function parseDualQuaternion(token: string): DualQuaternion {
  const parts: string[] = token.split(',');
  if (parts.length !== 8) {
    throw new Error(`元素 "${token}" 不是 8 个实数`);
  }
  const nums: number[] = [];
  for (let i = 0; i < 8; i++) {
    const v: number = Number(parts[i].trim());
    if (Number.isNaN(v)) {
      throw new Error(`元素 "${token}" 存在非数字输入`);
    }
    nums.push(v);
  }
  return new DualQuaternion(new Quaternion(nums[0], nums[1], nums[2], nums[3]), new Quaternion(nums[4], nums[5], nums[6], nums[7]));
}

function parseDualQuaternionMatrix(text: string, n: number): DualQuaternion[][] {
  const lines: string[] = text.split(/\r?\n/).map((s: string) => s.trim()).filter((s: string) => s.length > 0);
  if (lines.length !== n) {
    throw new Error(`矩阵行数应为 ${n}，当前为 ${lines.length}`);
  }
  const matrix: DualQuaternion[][] = [];
  for (let i = 0; i < n; i++) {
    const cols: string[] = lines[i].split(';').map((s: string) => s.trim()).filter((s: string) => s.length > 0);
    if (cols.length !== n) {
      throw new Error(`第 ${i + 1} 行列数应为 ${n}，当前为 ${cols.length}`);
    }
    const row: DualQuaternion[] = [];
    for (let j = 0; j < n; j++) {
      row.push(parseDualQuaternion(cols[j]));
    }
    matrix.push(row);
  }
  return matrix;
}

function splitStandardAndDual(matrix: DualQuaternion[][]): SplitResult {
  const n: number = matrix.length;
  const standard: Quaternion[][] = [];
  const dual: Quaternion[][] = [];
  for (let i = 0; i < n; i++) {
    const rowS: Quaternion[] = [];
    const rowD: Quaternion[] = [];
    for (let j = 0; j < n; j++) {
      rowS.push(matrix[i][j].primal);
      rowD.push(matrix[i][j].dual);
    }
    standard.push(rowS);
    dual.push(rowD);
  }
  return new SplitResult(standard, dual);
}

function validateDualQuaternionHermitian(matrix: DualQuaternion[][], tol: number = 1e-8): void {
  const n: number = matrix.length;
  for (let i = 0; i < n; i++) {
    const d: DualQuaternion = matrix[i][i];
    if (!approxEqual(d.primal.b, 0, tol) || !approxEqual(d.primal.c, 0, tol) || !approxEqual(d.primal.d, 0, tol)) {
      throw new Error(`矩阵不是埃尔米特矩阵：第 ${i + 1} 个对角元标准部应为实数四元数`);
    }
    if (!approxEqual(d.dual.b, 0, tol) || !approxEqual(d.dual.c, 0, tol) || !approxEqual(d.dual.d, 0, tol)) {
      throw new Error(`矩阵不是埃尔米特矩阵：第 ${i + 1} 个对角元对偶部应为实数四元数`);
    }
    for (let j = i + 1; j < n; j++) {
      const aij: DualQuaternion = matrix[i][j];
      const aji: DualQuaternion = matrix[j][i];
      const cPrimal: Quaternion = quaternionConj(aij.primal);
      const cDual: Quaternion = quaternionConj(aij.dual);
      if (!isQuaternionApproxEqual(aji.primal, cPrimal, tol) || !isQuaternionApproxEqual(aji.dual, cDual, tol)) {
        throw new Error(`矩阵不是埃尔米特矩阵：第 (${i + 1},${j + 1}) 与 (${j + 1},${i + 1}) 不满足共轭转置关系`);
      }
    }
  }
}

function quaternionToAlphaBeta(q: Quaternion): AlphaBeta {
  return new AlphaBeta(new Complex(q.a, q.b), new Complex(q.c, q.d));
}

function quaternionHermitianToComplexAdjoint(matrix: Quaternion[][]): Complex[][] {
  const n: number = matrix.length;
  const m: number = 2 * n;
  const adj: Complex[][] = makeComplexMatrix(m);
  for (let i = 0; i < n; i++) {
    for (let j = 0; j < n; j++) {
      const ab: AlphaBeta = quaternionToAlphaBeta(matrix[i][j]);
      adj[i][j] = ab.alpha;
      adj[i][j + n] = ab.beta;
      adj[i + n][j] = complexNeg(complexConj(ab.beta));
      adj[i + n][j + n] = complexConj(ab.alpha);
    }
  }
  return adj;
}

function complexHermitianToRealSymmetric(h: Complex[][]): number[][] {
  const m: number = h.length;
  const r: number[][] = makeRealMatrix(2 * m);
  for (let i = 0; i < m; i++) {
    for (let j = 0; j < m; j++) {
      const re: number = h[i][j].re;
      const im: number = h[i][j].im;
      r[i][j] = re;
      r[i][j + m] = -im;
      r[i + m][j] = im;
      r[i + m][j + m] = re;
    }
  }
  return r;
}

function transpose(a: number[][]): number[][] {
  const n: number = a.length;
  const m: number = a[0].length;
  const t: number[][] = makeRealMatrix(m);
  for (let i = 0; i < m; i++) {
    for (let j = 0; j < n; j++) {
      t[i][j] = a[j][i];
    }
  }
  return t;
}

function multiply(a: number[][], b: number[][]): number[][] {
  const n: number = a.length;
  const p: number = a[0].length;
  const m: number = b[0].length;
  const out: number[][] = makeRealMatrix(n);
  for (let i = 0; i < n; i++) {
    out[i] = [];
    for (let j = 0; j < m; j++) {
      let s: number = 0;
      for (let k = 0; k < p; k++) {
        s += a[i][k] * b[k][j];
      }
      out[i][j] = s;
    }
  }
  return out;
}

function identity(n: number): number[][] {
  const iM: number[][] = makeRealMatrix(n);
  for (let i = 0; i < n; i++) {
    iM[i][i] = 1;
  }
  return iM;
}

function jacobiEigenSymmetric(input: number[][], eps: number = 1e-11, maxIter: number = 200): EigDecomp {
  const n: number = input.length;
  const a: number[][] = input.map((row: number[]) => [...row]);
  const v: number[][] = identity(n);
  const sweepLimit: number = maxIter * n * n;

  for (let sweep = 0; sweep < sweepLimit; sweep++) {
    let p: number = 0;
    let q: number = 1;
    let maxVal: number = 0;
    for (let i = 0; i < n; i++) {
      for (let j = i + 1; j < n; j++) {
        const val: number = Math.abs(a[i][j]);
        if (val > maxVal) {
          maxVal = val;
          p = i;
          q = j;
        }
      }
    }
    if (maxVal < eps) {
      break;
    }

    const app: number = a[p][p];
    const aqq: number = a[q][q];
    const apq: number = a[p][q];
    const phi: number = 0.5 * Math.atan2(2 * apq, aqq - app);
    const c: number = Math.cos(phi);
    const s: number = Math.sin(phi);

    for (let k = 0; k < n; k++) {
      if (k !== p && k !== q) {
        const akp: number = a[k][p];
        const akq: number = a[k][q];
        a[k][p] = c * akp - s * akq;
        a[p][k] = a[k][p];
        a[k][q] = s * akp + c * akq;
        a[q][k] = a[k][q];
      }
    }

    a[p][p] = c * c * app - 2 * s * c * apq + s * s * aqq;
    a[q][q] = s * s * app + 2 * s * c * apq + c * c * aqq;
    a[p][q] = 0;
    a[q][p] = 0;

    for (let k = 0; k < n; k++) {
      const vkp: number = v[k][p];
      const vkq: number = v[k][q];
      v[k][p] = c * vkp - s * vkq;
      v[k][q] = s * vkp + c * vkq;
    }
  }

  const pairs: IndexValue[] = [];
  for (let i = 0; i < n; i++) {
    pairs.push(new IndexValue(a[i][i], i));
  }
  pairs.sort((x: IndexValue, y: IndexValue) => x.value - y.value);

  const values: number[] = [];
  const vectors: number[][] = [];
  for (let k = 0; k < n; k++) {
    values.push(pairs[k].value);
  }
  for (let row = 0; row < n; row++) {
    const outRow: number[] = [];
    for (let col = 0; col < n; col++) {
      outRow.push(v[row][pairs[col].index]);
    }
    vectors.push(outRow);
  }
  return new EigDecomp(values, vectors);
}

function clusterByGap(values: number[], tol: number): number[][] {
  const groups: number[][] = [];
  if (values.length === 0) {
    return groups;
  }
  let current: number[] = [0];
  for (let i = 1; i < values.length; i++) {
    if (Math.abs(values[i] - values[i - 1]) <= tol) {
      current.push(i);
    } else {
      groups.push(current);
      current = [i];
    }
  }
  groups.push(current);
  return groups;
}

function estimateTolerance(values: number[]): number {
  let maxAbs: number = 0;
  for (let i = 0; i < values.length; i++) {
    const t: number = Math.abs(values[i]);
    if (t > maxAbs) {
      maxAbs = t;
    }
  }
  return Math.max(1e-8, maxAbs * 1e-7);
}

function columnsOf(a: number[][], idx: number[]): number[][] {
  const n: number = a.length;
  const out: number[][] = [];
  for (let i = 0; i < n; i++) {
    const row: number[] = [];
    for (let j = 0; j < idx.length; j++) {
      row.push(a[i][idx[j]]);
    }
    out.push(row);
  }
  return out;
}

function realEmbeddingOfQuaternionHermitian(matrix: Quaternion[][]): number[][] {
  const complexAdj: Complex[][] = quaternionHermitianToComplexAdjoint(matrix);
  return complexHermitianToRealSymmetric(complexAdj);
}

function formatNumber(x: number): string {
  const y: number = Number(x.toFixed(9));
  if (isNegativeZero(y)) {
    return '0';
  }
  return y.toString();
}

function repeatedCollapse(values: number[], repeat: number): number[] {
  if (values.length === 0) {
    return [];
  }
  const sorted: number[] = [...values].sort((a: number, b: number) => a - b);
  const out: number[] = [];
  const c: number = Math.max(1, Math.floor(sorted.length / repeat));
  for (let i = 0; i < c; i++) {
    const l: number = i * repeat;
    const r: number = Math.min(sorted.length, (i + 1) * repeat);
    let s: number = 0;
    for (let k = l; k < r; k++) {
      s += sorted[k];
    }
    out.push(s / (r - l));
  }
  return out;
}

function columnVector(a: number[][], col: number): number[] {
  const out: number[] = [];
  for (let i = 0; i < a.length; i++) {
    out.push(a[i][col]);
  }
  return out;
}

function realVectorToQuaternionEigenvector(realVec: number[], n: number): Quaternion[] {
  const m: number = 2 * n;
  const qVec: Quaternion[] = [];
  for (let i = 0; i < n; i++) {
    const alphaRe: number = realVec[i];
    const alphaIm: number = realVec[i + m];
    const betaRe: number = realVec[i + n];
    const betaIm: number = realVec[i + n + m];
    qVec.push(new Quaternion(alphaRe, alphaIm, betaRe, betaIm));
  }
  return qVec;
}

function formatSigned(x: number): string {
  const s: string = formatNumber(x);
  return x >= 0 ? `+${s}` : s;
}

function formatQuaternion(q: Quaternion): string {
  const a: string = formatNumber(q.a);
  const b: string = formatSigned(q.b);
  const c: string = formatSigned(q.c);
  const d: string = formatSigned(q.d);
  return `${a}${b}i${c}j${d}k`;
}

function formatQuaternionVector(vec: Quaternion[]): string {
  const parts: string[] = [];
  for (let i = 0; i < vec.length; i++) {
    parts.push(formatQuaternion(vec[i]));
  }
  return `[${parts.join(', ')}]`;
}

function formatDualQuaternionVector(primalVec: Quaternion[], dualVec: Quaternion[]): string {
  const parts: string[] = [];
  for (let i = 0; i < primalVec.length; i++) {
    const p: Quaternion = primalVec[i];
    const d: Quaternion = i < dualVec.length ? dualVec[i] : new Quaternion();
    parts.push(`(${formatQuaternion(p)})+(${formatQuaternion(d)})·ε`);
  }
  return `[${parts.join(', ')}]`;
}

function vectorDot(a: number[], b: number[]): number {
  let s: number = 0;
  for (let i = 0; i < a.length; i++) {
    s += a[i] * b[i];
  }
  return s;
}

function matVecMul(a: number[][], x: number[]): number[] {
  const out: number[] = [];
  for (let i = 0; i < a.length; i++) {
    let s: number = 0;
    for (let j = 0; j < x.length; j++) {
      s += a[i][j] * x[j];
    }
    out.push(s);
  }
  return out;
}

function vectorAdd(a: number[], b: number[]): number[] {
  const out: number[] = [];
  for (let i = 0; i < a.length; i++) {
    out.push(a[i] + b[i]);
  }
  return out;
}

function vectorScale(a: number[], k: number): number[] {
  const out: number[] = [];
  for (let i = 0; i < a.length; i++) {
    out.push(a[i] * k);
  }
  return out;
}

function solveLinearSystem(a: number[][], b: number[]): number[] {
  const n: number = a.length;
  const m: number[][] = [];
  for (let i = 0; i < n; i++) {
    const row: number[] = [];
    for (let j = 0; j < n; j++) {
      row.push(a[i][j]);
    }
    row.push(b[i]);
    m.push(row);
  }
  for (let col = 0; col < n; col++) {
    let pivot: number = col;
    for (let r = col + 1; r < n; r++) {
      if (Math.abs(m[r][col]) > Math.abs(m[pivot][col])) {
        pivot = r;
      }
    }
    if (Math.abs(m[pivot][col]) < 1e-12) {
      continue;
    }
    if (pivot !== col) {
      const tmp: number[] = m[col];
      m[col] = m[pivot];
      m[pivot] = tmp;
    }
    const base: number = m[col][col];
    for (let j = col; j <= n; j++) {
      m[col][j] = m[col][j] / base;
    }
    for (let r = 0; r < n; r++) {
      if (r === col) {
        continue;
      }
      const factor: number = m[r][col];
      if (Math.abs(factor) < 1e-20) {
        continue;
      }
      for (let j = col; j <= n; j++) {
        m[r][j] = m[r][j] - factor * m[col][j];
      }
    }
  }
  const x: number[] = [];
  for (let i = 0; i < n; i++) {
    x.push(m[i][n]);
  }
  return x;
}

function solveDualPartRealVector(realAs: number[][], realAd: number[][], lambdaS: number, lambdaD: number, primalVec: number[]): number[] {
  const m: number = realAs.length;
  const kMat: number[][] = makeRealMatrix(m);
  for (let i = 0; i < m; i++) {
    for (let j = 0; j < m; j++) {
      kMat[i][j] = realAs[i][j] - (i === j ? lambdaS : 0);
    }
  }
  const rhsTerm: number[] = matVecMul(realAd, primalVec);
  const rhs: number[] = [];
  for (let i = 0; i < m; i++) {
    rhs.push(-(rhsTerm[i] - lambdaD * primalVec[i]));
  }
  const kt: number[][] = transpose(kMat);
  const normalA: number[][] = multiply(kt, kMat);
  const normalB: number[] = matVecMul(kt, rhs);
  const reg: number = 1e-10;
  for (let i = 0; i < m; i++) {
    normalA[i][i] += reg;
  }
  let dualVec: number[] = solveLinearSystem(normalA, normalB);
  const denom: number = vectorDot(primalVec, primalVec);
  if (Math.abs(denom) > 1e-12) {
    const proj: number = vectorDot(primalVec, dualVec) / denom;
    dualVec = vectorAdd(dualVec, vectorScale(primalVec, -proj));
  }
  return dualVec;
}

function dualPartsBySupplement(realAs: number[][], realAd: number[][]): SupplementSolveResult {
  const eigAs: EigDecomp = jacobiEigenSymmetric(realAs);
  const standardTol: number = estimateTolerance(eigAs.values);
  const groups: number[][] = clusterByGap(eigAs.values, standardTol);
  if (realAs.length % 4 !== 0) {
    throw new Error(`实嵌入维度异常: ${realAs.length} 不是 4 的倍数`);
  }
  const n: number = Math.floor(realAs.length / 4);
  const lambdaS: number[] = [];
  const lambdaD: number[] = [];
  const primalEigenvectors: Quaternion[][] = [];
  const primalRealVectors: number[][] = [];

  for (let gi = 0; gi < groups.length; gi++) {
    const idx: number[] = groups[gi];
    if (idx.length % 4 !== 0) {
      throw new Error(`标准部重根维度异常：第 ${gi + 1} 组维度为 ${idx.length}，不是 4 的倍数`);
    }
    const sVals: number[] = [];
    for (let t = 0; t < idx.length; t++) {
      sVals.push(eigAs.values[idx[t]]);
    }
    const collapsedS: number[] = repeatedCollapse(sVals, 4);
    for (let t = 0; t < collapsedS.length; t++) {
      lambdaS.push(collapsedS[t]);
    }

    for (let t = 0; t < collapsedS.length; t++) {
      const repCol: number = idx[t * 4];
      const realVec: number[] = columnVector(eigAs.vectors, repCol);
      primalRealVectors.push(realVec);
      primalEigenvectors.push(realVectorToQuaternionEigenvector(realVec, n));
    }

    const u: number[][] = columnsOf(eigAs.vectors, idx);
    const ut: number[][] = transpose(u);
    const sMat: number[][] = multiply(multiply(ut, realAd), u);
    const sEig: EigDecomp = jacobiEigenSymmetric(sMat);
    const collapsedD: number[] = repeatedCollapse(sEig.values, 4);
    for (let k = 0; k < collapsedD.length; k++) {
      lambdaD.push(collapsedD[k]);
    }
  }

  const dualEigenvectors: Quaternion[][] = [];
  for (let i = 0; i < lambdaS.length; i++) {
    const dualReal: number[] = solveDualPartRealVector(realAs, realAd, lambdaS[i], lambdaD[i], primalRealVectors[i]);
    dualEigenvectors.push(realVectorToQuaternionEigenvector(dualReal, n));
  }

  return new SupplementSolveResult(lambdaS, lambdaD, primalEigenvectors, dualEigenvectors);
}

export function solveDualQuaternionHermitianEigenvalues(matrixText: string, n: number): EigenSolveResult {
  try {
    if (n < 2 || n > 8) {
      return new EigenSolveResult(false, 'n 必须在 2 到 8 之间', [], []);
    }
    const dualQ: DualQuaternion[][] = parseDualQuaternionMatrix(matrixText, n);
    validateDualQuaternionHermitian(dualQ);
    const split: SplitResult = splitStandardAndDual(dualQ);
    const rs: number[][] = realEmbeddingOfQuaternionHermitian(split.standard);
    const rd: number[][] = realEmbeddingOfQuaternionHermitian(split.dual);
    const ans: SupplementSolveResult = dualPartsBySupplement(rs, rd);

    if (ans.lambdaS.length !== n || ans.lambdaD.length !== n) {
      return new EigenSolveResult(false, `求解结果维度异常: 标准部 ${ans.lambdaS.length}, 对偶部 ${ans.lambdaD.length}`, [], []);
    }
    if (ans.primalEigenvectors.length !== n || ans.dualEigenvectors.length !== n) {
      return new EigenSolveResult(false, `求解结果维度异常: 特征向量数量 ${ans.primalEigenvectors.length}/${ans.dualEigenvectors.length}`, [], []);
    }

    const values: string[] = [];
    const vectors: string[] = [];
    for (let i = 0; i < n; i++) {
      values.push(`${formatNumber(ans.lambdaS[i])}+${formatNumber(ans.lambdaD[i])}·ε`);
      vectors.push(formatDualQuaternionVector(ans.primalEigenvectors[i], ans.dualEigenvectors[i]));
    }
    return new EigenSolveResult(true, 'ok', values, vectors);
  } catch (e) {
    return new EigenSolveResult(false, `${e}`, [], []);
  }
}

function parseRealMatrix(text: string, n: number): number[][] {
  const lines: string[] = text.split(/\r?\n/).map((s: string) => s.trim()).filter((s: string) => s.length > 0);
  if (lines.length !== n) {
    throw new Error(`矩阵行数应为 ${n}，当前为 ${lines.length}`);
  }
  const matrix: number[][] = [];
  for (let i = 0; i < n; i++) {
    const parts: string[] = lines[i].split(',').map((s: string) => s.trim()).filter((s: string) => s.length > 0);
    if (parts.length !== n) {
      throw new Error(`第 ${i + 1} 行列数应为 ${n}，当前为 ${parts.length}`);
    }
    const row: number[] = [];
    for (let j = 0; j < n; j++) {
      const v: number = Number(parts[j]);
      if (Number.isNaN(v)) {
        throw new Error(`第 ${i + 1} 行第 ${j + 1} 列不是数字`);
      }
      row.push(v);
    }
    matrix.push(row);
  }
  return matrix;
}

function symmetrize(a: number[][]): number[][] {
  const n: number = a.length;
  const s: number[][] = makeRealMatrix(n);
  for (let i = 0; i < n; i++) {
    for (let j = 0; j < n; j++) {
      s[i][j] = 0.5 * (a[i][j] + a[j][i]);
    }
  }
  return s;
}

export function evaluateFormationFeasibility(laplacianText: string, n: number): FormationResult {
  try {
    if (n < 2 || n > 8) {
      return new FormationResult(false, 'n 必须在 2 到 8 之间', false, []);
    }

    const l: number[][] = parseRealMatrix(laplacianText, n);
    const lSym: number[][] = symmetrize(l);
    const eigen: number[] = jacobiEigenSymmetric(lSym).values.sort((a: number, b: number) => a - b);
    const tol: number = 1e-6;

    let rowSumOk: boolean = true;
    let offDiagOk: boolean = true;
    let diagOk: boolean = true;
    let symmetryOk: boolean = true;

    for (let i = 0; i < n; i++) {
      let sum: number = 0;
      for (let j = 0; j < n; j++) {
        sum += l[i][j];
        if (!approxEqual(l[i][j], l[j][i], 1e-5)) {
          symmetryOk = false;
        }
        if (i !== j && l[i][j] > tol) {
          offDiagOk = false;
        }
      }
      if (Math.abs(sum) > 1e-5) {
        rowSumOk = false;
      }
      if (l[i][i] < -tol) {
        diagOk = false;
      }
    }

    let zeroCount: number = 0;
    for (let i = 0; i < eigen.length; i++) {
      if (Math.abs(eigen[i]) <= tol) {
        zeroCount++;
      }
    }

    const psdOk: boolean = eigen[0] >= -tol;
    const lambda2: number = eigen[1];
    const feasible: boolean = rowSumOk && offDiagOk && diagOk && symmetryOk && psdOk && zeroCount === 1 && lambda2 > tol;
    const message: string = `lambda2=${formatNumber(lambda2)}, zeroCount=${zeroCount}, symmetryOk=${symmetryOk}, rowSumOk=${rowSumOk}, offDiagOk=${offDiagOk}, diagOk=${diagOk}, psdOk=${psdOk}`;
    const eigenText: string[] = eigen.map((x: number) => formatNumber(x));
    return new FormationResult(true, message, feasible, eigenText);
  } catch (e) {
    return new FormationResult(false, `${e}`, false, []);
  }
}
