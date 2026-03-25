const DISPLAY_DECIMALS: number = 6;
const DISPLAY_ZERO_TOL: number = 1e-10;
const EIGEN_TOL: number = 1e-8;
const RESIDUAL_TOL: number = 5e-6;

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

class EigenPair {
  lambdaS: number = 0;
  lambdaD: number = 0;
  primalReal: number[] = [];
  dualReal: number[] = [];
  primalQuaternion: Quaternion[] = [];
  dualQuaternion: Quaternion[] = [];
  residualStandard: number = 0;
  residualDual: number = 0;

  constructor(lambdaS: number, lambdaD: number, primalReal: number[], dualReal: number[], primalQuaternion: Quaternion[],
    dualQuaternion: Quaternion[], residualStandard: number, residualDual: number) {
    this.lambdaS = lambdaS;
    this.lambdaD = lambdaD;
    this.primalReal = primalReal;
    this.dualReal = dualReal;
    this.primalQuaternion = primalQuaternion;
    this.dualQuaternion = dualQuaternion;
    this.residualStandard = residualStandard;
    this.residualDual = residualDual;
  }
}

class SupplementSolveResult {
  pairs: EigenPair[] = [];

  constructor(pairs: EigenPair[]) {
    this.pairs = pairs;
  }
}

class CollapsedEigenBlock {
  lambda: number = 0;
  reps: number[] = [];

  constructor(lambda: number, reps: number[]) {
    this.lambda = lambda;
    this.reps = reps;
  }
}

class DualScalar {
  standard: number = 0;
  dual: number = 0;

  constructor(standard: number, dual: number) {
    this.standard = standard;
    this.dual = dual;
  }
}

export class EigenDisplayItem {
  index: number = 0;
  lambdaS: number = 0;
  lambdaD: number = 0;
  lambdaSText: string = '';
  lambdaDText: string = '';
  lambdaText: string = '';
  vectorTitle: string = '';
  vectorLines: string[] = [];
  vectorText: string = '';
  residualStandard: number = 0;
  residualDual: number = 0;
  primalVectorComponents: number[][] = [];
  dualVectorComponents: number[][] = [];

  constructor(index: number, lambdaS: number, lambdaD: number, lambdaSText: string, lambdaDText: string, lambdaText: string,
    vectorTitle: string, vectorLines: string[],
    residualStandard: number, residualDual: number, primalVectorComponents: number[][], dualVectorComponents: number[][]) {
    this.index = index;
    this.lambdaS = lambdaS;
    this.lambdaD = lambdaD;
    this.lambdaSText = lambdaSText;
    this.lambdaDText = lambdaDText;
    this.lambdaText = lambdaText;
    this.vectorTitle = vectorTitle;
    this.vectorLines = vectorLines;
    this.vectorText = vectorLines.join('\n');
    this.residualStandard = residualStandard;
    this.residualDual = residualDual;
    this.primalVectorComponents = primalVectorComponents;
    this.dualVectorComponents = dualVectorComponents;
  }
}

export class EigenSolveResult {
  ok: boolean = false;
  message: string = '';
  values: string[] = [];
  vectors: string[] = [];
  items: EigenDisplayItem[] = [];

  constructor(ok: boolean, message: string, values: string[], vectors: string[], items: EigenDisplayItem[]) {
    this.ok = ok;
    this.message = message;
    this.values = values;
    this.vectors = vectors;
    this.items = items;
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

export class FormationConditionItem {
  key: string = '';
  label: string = '';
  passed: boolean = false;
  statusText: string = '';
  helpTitle: string = '';
  helpText: string = '';

  constructor(key: string, label: string, passed: boolean, statusText: string, helpTitle: string, helpText: string) {
    this.key = key;
    this.label = label;
    this.passed = passed;
    this.statusText = statusText;
    this.helpTitle = helpTitle;
    this.helpText = helpText;
  }
}

export class FormationIndicatorItem {
  key: string = '';
  label: string = '';
  valueText: string = '';
  helpTitle: string = '';
  helpText: string = '';

  constructor(key: string, label: string, valueText: string, helpTitle: string, helpText: string) {
    this.key = key;
    this.label = label;
    this.valueText = valueText;
    this.helpTitle = helpTitle;
    this.helpText = helpText;
  }
}

export class FormationFeasibilityResult {
  ok: boolean = false;
  feasible: boolean = false;
  message: string = '';
  summary: string = '';
  conditions: FormationConditionItem[] = [];
  indicators: FormationIndicatorItem[] = [];
  zeroEigenvectorTitle: string = '';
  zeroEigenvectorText: string = '';
  underlyingLaplacianTitle: string = '';
  underlyingLaplacianPreview: string = '';

  constructor(ok: boolean, feasible: boolean, message: string, summary: string, conditions: FormationConditionItem[],
    indicators: FormationIndicatorItem[], zeroEigenvectorTitle: string, zeroEigenvectorText: string, underlyingLaplacianTitle: string,
    underlyingLaplacianPreview: string) {
    this.ok = ok;
    this.feasible = feasible;
    this.message = message;
    this.summary = summary;
    this.conditions = conditions;
    this.indicators = indicators;
    this.zeroEigenvectorTitle = zeroEigenvectorTitle;
    this.zeroEigenvectorText = zeroEigenvectorText;
    this.underlyingLaplacianTitle = underlyingLaplacianTitle;
    this.underlyingLaplacianPreview = underlyingLaplacianPreview;
  }
}

class LaplacianValidationResult {
  underlying: DualQuaternion[][] = [];
  degreeCounts: number[] = [];

  constructor(underlying: DualQuaternion[][], degreeCounts: number[]) {
    this.underlying = underlying;
    this.degreeCounts = degreeCounts;
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

function sanitizeDisplayNumber(x: number): number {
  if (Math.abs(x) <= DISPLAY_ZERO_TOL) {
    return 0;
  }
  return x;
}

function quaternionConj(q: Quaternion): Quaternion {
  return new Quaternion(q.a, -q.b, -q.c, -q.d);
}

function isQuaternionApproxEqual(x: Quaternion, y: Quaternion, tol: number): boolean {
  return approxEqual(x.a, y.a, tol) && approxEqual(x.b, y.b, tol) && approxEqual(x.c, y.c, tol) && approxEqual(x.d, y.d, tol);
}

function quaternionMultiply(x: Quaternion, y: Quaternion): Quaternion {
  return new Quaternion(
    x.a * y.a - x.b * y.b - x.c * y.c - x.d * y.d,
    x.a * y.b + x.b * y.a + x.c * y.d - x.d * y.c,
    x.a * y.c - x.b * y.d + x.c * y.a + x.d * y.b,
    x.a * y.d + x.b * y.c - x.c * y.b + x.d * y.a
  );
}

function quaternionAdd(x: Quaternion, y: Quaternion): Quaternion {
  return new Quaternion(x.a + y.a, x.b + y.b, x.c + y.c, x.d + y.d);
}

function quaternionScale(q: Quaternion, k: number): Quaternion {
  return new Quaternion(q.a * k, q.b * k, q.c * k, q.d * k);
}

function quaternionNorm(q: Quaternion): number {
  return Math.sqrt(q.a * q.a + q.b * q.b + q.c * q.c + q.d * q.d);
}

function quaternionDot(x: Quaternion, y: Quaternion): number {
  return x.a * y.a + x.b * y.b + x.c * y.c + x.d * y.d;
}

function dualQuaternionConj(q: DualQuaternion): DualQuaternion {
  return new DualQuaternion(quaternionConj(q.primal), quaternionConj(q.dual));
}

function dualQuaternionAdd(x: DualQuaternion, y: DualQuaternion): DualQuaternion {
  return new DualQuaternion(quaternionAdd(x.primal, y.primal), quaternionAdd(x.dual, y.dual));
}

function dualQuaternionScale(q: DualQuaternion, k: number): DualQuaternion {
  return new DualQuaternion(quaternionScale(q.primal, k), quaternionScale(q.dual, k));
}

function dualQuaternionMultiply(x: DualQuaternion, y: DualQuaternion): DualQuaternion {
  const primal: Quaternion = quaternionMultiply(x.primal, y.primal);
  const dualLeft: Quaternion = quaternionMultiply(x.primal, y.dual);
  const dualRight: Quaternion = quaternionMultiply(x.dual, y.primal);
  return new DualQuaternion(primal, quaternionAdd(dualLeft, dualRight));
}

function dualQuaternionNegate(q: DualQuaternion): DualQuaternion {
  return dualQuaternionScale(q, -1);
}

function dualQuaternionIsZero(q: DualQuaternion, tol: number = EIGEN_TOL): boolean {
  return quaternionNorm(q.primal) <= tol && quaternionNorm(q.dual) <= tol;
}

function dualQuaternionMagnitude(q: DualQuaternion): DualScalar {
  const primalNorm: number = quaternionNorm(q.primal);
  if (primalNorm <= EIGEN_TOL) {
    return new DualScalar(0, quaternionNorm(q.dual));
  }
  const dualPart: number = quaternionDot(q.primal, q.dual) / primalNorm;
  return new DualScalar(primalNorm, dualPart);
}

function invertDualScalar(x: DualScalar): DualScalar {
  if (Math.abs(x.standard) <= EIGEN_TOL) {
    throw new Error('无法归一化零模长的对偶四元数分量');
  }
  return new DualScalar(1 / x.standard, -x.dual / (x.standard * x.standard));
}

function scaleQuaternionByDualScalar(q: DualQuaternion, s: DualScalar): DualQuaternion {
  const primal: Quaternion = quaternionScale(q.primal, s.standard);
  const dual: Quaternion = quaternionAdd(quaternionScale(q.primal, s.dual), quaternionScale(q.dual, s.standard));
  return new DualQuaternion(primal, dual);
}

function dualQuaternionNormalizeByMagnitude(q: DualQuaternion): DualQuaternion {
  return scaleQuaternionByDualScalar(q, invertDualScalar(dualQuaternionMagnitude(q)));
}

function dualQuaternionProductWithConjugate(q: DualQuaternion): DualQuaternion {
  return dualQuaternionMultiply(q, dualQuaternionConj(q));
}

function isUnitDualQuaternion(q: DualQuaternion, tol: number = 1e-6): boolean {
  const prod: DualQuaternion = dualQuaternionProductWithConjugate(q);
  return approxEqual(prod.primal.a, 1, tol) &&
    approxEqual(prod.primal.b, 0, tol) &&
    approxEqual(prod.primal.c, 0, tol) &&
    approxEqual(prod.primal.d, 0, tol) &&
    approxEqual(prod.dual.a, 0, tol) &&
    approxEqual(prod.dual.b, 0, tol) &&
    approxEqual(prod.dual.c, 0, tol) &&
    approxEqual(prod.dual.d, 0, tol);
}

function dualQuaternionFromReal(value: number): DualQuaternion {
  return new DualQuaternion(new Quaternion(value, 0, 0, 0), new Quaternion(0, 0, 0, 0));
}

function dualQuaternionFrNormEntrySquared(q: DualQuaternion): number {
  return quaternionDot(q.primal, q.primal) + quaternionDot(q.dual, q.dual);
}

function makeRealMatrix(rows: number, cols?: number): number[][] {
  const width: number = cols === undefined ? rows : cols;
  const m: number[][] = [];
  for (let i = 0; i < rows; i++) {
    const row: number[] = [];
    for (let j = 0; j < width; j++) {
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
  const rows: number = a.length;
  const cols: number = a[0].length;
  const t: number[][] = makeRealMatrix(cols, rows);
  for (let i = 0; i < cols; i++) {
    for (let j = 0; j < rows; j++) {
      t[i][j] = a[j][i];
    }
  }
  return t;
}

function multiply(a: number[][], b: number[][]): number[][] {
  const rows: number = a.length;
  const common: number = a[0].length;
  const cols: number = b[0].length;
  const out: number[][] = makeRealMatrix(rows, cols);
  for (let i = 0; i < rows; i++) {
    for (let j = 0; j < cols; j++) {
      let s: number = 0;
      for (let k = 0; k < common; k++) {
        s += a[i][k] * b[k][j];
      }
      out[i][j] = s;
    }
  }
  return out;
}

function identity(n: number): number[][] {
  const out: number[][] = makeRealMatrix(n);
  for (let i = 0; i < n; i++) {
    out[i][i] = 1;
  }
  return out;
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
  return Math.max(EIGEN_TOL, maxAbs * 1e-7);
}

function columnsOf(a: number[][], idx: number[]): number[][] {
  const rows: number = a.length;
  const out: number[][] = makeRealMatrix(rows, idx.length);
  for (let i = 0; i < rows; i++) {
    for (let j = 0; j < idx.length; j++) {
      out[i][j] = a[i][idx[j]];
    }
  }
  return out;
}

function realEmbeddingOfQuaternionHermitian(matrix: Quaternion[][]): number[][] {
  const complexAdj: Complex[][] = quaternionHermitianToComplexAdjoint(matrix);
  return complexHermitianToRealSymmetric(complexAdj);
}

function formatNumber(x: number): string {
  const y: number = sanitizeDisplayNumber(x);
  if (y === 0 || isNegativeZero(y)) {
    return '0';
  }
  let text: string = y.toFixed(DISPLAY_DECIMALS);
  while (text.includes('.') && text.endsWith('0')) {
    text = text.substring(0, text.length - 1);
  }
  if (text.endsWith('.')) {
    text = text.substring(0, text.length - 1);
  }
  if (text === '-0') {
    return '0';
  }
  return text;
}

function average(values: number[]): number {
  if (values.length === 0) {
    return 0;
  }
  let s: number = 0;
  for (let i = 0; i < values.length; i++) {
    s += values[i];
  }
  return s / values.length;
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
    qVec.push(new Quaternion(sanitizeDisplayNumber(alphaRe), sanitizeDisplayNumber(alphaIm),
      sanitizeDisplayNumber(betaRe), sanitizeDisplayNumber(betaIm)));
  }
  return qVec;
}

function formatSigned(x: number): string {
  const y: number = sanitizeDisplayNumber(x);
  const s: string = formatNumber(y);
  return y >= 0 ? `+${s}` : s;
}

function formatQuaternion(q: Quaternion): string {
  const a: string = formatNumber(q.a);
  const b: string = formatSigned(q.b);
  const c: string = formatSigned(q.c);
  const d: string = formatSigned(q.d);
  return `${a}${b}i${c}j${d}k`;
}

function formatDualEigenvalue(lambdaS: number, lambdaD: number): string {
  const standard: string = formatNumber(lambdaS);
  const dualAbs: string = formatNumber(Math.abs(lambdaD));
  const op: string = sanitizeDisplayNumber(lambdaD) >= 0 ? '+' : '-';
  return `${standard} ${op} ${dualAbs}·ε`;
}

function formatDualQuaternionVectorLines(primalVec: Quaternion[], dualVec: Quaternion[]): string[] {
  const lines: string[] = [];
  for (let i = 0; i < primalVec.length; i++) {
    const p: Quaternion = primalVec[i];
    const d: Quaternion = i < dualVec.length ? dualVec[i] : new Quaternion();
    lines.push(`x[${i + 1}] = (${formatQuaternion(p)}) + (${formatQuaternion(d)})·ε`);
  }
  return lines;
}

function formatDualQuaternion(q: DualQuaternion): string {
  return `(${formatQuaternion(q.primal)}) + (${formatQuaternion(q.dual)})·ε`;
}

function formatDualQuaternionMatrix(matrix: DualQuaternion[][]): string {
  const lines: string[] = [];
  for (let i = 0; i < matrix.length; i++) {
    const cols: string[] = [];
    for (let j = 0; j < matrix[i].length; j++) {
      cols.push(formatDualQuaternion(matrix[i][j]));
    }
    lines.push(cols.join('    '));
  }
  return lines.join('\n');
}

function makeDualQuaternionZeroMatrix(n: number): DualQuaternion[][] {
  const out: DualQuaternion[][] = [];
  for (let i = 0; i < n; i++) {
    const row: DualQuaternion[] = [];
    for (let j = 0; j < n; j++) {
      row.push(dualQuaternionFromReal(0));
    }
    out.push(row);
  }
  return out;
}

function dualQuaternionMatrixConjugateTranspose(matrix: DualQuaternion[][]): DualQuaternion[][] {
  const n: number = matrix.length;
  const out: DualQuaternion[][] = makeDualQuaternionZeroMatrix(n);
  for (let i = 0; i < n; i++) {
    for (let j = 0; j < n; j++) {
      out[j][i] = dualQuaternionConj(matrix[i][j]);
    }
  }
  return out;
}

function dualQuaternionMatrixMultiply(a: DualQuaternion[][], b: DualQuaternion[][]): DualQuaternion[][] {
  const n: number = a.length;
  const m: number = b[0].length;
  const common: number = b.length;
  const out: DualQuaternion[][] = [];
  for (let i = 0; i < n; i++) {
    const row: DualQuaternion[] = [];
    for (let j = 0; j < m; j++) {
      let sum: DualQuaternion = dualQuaternionFromReal(0);
      for (let k = 0; k < common; k++) {
        sum = dualQuaternionAdd(sum, dualQuaternionMultiply(a[i][k], b[k][j]));
      }
      row.push(sum);
    }
    out.push(row);
  }
  return out;
}

function dualQuaternionDiagonalMatrix(diagonal: DualQuaternion[]): DualQuaternion[][] {
  const n: number = diagonal.length;
  const out: DualQuaternion[][] = makeDualQuaternionZeroMatrix(n);
  for (let i = 0; i < n; i++) {
    out[i][i] = diagonal[i];
  }
  return out;
}

function dualQuaternionMatrixDiffFrNorm(a: DualQuaternion[][], b: DualQuaternion[][]): number {
  let sum: number = 0;
  for (let i = 0; i < a.length; i++) {
    for (let j = 0; j < a[i].length; j++) {
      const diff: DualQuaternion = dualQuaternionAdd(a[i][j], dualQuaternionNegate(b[i][j]));
      sum += dualQuaternionFrNormEntrySquared(diff);
    }
  }
  return Math.sqrt(sum);
}

function vectorDot(a: number[], b: number[]): number {
  let s: number = 0;
  for (let i = 0; i < a.length; i++) {
    s += a[i] * b[i];
  }
  return s;
}

function vectorMaxAbs(a: number[]): number {
  let maxVal: number = 0;
  for (let i = 0; i < a.length; i++) {
    const v: number = Math.abs(a[i]);
    if (v > maxVal) {
      maxVal = v;
    }
  }
  return maxVal;
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

function multiplyMatrixVector(a: number[][], x: number[]): number[] {
  return matVecMul(a, x);
}

function vectorSubtract(a: number[], b: number[]): number[] {
  const out: number[] = [];
  for (let i = 0; i < a.length; i++) {
    out.push(a[i] - b[i]);
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

function matrixSubtractLambdaIdentity(a: number[][], lambda: number): number[][] {
  const n: number = a.length;
  const out: number[][] = makeRealMatrix(n);
  for (let i = 0; i < n; i++) {
    for (let j = 0; j < n; j++) {
      out[i][j] = a[i][j] - (i === j ? lambda : 0);
    }
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
      throw new Error('线性系统求解失败：矩阵接近奇异');
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

function solveFullColumnRankLeastSquares(a: number[][], b: number[]): number[] {
  const at: number[][] = transpose(a);
  const ata: number[][] = multiply(at, a);
  const atb: number[] = matVecMul(at, b);
  for (let i = 0; i < ata.length; i++) {
    ata[i][i] += 1e-12;
  }
  return solveLinearSystem(ata, atb);
}

function collapseEigenBlocks(values: number[], vectors: number[][], tol: number): CollapsedEigenBlock[] {
  const groups: number[][] = clusterByGap(values, tol);
  const blocks: CollapsedEigenBlock[] = [];
  for (let gi = 0; gi < groups.length; gi++) {
    const idx: number[] = groups[gi];
    if (idx.length % 4 !== 0) {
      throw new Error(`特征值簇维度异常：第 ${gi + 1} 组维度为 ${idx.length}，不是 4 的倍数`);
    }
    const repCount: number = idx.length / 4;
    const groupValues: number[] = [];
    const reps: number[] = [];
    for (let t = 0; t < repCount; t++) {
      const block: number[] = [];
      for (let j = 0; j < 4; j++) {
        const col: number = idx[t * 4 + j];
        block.push(values[col]);
      }
      groupValues.push(average(block));
      reps.push(idx[t * 4]);
    }
    blocks.push(new CollapsedEigenBlock(average(groupValues), reps));
  }
  return blocks;
}

function solveDualPartRealVector(realAs: number[][], realAd: number[][], lambdaS: number, lambdaD: number, primalVec: number[],
  eigenspaceBasis: number[][]): number[] {
  const kMat: number[][] = matrixSubtractLambdaIdentity(realAs, lambdaS);
  const rhs: number[] = vectorSubtract(vectorScale(primalVec, lambdaD), matVecMul(realAd, primalVec));
  const basisT: number[][] = transpose(eigenspaceBasis);
  const augRows: number = kMat.length + basisT.length;
  const augA: number[][] = makeRealMatrix(augRows, kMat.length);
  const augB: number[] = [];

  for (let i = 0; i < kMat.length; i++) {
    for (let j = 0; j < kMat.length; j++) {
      augA[i][j] = kMat[i][j];
    }
    augB.push(rhs[i]);
  }
  for (let i = 0; i < basisT.length; i++) {
    for (let j = 0; j < basisT[i].length; j++) {
      augA[kMat.length + i][j] = basisT[i][j];
    }
    augB.push(0);
  }

  return solveFullColumnRankLeastSquares(augA, augB);
}

function standardResidual(realAs: number[][], lambdaS: number, primalVec: number[]): number {
  const lhs: number[] = matVecMul(realAs, primalVec);
  const rhs: number[] = vectorScale(primalVec, lambdaS);
  return vectorMaxAbs(vectorSubtract(lhs, rhs));
}

function dualResidual(realAs: number[][], realAd: number[][], lambdaS: number, lambdaD: number, primalVec: number[], dualVec: number[]): number {
  const lhs: number[] = matVecMul(matrixSubtractLambdaIdentity(realAs, lambdaS), dualVec);
  const rhs: number[] = vectorSubtract(vectorScale(primalVec, lambdaD), matVecMul(realAd, primalVec));
  return vectorMaxAbs(vectorSubtract(lhs, rhs));
}

function validateResiduals(pair: EigenPair, index: number): void {
  if (pair.residualStandard > RESIDUAL_TOL) {
    throw new Error(`第 ${index + 1} 个特征向量标准部残差过大：${pair.residualStandard}`);
  }
  if (pair.residualDual > RESIDUAL_TOL) {
    throw new Error(`第 ${index + 1} 个特征向量对偶部残差过大：${pair.residualDual}`);
  }
}

function quaternionVectorComponents(vec: Quaternion[]): number[][] {
  const out: number[][] = [];
  for (let i = 0; i < vec.length; i++) {
    out.push([vec[i].a, vec[i].b, vec[i].c, vec[i].d]);
  }
  return out;
}

function toDisplayItem(pair: EigenPair, index: number): EigenDisplayItem {
  const lambdaSText: string = formatNumber(pair.lambdaS);
  const lambdaDText: string = formatNumber(pair.lambdaD);
  const lambdaText: string = formatDualEigenvalue(pair.lambdaS, pair.lambdaD);
  const vectorLines: string[] = formatDualQuaternionVectorLines(pair.primalQuaternion, pair.dualQuaternion);
  return new EigenDisplayItem(index + 1, pair.lambdaS, pair.lambdaD, lambdaSText, lambdaDText, lambdaText, `特征向量 v${index + 1}`, vectorLines,
    pair.residualStandard, pair.residualDual, quaternionVectorComponents(pair.primalQuaternion), quaternionVectorComponents(pair.dualQuaternion));
}

function pairCompare(a: EigenPair, b: EigenPair): number {
  if (!approxEqual(a.lambdaS, b.lambdaS, 1e-8)) {
    return a.lambdaS - b.lambdaS;
  }
  if (!approxEqual(a.lambdaD, b.lambdaD, 1e-8)) {
    return a.lambdaD - b.lambdaD;
  }
  return a.residualDual - b.residualDual;
}

function dualPartsBySupplement(realAs: number[][], realAd: number[][]): SupplementSolveResult {
  const eigAs: EigDecomp = jacobiEigenSymmetric(realAs);
  const standardTol: number = estimateTolerance(eigAs.values);
  const standardGroups: number[][] = clusterByGap(eigAs.values, standardTol);
  if (realAs.length % 4 !== 0) {
    throw new Error(`实嵌入维度异常：${realAs.length} 不是 4 的倍数`);
  }
  const n: number = Math.floor(realAs.length / 4);
  const pairs: EigenPair[] = [];

  for (let gi = 0; gi < standardGroups.length; gi++) {
    const idx: number[] = standardGroups[gi];
    if (idx.length % 4 !== 0) {
      throw new Error(`标准部重根维度异常：第 ${gi + 1} 组维度为 ${idx.length}，不是 4 的倍数`);
    }
    const lambdaSBlock: number = average(idx.map((col: number) => eigAs.values[col]));
    const u: number[][] = columnsOf(eigAs.vectors, idx);
    const ut: number[][] = transpose(u);
    const sMat: number[][] = multiply(multiply(ut, realAd), u);
    const sEig: EigDecomp = jacobiEigenSymmetric(sMat);
    const dualBlocks: CollapsedEigenBlock[] = collapseEigenBlocks(sEig.values, sEig.vectors, estimateTolerance(sEig.values));

    for (let bi = 0; bi < dualBlocks.length; bi++) {
      const block = dualBlocks[bi];
      for (let ri = 0; ri < block.reps.length; ri++) {
        const yReal: number[] = columnVector(sEig.vectors, block.reps[ri]);
        const xSReal: number[] = multiplyMatrixVector(u, yReal);
        const xDReal: number[] = solveDualPartRealVector(realAs, realAd, lambdaSBlock, block.lambda, xSReal, u);
        const primalQuaternion: Quaternion[] = realVectorToQuaternionEigenvector(xSReal, n);
        const dualQuaternion: Quaternion[] = realVectorToQuaternionEigenvector(xDReal, n);
        const pair: EigenPair = new EigenPair(lambdaSBlock, block.lambda, xSReal, xDReal, primalQuaternion, dualQuaternion,
          standardResidual(realAs, lambdaSBlock, xSReal), dualResidual(realAs, realAd, lambdaSBlock, block.lambda, xSReal, xDReal));
        pairs.push(pair);
      }
    }
  }

  pairs.sort(pairCompare);
  return new SupplementSolveResult(pairs);
}

export function solveDualQuaternionHermitianEigenvalues(matrixText: string, n: number): EigenSolveResult {
  try {
    if (n < 2 || n > 8) {
      return new EigenSolveResult(false, 'n 必须在 2 到 8 之间', [], [], []);
    }

    const dualQ: DualQuaternion[][] = parseDualQuaternionMatrix(matrixText, n);
    validateDualQuaternionHermitian(dualQ);
    const split: SplitResult = splitStandardAndDual(dualQ);
    const rs: number[][] = realEmbeddingOfQuaternionHermitian(split.standard);
    const rd: number[][] = realEmbeddingOfQuaternionHermitian(split.dual);
    const ans: SupplementSolveResult = dualPartsBySupplement(rs, rd);

    if (ans.pairs.length !== n) {
      return new EigenSolveResult(false, `求解结果维度异常：特征对数量 ${ans.pairs.length}，应为 ${n}`, [], [], []);
    }

    for (let i = 0; i < ans.pairs.length; i++) {
      validateResiduals(ans.pairs[i], i);
    }

    const items: EigenDisplayItem[] = [];
    const values: string[] = [];
    const vectors: string[] = [];
    for (let i = 0; i < ans.pairs.length; i++) {
      const item: EigenDisplayItem = toDisplayItem(ans.pairs[i], i);
      items.push(item);
      values.push(item.lambdaText);
      vectors.push(item.vectorText);
    }
    return new EigenSolveResult(true, 'ok', values, vectors, items);
  } catch (e) {
    return new EigenSolveResult(false, `${e}`, [], [], []);
  }
}

function pairIsZero(pair: EigenPair, tol: number): boolean {
  return Math.abs(pair.lambdaS) <= tol && Math.abs(pair.lambdaD) <= tol;
}

function pairToDualQuaternionVector(pair: EigenPair): DualQuaternion[] {
  const out: DualQuaternion[] = [];
  for (let i = 0; i < pair.primalQuaternion.length; i++) {
    out.push(new DualQuaternion(pair.primalQuaternion[i], pair.dualQuaternion[i]));
  }
  return out;
}

function buildUnderlyingGraphLaplacian(degreeCounts: number[], adjacencyMask: boolean[][]): DualQuaternion[][] {
  const n: number = degreeCounts.length;
  const out: DualQuaternion[][] = makeDualQuaternionZeroMatrix(n);
  for (let i = 0; i < n; i++) {
    out[i][i] = dualQuaternionFromReal(degreeCounts[i]);
    for (let j = 0; j < n; j++) {
      if (i !== j && adjacencyMask[i][j]) {
        out[i][j] = dualQuaternionFromReal(-1);
      }
    }
  }
  return out;
}

function validateDualQuaternionLaplacian(matrix: DualQuaternion[][], tol: number = 1e-6): LaplacianValidationResult {
  validateDualQuaternionHermitian(matrix, tol);
  const n: number = matrix.length;
  const adjacencyMask: boolean[][] = [];
  const degreeCounts: number[] = [];

  for (let i = 0; i < n; i++) {
    const rowMask: boolean[] = [];
    let degree: number = 0;
    for (let j = 0; j < n; j++) {
      if (i === j) {
        rowMask.push(false);
        continue;
      }
      const entry: DualQuaternion = matrix[i][j];
      const hasEdge: boolean = !dualQuaternionIsZero(entry, tol);
      rowMask.push(hasEdge);
      if (hasEdge) {
        if (!isUnitDualQuaternion(entry, tol)) {
          throw new Error(`拉普拉斯矩阵非法：第 (${i + 1},${j + 1}) 个非对角元不是单位对偶四元数的相反数`);
        }
        degree++;
      }
    }
    adjacencyMask.push(rowMask);
    degreeCounts.push(degree);
  }

  for (let i = 0; i < n; i++) {
    const diagonal: DualQuaternion = matrix[i][i];
    if (!approxEqual(diagonal.primal.a, degreeCounts[i], tol)) {
      throw new Error(`拉普拉斯矩阵非法：第 ${i + 1} 个对角元应等于节点度数 ${degreeCounts[i]}`);
    }
    if (!approxEqual(diagonal.dual.a, 0, tol)) {
      throw new Error(`拉普拉斯矩阵非法：第 ${i + 1} 个对角元的对偶部应为 0`);
    }
    if (diagonal.primal.a < -tol) {
      throw new Error(`拉普拉斯矩阵非法：第 ${i + 1} 个对角元不能为负`);
    }
  }

  return new LaplacianValidationResult(buildUnderlyingGraphLaplacian(degreeCounts, adjacencyMask), degreeCounts);
}

function dualScalarApproxEqual(x: DualScalar, y: DualScalar, tol: number = 1e-5): boolean {
  return approxEqual(x.standard, y.standard, tol) && approxEqual(x.dual, y.dual, tol);
}

function dualScalarText(x: DualScalar): string {
  const op: string = sanitizeDisplayNumber(x.dual) >= 0 ? '+' : '-';
  return `${formatNumber(x.standard)} ${op} ${formatNumber(Math.abs(x.dual))}·ε`;
}

function buildMetricHelpTitle(label: string): string {
  return `${label}说明`;
}

function makeConditionItem(key: string, label: string, passed: boolean, helpText: string): FormationConditionItem {
  return new FormationConditionItem(key, label, passed, passed ? '通过' : '未通过', buildMetricHelpTitle(label), helpText);
}

function makeIndicatorItem(key: string, label: string, valueText: string, helpText: string): FormationIndicatorItem {
  return new FormationIndicatorItem(key, label, valueText, buildMetricHelpTitle(label), helpText);
}

function evaluateCondition2(zeroVector: DualQuaternion[], tol: number): boolean {
  if (zeroVector.length === 0) {
    return false;
  }
  const firstMagnitude: DualScalar = dualQuaternionMagnitude(zeroVector[0]);
  if (Math.abs(firstMagnitude.standard) <= tol) {
    return false;
  }
  for (let i = 1; i < zeroVector.length; i++) {
    const current: DualScalar = dualQuaternionMagnitude(zeroVector[i]);
    if (Math.abs(current.standard) <= tol || !dualScalarApproxEqual(firstMagnitude, current, tol)) {
      return false;
    }
  }
  return true;
}

function buildSwitchingDiagonal(zeroVector: DualQuaternion[]): DualQuaternion[] {
  const diagonal: DualQuaternion[] = [];
  for (let i = 0; i < zeroVector.length; i++) {
    diagonal.push(dualQuaternionNormalizeByMagnitude(zeroVector[i]));
  }
  return diagonal;
}

function findZeroPairIndex(pairs: EigenPair[], tol: number): number {
  for (let i = 0; i < pairs.length; i++) {
    if (pairIsZero(pairs[i], tol)) {
      return i;
    }
  }
  return -1;
}

export function evaluateDualQuaternionFormationFeasibility(matrixText: string, n: number): FormationFeasibilityResult {
  try {
    if (n < 2 || n > 8) {
      return new FormationFeasibilityResult(false, false, 'n 必须在 2 到 8 之间', '', [], [], '', '', '', '');
    }

    const matrix: DualQuaternion[][] = parseDualQuaternionMatrix(matrixText, n);
    const validation: LaplacianValidationResult = validateDualQuaternionLaplacian(matrix);
    const split: SplitResult = splitStandardAndDual(matrix);
    const rs: number[][] = realEmbeddingOfQuaternionHermitian(split.standard);
    const rd: number[][] = realEmbeddingOfQuaternionHermitian(split.dual);
    const solveResult: SupplementSolveResult = dualPartsBySupplement(rs, rd);
    const pairs: EigenPair[] = solveResult.pairs;

    if (pairs.length !== n) {
      return new FormationFeasibilityResult(false, false, `判定失败：谱分解返回 ${pairs.length} 个特征对，预期应为 ${n}`, '', [], [], '', '', '', '');
    }

    for (let i = 0; i < pairs.length; i++) {
      validateResiduals(pairs[i], i);
    }

    const tol: number = 1e-6;
    let zeroEigenCount: number = 0;
    for (let i = 0; i < pairs.length; i++) {
      if (pairIsZero(pairs[i], tol)) {
        zeroEigenCount++;
      }
    }

    const lambdaMinPair: EigenPair = pairs[0];
    const lambda2Pair: EigenPair = pairs.length > 1 ? pairs[1] : pairs[0];
    const zeroPairIndex: number = findZeroPairIndex(pairs, tol);
    const zeroVector: DualQuaternion[] = zeroPairIndex < 0 ? [] : pairToDualQuaternionVector(pairs[zeroPairIndex]);

    const condition1Ok: boolean = zeroEigenCount === 1 && pairIsZero(lambdaMinPair, tol);
    const condition2Ok: boolean = condition1Ok && evaluateCondition2(zeroVector, tol);

    let err: number = Number.POSITIVE_INFINITY;
    let condition3Ok: boolean = false;
    if (condition2Ok) {
      const yDiagonal: DualQuaternion[] = buildSwitchingDiagonal(zeroVector);
      const yMatrix: DualQuaternion[][] = dualQuaternionDiagonalMatrix(yDiagonal);
      const switched: DualQuaternion[][] = dualQuaternionMatrixMultiply(
        dualQuaternionMatrixMultiply(dualQuaternionMatrixConjugateTranspose(yMatrix), matrix),
        yMatrix
      );
      err = dualQuaternionMatrixDiffFrNorm(switched, validation.underlying);
      condition3Ok = err <= 1e-8;
    }

    const feasible: boolean = condition1Ok && condition2Ok && condition3Ok;
    const conditions: FormationConditionItem[] = [];
    conditions.push(makeConditionItem(
      'condition1',
      '条件 (i)：零特征值简单且最小',
      condition1Ok,
      '这条条件检查拉普拉斯矩阵是否恰好只有一个零特征值，并且它位于谱的最小端。若不成立，连通图版 Corollary 6.3 无法判为可行。'
    ));
    conditions.push(makeConditionItem(
      'condition2',
      '条件 (ii)：零特征向量模长一致',
      condition2Ok,
      '这条条件要求零特征向量每个节点分量的模长一致。它反映了是否能从该特征向量中恢复统一尺度下的目标构型相位/姿态信息。'
    ));
    conditions.push(makeConditionItem(
      'condition3',
      '条件 (iii)：切换后等于底层图 Laplacian',
      condition3Ok,
      '这条条件检查用零特征向量构造的切换矩阵 Y 后，Y*LY 是否与底层无增益图的拉普拉斯矩阵一致。它是最终确认图平衡、从而确认构型可行的关键条件。'
    ));

    const indicators: FormationIndicatorItem[] = [];
    indicators.push(makeIndicatorItem(
      'feasible',
      '可行性判定',
      feasible ? '可行' : '不可行',
      '这里给出论文连通图版 Corollary 6.3 的最终结论。只有三条条件同时成立时，目标相对构型才判为可行。'
    ));
    indicators.push(makeIndicatorItem(
      'zeroEigenCount',
      '零特征值重数',
      `${zeroEigenCount}`,
      '零特征值重数反映图的零空间维数。对连通图版判定来说，它应当等于 1。'
    ));
    indicators.push(makeIndicatorItem(
      'lambdaMin',
      '最小特征值',
      formatDualEigenvalue(lambdaMinPair.lambdaS, lambdaMinPair.lambdaD),
      '最小特征值用于检查谱的起点是否为 0。若最小特征值不是 0，则条件 (i) 直接失败。'
    ));
    indicators.push(makeIndicatorItem(
      'lambda2',
      '第二小特征值 λ2',
      formatDualEigenvalue(lambda2Pair.lambdaS, lambda2Pair.lambdaD),
      '第二小特征值 λ2 用来辅助理解零特征值之后的谱结构。对平衡连通图，它应位于零特征值之后并对应正谱部分。'
    ));
    const errText: string = err < 1e99 ? formatNumber(err) : '未计算';
    indicators.push(makeIndicatorItem(
      'err',
      '误差 Err',
      errText,
      '误差 Err 定义为 ||Y*LY - L(0)||_FR。它越接近 0，说明切换后的矩阵越接近底层图 Laplacian。'
    ));

    const zeroEigenvectorTitle: string = '零特征向量';
    const zeroEigenvectorText: string = zeroPairIndex < 0 ? '未找到零特征值对应的特征向量。' :
      formatDualQuaternionVectorLines(pairs[zeroPairIndex].primalQuaternion, pairs[zeroPairIndex].dualQuaternion).join('\n');
    const summary: string = feasible ? '满足论文 Corollary 6.3 的三项条件，该目标相对构型可行。' :
      '未满足论文 Corollary 6.3 的全部条件，该目标相对构型当前不能判为可行。';

    return new FormationFeasibilityResult(
      true,
      feasible,
      feasible ? 'ok' : '判定完成，但未通过全部论文条件',
      summary,
      conditions,
      indicators,
      zeroEigenvectorTitle,
      zeroEigenvectorText,
      '底层图 Laplacian L(0)',
      formatDualQuaternionMatrix(validation.underlying)
    );
  } catch (e) {
    return new FormationFeasibilityResult(false, false, `${e}`, '', [], [], '', '', '', '');
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
