export class MatrixGridData {
  qa: string[][] = [];
  qb: string[][] = [];
  qc: string[][] = [];
  qd: string[][] = [];
  ea: string[][] = [];
  eb: string[][] = [];
  ec: string[][] = [];
  ed: string[][] = [];
}

function randomInt(min: number, max: number): number {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function negateText(v: string): string {
  const t = v.trim();
  if (t.length === 0) {
    return '0';
  }
  if (t.startsWith('-')) {
    return t.substring(1);
  }
  return `-${t}`;
}

function toNumberText(v: string): string {
  const trimmed = v.trim();
  const value = Number(trimmed);
  if (Number.isNaN(value)) {
    return '0';
  }
  return `${value}`;
}

export function createFilledGrid(n: number, fill: string): string[][] {
  const grid: string[][] = [];
  for (let i = 0; i < n; i++) {
    const row: string[] = [];
    for (let j = 0; j < n; j++) {
      row.push(fill);
    }
    grid.push(row);
  }
  return grid;
}

function cloneGrid(source: string[][]): string[][] {
  const copy: string[][] = [];
  for (let i = 0; i < source.length; i++) {
    copy.push([...source[i]]);
  }
  return copy;
}

export function cloneMatrixGrid(data: MatrixGridData): MatrixGridData {
  const next: MatrixGridData = new MatrixGridData();
  next.qa = cloneGrid(data.qa);
  next.qb = cloneGrid(data.qb);
  next.qc = cloneGrid(data.qc);
  next.qd = cloneGrid(data.qd);
  next.ea = cloneGrid(data.ea);
  next.eb = cloneGrid(data.eb);
  next.ec = cloneGrid(data.ec);
  next.ed = cloneGrid(data.ed);
  return next;
}

export function createResetQuaternionGrid(n: number, diagonalValue: string): MatrixGridData {
  const data: MatrixGridData = new MatrixGridData();
  data.qa = createFilledGrid(n, '0');
  data.qb = createFilledGrid(n, '0');
  data.qc = createFilledGrid(n, '0');
  data.qd = createFilledGrid(n, '0');
  data.ea = createFilledGrid(n, '0');
  data.eb = createFilledGrid(n, '0');
  data.ec = createFilledGrid(n, '0');
  data.ed = createFilledGrid(n, '0');
  for (let i = 0; i < n; i++) {
    data.qa[i][i] = diagonalValue;
  }
  return data;
}

export function matrixTextFromGrid(data: MatrixGridData, n: number): string {
  const lines: string[] = [];
  for (let i = 0; i < n; i++) {
    const cols: string[] = [];
    for (let j = 0; j < n; j++) {
      cols.push(
        `${toNumberText(data.qa[i][j])},${toNumberText(data.qb[i][j])},${toNumberText(data.qc[i][j])},${toNumberText(data.qd[i][j])},` +
        `${toNumberText(data.ea[i][j])},${toNumberText(data.eb[i][j])},${toNumberText(data.ec[i][j])},${toNumberText(data.ed[i][j])}`
      );
    }
    lines.push(cols.join(';'));
  }
  return lines.join('\n');
}

export function applyMatrixTextToGrid(text: string, n: number): MatrixGridData | null {
  const lines: string[] = text.split(/\r?\n/).map((item: string) => item.trim()).filter((item: string) => item.length > 0);
  if (lines.length !== n) {
    return null;
  }

  const data: MatrixGridData = createResetQuaternionGrid(n, '0');
  for (let i = 0; i < n; i++) {
    const cols: string[] = lines[i].split(';').map((item: string) => item.trim());
    if (cols.length !== n) {
      return null;
    }
    for (let j = 0; j < n; j++) {
      const parts: string[] = cols[j].split(',').map((item: string) => item.trim());
      if (parts.length !== 8) {
        return null;
      }
      data.qa[i][j] = parts[0];
      data.qb[i][j] = parts[1];
      data.qc[i][j] = parts[2];
      data.qd[i][j] = parts[3];
      data.ea[i][j] = parts[4];
      data.eb[i][j] = parts[5];
      data.ec[i][j] = parts[6];
      data.ed[i][j] = parts[7];
    }
  }
  return data;
}

export function updateGridCell(data: MatrixGridData, i: number, j: number, component: number, value: string, isDual: boolean,
  allowDiagonalEdit: boolean = true): MatrixGridData {
  if (i > j) {
    return cloneMatrixGrid(data);
  }
  if (i === j && !allowDiagonalEdit && isDual) {
    return cloneMatrixGrid(data);
  }

  const next: MatrixGridData = cloneMatrixGrid(data);
  const v: string = value.trim().length === 0 ? '0' : value.trim();
  let aGrid: string[][];
  let bGrid: string[][];
  let cGrid: string[][];
  let dGrid: string[][];
  if (isDual) {
    aGrid = next.ea;
    bGrid = next.eb;
    cGrid = next.ec;
    dGrid = next.ed;
  } else {
    aGrid = next.qa;
    bGrid = next.qb;
    cGrid = next.qc;
    dGrid = next.qd;
  }

  if (component === 0) {
    aGrid[i][j] = v;
    aGrid[j][i] = v;
  } else if (component === 1) {
    const nv: string = i === j ? '0' : v;
    bGrid[i][j] = nv;
    bGrid[j][i] = i === j ? '0' : negateText(nv);
  } else if (component === 2) {
    const nv: string = i === j ? '0' : v;
    cGrid[i][j] = nv;
    cGrid[j][i] = i === j ? '0' : negateText(nv);
  } else {
    const nv: string = i === j ? '0' : v;
    dGrid[i][j] = nv;
    dGrid[j][i] = i === j ? '0' : negateText(nv);
  }
  return next;
}

export function createRandomHermitianGrid(n: number): MatrixGridData {
  const data: MatrixGridData = createResetQuaternionGrid(n, '0');
  for (let i = 0; i < n; i++) {
    data.qa[i][i] = `${randomInt(1, 8)}`;
    data.ea[i][i] = `${randomInt(-3, 3)}`;
    for (let j = i + 1; j < n; j++) {
      const pA: number = randomInt(-3, 3);
      const pB: number = randomInt(-3, 3);
      const pC: number = randomInt(-3, 3);
      const pD: number = randomInt(-3, 3);
      const dA: number = randomInt(-3, 3);
      const dB: number = randomInt(-3, 3);
      const dC: number = randomInt(-3, 3);
      const dD: number = randomInt(-3, 3);
      data.qa[i][j] = `${pA}`;
      data.qb[i][j] = `${pB}`;
      data.qc[i][j] = `${pC}`;
      data.qd[i][j] = `${pD}`;
      data.qa[j][i] = `${pA}`;
      data.qb[j][i] = `${-pB}`;
      data.qc[j][i] = `${-pC}`;
      data.qd[j][i] = `${-pD}`;
      data.ea[i][j] = `${dA}`;
      data.eb[i][j] = `${dB}`;
      data.ec[i][j] = `${dC}`;
      data.ed[i][j] = `${dD}`;
      data.ea[j][i] = `${dA}`;
      data.eb[j][i] = `${-dB}`;
      data.ec[j][i] = `${-dC}`;
      data.ed[j][i] = `${-dD}`;
    }
  }
  return data;
}

function isOffDiagonalNonZero(data: MatrixGridData, i: number, j: number): boolean {
  const parts: string[] = [
    data.qa[i][j], data.qb[i][j], data.qc[i][j], data.qd[i][j],
    data.ea[i][j], data.eb[i][j], data.ec[i][j], data.ed[i][j]
  ];
  for (let k = 0; k < parts.length; k++) {
    if (Math.abs(Number(parts[k])) > 1e-9) {
      return true;
    }
  }
  return false;
}

export function autoFillJudgeDegrees(data: MatrixGridData, n: number): MatrixGridData {
  const next: MatrixGridData = cloneMatrixGrid(data);
  for (let i = 0; i < n; i++) {
    let degree: number = 0;
    for (let j = 0; j < n; j++) {
      if (i !== j && isOffDiagonalNonZero(next, i, j)) {
        degree++;
      }
    }
    next.qa[i][i] = `${degree}`;
    next.qb[i][i] = '0';
    next.qc[i][i] = '0';
    next.qd[i][i] = '0';
    next.ea[i][i] = '0';
    next.eb[i][i] = '0';
    next.ec[i][i] = '0';
    next.ed[i][i] = '0';
  }
  return next;
}

function fillJudgeEdge(data: MatrixGridData, i: number, j: number) {
  const dualI: number = randomInt(-2, 2);
  const dualJ: number = randomInt(-2, 2);
  const dualK: number = randomInt(-2, 2);

  data.qa[i][j] = '-1';
  data.qb[i][j] = '0';
  data.qc[i][j] = '0';
  data.qd[i][j] = '0';
  data.ea[i][j] = '0';
  data.eb[i][j] = `${-dualI}`;
  data.ec[i][j] = `${-dualJ}`;
  data.ed[i][j] = `${-dualK}`;

  data.qa[j][i] = '-1';
  data.qb[j][i] = '0';
  data.qc[j][i] = '0';
  data.qd[j][i] = '0';
  data.ea[j][i] = '0';
  data.eb[j][i] = `${dualI}`;
  data.ec[j][i] = `${dualJ}`;
  data.ed[j][i] = `${dualK}`;
}

export function createBalancedJudgeExample(): MatrixGridData {
  const sample: string =
    '2,0,0,0,0,0,0,0;-1,0,0,0,0,-1,0,0;-1,0,0,0,0,0,0,0\n' +
    '-1,0,0,0,0,1,0,0;2,0,0,0,0,0,0,0;-1,0,0,0,0,1,0,0\n' +
    '-1,0,0,0,0,0,0,0;-1,0,0,0,0,-1,0,0;2,0,0,0,0,0,0,0';
  const data: MatrixGridData | null = applyMatrixTextToGrid(sample, 3);
  return data === null ? createResetQuaternionGrid(3, '0') : data;
}

export function createUnbalancedJudgeExample(): MatrixGridData {
  const sample: string =
    '2,0,0,0,0,0,0,0;-1,0,0,0,0,-1,0,0;-1,0,0,0,0,2,0,0\n' +
    '-1,0,0,0,0,1,0,0;2,0,0,0,0,0,0,0;-1,0,0,0,0,1,0,0\n' +
    '-1,0,0,0,0,-2,0,0;-1,0,0,0,0,-1,0,0;2,0,0,0,0,0,0,0';
  const data: MatrixGridData | null = applyMatrixTextToGrid(sample, 3);
  return data === null ? createResetQuaternionGrid(3, '0') : data;
}

export function createRandomJudgeGrid(n: number): MatrixGridData {
  const data: MatrixGridData = createResetQuaternionGrid(n, '0');
  for (let i = 0; i < n - 1; i++) {
    fillJudgeEdge(data, i, i + 1);
  }
  for (let i = 0; i < n; i++) {
    for (let j = i + 2; j < n; j++) {
      if (Math.random() < 0.45) {
        fillJudgeEdge(data, i, j);
      }
    }
  }
  return autoFillJudgeDegrees(data, n);
}

export function formatTimeText(epochMs: string): string {
  const value: number = Number(epochMs);
  if (Number.isNaN(value)) {
    return epochMs;
  }
  const date: Date = new Date(value);
  const year: number = date.getFullYear();
  const month: number = date.getMonth() + 1;
  const day: number = date.getDate();
  const hours: number = date.getHours();
  const minutes: number = date.getMinutes();
  const seconds: number = date.getSeconds();
  const pad = (num: number): string => num < 10 ? `0${num}` : `${num}`;
  return `${year}-${pad(month)}-${pad(day)} ${pad(hours)}:${pad(minutes)}:${pad(seconds)}`;
}
