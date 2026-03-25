const EIGEN_HISTORY_KEY: string = 'eigen_history';
const FEASIBILITY_HISTORY_KEY: string = 'feasibility_history';
const MAX_HISTORY_COUNT: number = 10;

let historyStorageInitialized: boolean = false;

export class EigenHistoryItem {
  id: string = '';
  timestamp: string = '';
  n: number = 2;
  matrixText: string = '';
  resultSummary: string = '';
  eigenCount: number = 0;
  topEigenText: string = '';

  constructor(id: string = '', timestamp: string = '', n: number = 2, matrixText: string = '', resultSummary: string = '',
    eigenCount: number = 0, topEigenText: string = '') {
    this.id = id;
    this.timestamp = timestamp;
    this.n = n;
    this.matrixText = matrixText;
    this.resultSummary = resultSummary;
    this.eigenCount = eigenCount;
    this.topEigenText = topEigenText;
  }
}

export class FeasibilityHistoryItem {
  id: string = '';
  timestamp: string = '';
  n: number = 2;
  matrixText: string = '';
  feasible: boolean = false;
  summary: string = '';
  conditionFlags: string = '';
  errText: string = '';

  constructor(id: string = '', timestamp: string = '', n: number = 2, matrixText: string = '', feasible: boolean = false,
    summary: string = '', conditionFlags: string = '', errText: string = '') {
    this.id = id;
    this.timestamp = timestamp;
    this.n = n;
    this.matrixText = matrixText;
    this.feasible = feasible;
    this.summary = summary;
    this.conditionFlags = conditionFlags;
    this.errText = errText;
  }
}

function ensureHistoryStorage() {
  if (historyStorageInitialized) {
    return;
  }
  PersistentStorage.persistProp(EIGEN_HISTORY_KEY, '');
  PersistentStorage.persistProp(FEASIBILITY_HISTORY_KEY, '');
  historyStorageInitialized = true;
}

function encodeField(value: string): string {
  return encodeURIComponent(value);
}

function decodeField(value: string): string {
  try {
    return decodeURIComponent(value);
  } catch (err) {
    return '';
  }
}

function readRaw(key: string): string {
  ensureHistoryStorage();
  const value: string | undefined = AppStorage.get<string>(key);
  if (typeof value === 'string') {
    return value;
  }
  return '';
}

function writeRaw(key: string, value: string) {
  ensureHistoryStorage();
  AppStorage.setOrCreate(key, value);
}

function trimLines(lines: string[]): string[] {
  const next: string[] = [];
  for (let i = 0; i < lines.length && i < MAX_HISTORY_COUNT; i++) {
    if (lines[i].trim().length > 0) {
      next.push(lines[i]);
    }
  }
  return next;
}

export function initHistoryStorage() {
  ensureHistoryStorage();
}

export function loadEigenHistory(): EigenHistoryItem[] {
  const raw: string = readRaw(EIGEN_HISTORY_KEY);
  const lines: string[] = raw.length === 0 ? [] : raw.split('\n');
  const items: EigenHistoryItem[] = [];
  for (let i = 0; i < lines.length; i++) {
    const line: string = lines[i].trim();
    if (line.length === 0) {
      continue;
    }
    const fields: string[] = line.split('\t');
    if (fields.length < 7) {
      continue;
    }
    items.push(
      new EigenHistoryItem(
        decodeField(fields[0]),
        decodeField(fields[1]),
        Number(fields[2]),
        decodeField(fields[3]),
        decodeField(fields[4]),
        Number(fields[5]),
        decodeField(fields[6])
      )
    );
  }
  return items;
}

export function saveEigenHistory(item: EigenHistoryItem): EigenHistoryItem[] {
  const existing: EigenHistoryItem[] = loadEigenHistory();
  const lines: string[] = [];
  lines.push(
    `${encodeField(item.id)}\t${encodeField(item.timestamp)}\t${item.n}\t${encodeField(item.matrixText)}\t` +
    `${encodeField(item.resultSummary)}\t${item.eigenCount}\t${encodeField(item.topEigenText)}`
  );
  for (let i = 0; i < existing.length && lines.length < MAX_HISTORY_COUNT; i++) {
    const current: EigenHistoryItem = existing[i];
    if (current.id === item.id) {
      continue;
    }
    lines.push(
      `${encodeField(current.id)}\t${encodeField(current.timestamp)}\t${current.n}\t${encodeField(current.matrixText)}\t` +
      `${encodeField(current.resultSummary)}\t${current.eigenCount}\t${encodeField(current.topEigenText)}`
    );
  }
  writeRaw(EIGEN_HISTORY_KEY, trimLines(lines).join('\n'));
  return loadEigenHistory();
}

export function loadFeasibilityHistory(): FeasibilityHistoryItem[] {
  const raw: string = readRaw(FEASIBILITY_HISTORY_KEY);
  const lines: string[] = raw.length === 0 ? [] : raw.split('\n');
  const items: FeasibilityHistoryItem[] = [];
  for (let i = 0; i < lines.length; i++) {
    const line: string = lines[i].trim();
    if (line.length === 0) {
      continue;
    }
    const fields: string[] = line.split('\t');
    if (fields.length < 8) {
      continue;
    }
    items.push(
      new FeasibilityHistoryItem(
        decodeField(fields[0]),
        decodeField(fields[1]),
        Number(fields[2]),
        decodeField(fields[3]),
        fields[4] === '1',
        decodeField(fields[5]),
        decodeField(fields[6]),
        decodeField(fields[7])
      )
    );
  }
  return items;
}

export function saveFeasibilityHistory(item: FeasibilityHistoryItem): FeasibilityHistoryItem[] {
  const existing: FeasibilityHistoryItem[] = loadFeasibilityHistory();
  const lines: string[] = [];
  lines.push(
    `${encodeField(item.id)}\t${encodeField(item.timestamp)}\t${item.n}\t${encodeField(item.matrixText)}\t` +
    `${item.feasible ? '1' : '0'}\t${encodeField(item.summary)}\t${encodeField(item.conditionFlags)}\t${encodeField(item.errText)}`
  );
  for (let i = 0; i < existing.length && lines.length < MAX_HISTORY_COUNT; i++) {
    const current: FeasibilityHistoryItem = existing[i];
    if (current.id === item.id) {
      continue;
    }
    lines.push(
      `${encodeField(current.id)}\t${encodeField(current.timestamp)}\t${current.n}\t${encodeField(current.matrixText)}\t` +
      `${current.feasible ? '1' : '0'}\t${encodeField(current.summary)}\t${encodeField(current.conditionFlags)}\t${encodeField(current.errText)}`
    );
  }
  writeRaw(FEASIBILITY_HISTORY_KEY, trimLines(lines).join('\n'));
  return loadFeasibilityHistory();
}
