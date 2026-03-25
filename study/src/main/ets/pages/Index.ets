import {
  EigenDisplayItem,
  FormationConditionItem,
  FormationIndicatorItem,
  evaluateDualQuaternionFormationFeasibility,
  solveDualQuaternionHermitianEigenvalues
} from '../utils/EigenSolver';

@Entry
@Component
struct Index {
  @State mode: number = 0;
  @State n: number = 2;
  @State matrixInput: string = '';
  @State eigenMessage: string = '请选择功能并点击计算';
  @State eigenItems: EigenDisplayItem[] = [];
  @State formationOk: boolean = true;
  @State formationFeasible: boolean = false;
  @State formationMessage: string = '请选择功能并点击判定';
  @State formationSummary: string = '';
  @State formationConditions: FormationConditionItem[] = [];
  @State formationIndicators: FormationIndicatorItem[] = [];
  @State zeroEigenvectorText: string = '';
  @State underlyingLaplacianText: string = '';
  @State showOverlay: boolean = false;
  @State overlayTitle: string = '';
  @State overlayText: string = '';
  @State qa: string[][] = [];
  @State qb: string[][] = [];
  @State qc: string[][] = [];
  @State qd: string[][] = [];
  @State ea: string[][] = [];
  @State eb: string[][] = [];
  @State ec: string[][] = [];
  @State ed: string[][] = [];

  aboutToAppear() {
    this.resetQuaternionGrid(this.n, '1');
  }

  private updateN(value: string) {
    const parsed = Number(value);
    if (Number.isNaN(parsed)) {
      return;
    }
    const nextN = Math.max(2, Math.min(8, Math.floor(parsed)));
    if (nextN !== this.n) {
      this.n = nextN;
      this.resetQuaternionGrid(nextN, this.mode === 0 ? '1' : '0');
      this.clearResultState();
    }
  }

  private clearResultState() {
    this.eigenItems = [];
    this.eigenMessage = '请选择功能并点击计算';
    this.formationOk = true;
    this.formationFeasible = false;
    this.formationMessage = '请选择功能并点击判定';
    this.formationSummary = '';
    this.formationConditions = [];
    this.formationIndicators = [];
    this.zeroEigenvectorText = '';
    this.underlyingLaplacianText = '';
  }

  private switchMode(nextMode: number) {
    if (this.mode === nextMode) {
      return;
    }
    this.mode = nextMode;
    this.clearResultState();
    this.resetQuaternionGrid(this.n, nextMode === 0 ? '1' : '0');
  }

  private indices(n: number): number[] {
    const arr: number[] = [];
    for (let i = 0; i < n; i++) {
      arr.push(i);
    }
    return arr;
  }

  private createFilledGrid(n: number, fill: string): string[][] {
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

  private resetQuaternionGrid(n: number, diagonalValue: string) {
    const a: string[][] = this.createFilledGrid(n, '0');
    const b: string[][] = this.createFilledGrid(n, '0');
    const c: string[][] = this.createFilledGrid(n, '0');
    const d: string[][] = this.createFilledGrid(n, '0');
    const da: string[][] = this.createFilledGrid(n, '0');
    const db: string[][] = this.createFilledGrid(n, '0');
    const dc: string[][] = this.createFilledGrid(n, '0');
    const dd: string[][] = this.createFilledGrid(n, '0');
    for (let i = 0; i < n; i++) {
      a[i][i] = diagonalValue;
    }
    this.qa = a;
    this.qb = b;
    this.qc = c;
    this.qd = d;
    this.ea = da;
    this.eb = db;
    this.ec = dc;
    this.ed = dd;
  }

  private negateText(v: string): string {
    const t = v.trim();
    if (t.length === 0) {
      return '0';
    }
    if (t.startsWith('-')) {
      return t.substring(1);
    }
    return `-${t}`;
  }

  private randomInt(min: number, max: number): number {
    return Math.floor(Math.random() * (max - min + 1)) + min;
  }

  private randomizeQuaternionGrid(n: number) {
    const a: string[][] = this.createFilledGrid(n, '0');
    const b: string[][] = this.createFilledGrid(n, '0');
    const c: string[][] = this.createFilledGrid(n, '0');
    const d: string[][] = this.createFilledGrid(n, '0');
    const da: string[][] = this.createFilledGrid(n, '0');
    const db: string[][] = this.createFilledGrid(n, '0');
    const dc: string[][] = this.createFilledGrid(n, '0');
    const dd: string[][] = this.createFilledGrid(n, '0');
    for (let i = 0; i < n; i++) {
      a[i][i] = `${this.randomInt(1, 8)}`;
      da[i][i] = `${this.randomInt(-3, 3)}`;
      for (let j = i + 1; j < n; j++) {
        const pA = this.randomInt(-3, 3);
        const pB = this.randomInt(-3, 3);
        const pC = this.randomInt(-3, 3);
        const pD = this.randomInt(-3, 3);
        const dA = this.randomInt(-3, 3);
        const dB = this.randomInt(-3, 3);
        const dC = this.randomInt(-3, 3);
        const dD = this.randomInt(-3, 3);
        a[i][j] = `${pA}`;
        b[i][j] = `${pB}`;
        c[i][j] = `${pC}`;
        d[i][j] = `${pD}`;
        a[j][i] = `${pA}`;
        b[j][i] = `${-pB}`;
        c[j][i] = `${-pC}`;
        d[j][i] = `${-pD}`;
        da[i][j] = `${dA}`;
        db[i][j] = `${dB}`;
        dc[i][j] = `${dC}`;
        dd[i][j] = `${dD}`;
        da[j][i] = `${dA}`;
        db[j][i] = `${-dB}`;
        dc[j][i] = `${-dC}`;
        dd[j][i] = `${-dD}`;
      }
    }
    this.qa = a;
    this.qb = b;
    this.qc = c;
    this.qd = d;
    this.ea = da;
    this.eb = db;
    this.ec = dc;
    this.ed = dd;
  }

  private toNumberText(v: string): string {
    const trimmed = v.trim();
    const x = Number(trimmed);
    if (Number.isNaN(x)) {
      return '0';
    }
    return `${x}`;
  }

  private matrixTextFromGrid(): string {
    const lines: string[] = [];
    for (let i = 0; i < this.n; i++) {
      const cols: string[] = [];
      for (let j = 0; j < this.n; j++) {
        cols.push(
          `${this.toNumberText(this.qa[i][j])},${this.toNumberText(this.qb[i][j])},${this.toNumberText(this.qc[i][j])},${this.toNumberText(this.qd[i][j])},` +
          `${this.toNumberText(this.ea[i][j])},${this.toNumberText(this.eb[i][j])},${this.toNumberText(this.ec[i][j])},${this.toNumberText(this.ed[i][j])}`
        );
      }
      lines.push(cols.join(';'));
    }
    return lines.join('\n');
  }

  private applyMatrixTextToGrid(text: string, n: number) {
    const lines: string[] = text.split(/\r?\n/).map((item: string) => item.trim()).filter((item: string) => item.length > 0);
    if (lines.length !== n) {
      return;
    }
    const a: string[][] = this.createFilledGrid(n, '0');
    const b: string[][] = this.createFilledGrid(n, '0');
    const c: string[][] = this.createFilledGrid(n, '0');
    const d: string[][] = this.createFilledGrid(n, '0');
    const da: string[][] = this.createFilledGrid(n, '0');
    const db: string[][] = this.createFilledGrid(n, '0');
    const dc: string[][] = this.createFilledGrid(n, '0');
    const dd: string[][] = this.createFilledGrid(n, '0');

    for (let i = 0; i < n; i++) {
      const cols: string[] = lines[i].split(';').map((item: string) => item.trim());
      if (cols.length !== n) {
        return;
      }
      for (let j = 0; j < n; j++) {
        const parts: string[] = cols[j].split(',').map((item: string) => item.trim());
        if (parts.length !== 8) {
          return;
        }
        a[i][j] = parts[0];
        b[i][j] = parts[1];
        c[i][j] = parts[2];
        d[i][j] = parts[3];
        da[i][j] = parts[4];
        db[i][j] = parts[5];
        dc[i][j] = parts[6];
        dd[i][j] = parts[7];
      }
    }

    this.n = n;
    this.qa = a;
    this.qb = b;
    this.qc = c;
    this.qd = d;
    this.ea = da;
    this.eb = db;
    this.ec = dc;
    this.ed = dd;
  }

  private updateCellWithPart(i: number, j: number, component: number, value: string, isDual: boolean, allowDiagonalEdit: boolean = true) {
    if (i > j) {
      return;
    }
    if (i === j && !allowDiagonalEdit && isDual) {
      return;
    }
    const v: string = value.trim().length === 0 ? '0' : value.trim();
    let aGrid: string[][];
    let bGrid: string[][];
    let cGrid: string[][];
    let dGrid: string[][];
    if (isDual) {
      aGrid = this.ea;
      bGrid = this.eb;
      cGrid = this.ec;
      dGrid = this.ed;
    } else {
      aGrid = this.qa;
      bGrid = this.qb;
      cGrid = this.qc;
      dGrid = this.qd;
    }

    if (component === 0) {
      aGrid[i][j] = v;
      aGrid[j][i] = v;
    } else if (component === 1) {
      const nv = i === j ? '0' : v;
      bGrid[i][j] = nv;
      bGrid[j][i] = i === j ? '0' : this.negateText(nv);
    } else if (component === 2) {
      const nv = i === j ? '0' : v;
      cGrid[i][j] = nv;
      cGrid[j][i] = i === j ? '0' : this.negateText(nv);
    } else {
      const nv = i === j ? '0' : v;
      dGrid[i][j] = nv;
      dGrid[j][i] = i === j ? '0' : this.negateText(nv);
    }

    if (isDual) {
      this.ea = [...aGrid];
      this.eb = [...bGrid];
      this.ec = [...cGrid];
      this.ed = [...dGrid];
    } else {
      this.qa = [...aGrid];
      this.qb = [...bGrid];
      this.qc = [...cGrid];
      this.qd = [...dGrid];
    }
  }

  private updateStandardCell(i: number, j: number, component: number, value: string) {
    this.updateCellWithPart(i, j, component, value, false, true);
  }

  private updateDualCell(i: number, j: number, component: number, value: string, allowDiagonalEdit: boolean = true) {
    this.updateCellWithPart(i, j, component, value, true, allowDiagonalEdit);
  }

  private openOverlay(title: string, text: string) {
    this.overlayTitle = title;
    this.overlayText = text;
    this.showOverlay = true;
  }

  private closeOverlay() {
    this.showOverlay = false;
  }

  private fillCurrentExample() {
    if (this.mode === 0) {
      this.randomizeQuaternionGrid(this.n);
      this.matrixInput = this.matrixTextFromGrid();
    } else {
      this.fillBalancedJudgeExample();
    }
  }

  private fillBalancedJudgeExample() {
    const sample: string =
      '2,0,0,0,0,0,0,0;-1,0,0,0,0,-1,0,0;-1,0,0,0,0,0,0,0\n' +
      '-1,0,0,0,0,1,0,0;2,0,0,0,0,0,0,0;-1,0,0,0,0,1,0,0\n' +
      '-1,0,0,0,0,0,0,0;-1,0,0,0,0,-1,0,0;2,0,0,0,0,0,0,0';
    this.applyMatrixTextToGrid(sample, 3);
    this.clearFormationResult();
  }

  private fillUnbalancedJudgeExample() {
    const sample: string =
      '2,0,0,0,0,0,0,0;-1,0,0,0,0,-1,0,0;-1,0,0,0,0,2,0,0\n' +
      '-1,0,0,0,0,1,0,0;2,0,0,0,0,0,0,0;-1,0,0,0,0,1,0,0\n' +
      '-1,0,0,0,0,-2,0,0;-1,0,0,0,0,-1,0,0;2,0,0,0,0,0,0,0';
    this.applyMatrixTextToGrid(sample, 3);
    this.clearFormationResult();
  }

  private randomizeJudgeMatrix() {
    const n: number = this.n;
    const a: string[][] = this.createFilledGrid(n, '0');
    const b: string[][] = this.createFilledGrid(n, '0');
    const c: string[][] = this.createFilledGrid(n, '0');
    const d: string[][] = this.createFilledGrid(n, '0');
    const da: string[][] = this.createFilledGrid(n, '0');
    const db: string[][] = this.createFilledGrid(n, '0');
    const dc: string[][] = this.createFilledGrid(n, '0');
    const dd: string[][] = this.createFilledGrid(n, '0');

    for (let i = 0; i < n; i++) {
      a[i][i] = '0';
    }

    for (let i = 0; i < n - 1; i++) {
      this.fillJudgeEdge(a, b, c, d, da, db, dc, dd, i, i + 1);
    }

    for (let i = 0; i < n; i++) {
      for (let j = i + 2; j < n; j++) {
        if (Math.random() < 0.45) {
          this.fillJudgeEdge(a, b, c, d, da, db, dc, dd, i, j);
        }
      }
    }

    this.qa = a;
    this.qb = b;
    this.qc = c;
    this.qd = d;
    this.ea = da;
    this.eb = db;
    this.ec = dc;
    this.ed = dd;
    this.autofillJudgeDegrees();
    this.clearFormationResult();
  }

  private fillJudgeEdge(a: string[][], b: string[][], c: string[][], d: string[][], da: string[][], db: string[][],
    dc: string[][], dd: string[][], i: number, j: number) {
    const dualI: number = this.randomInt(-2, 2);
    const dualJ: number = this.randomInt(-2, 2);
    const dualK: number = this.randomInt(-2, 2);

    a[i][j] = '-1';
    b[i][j] = '0';
    c[i][j] = '0';
    d[i][j] = '0';
    da[i][j] = '0';
    db[i][j] = `${-dualI}`;
    dc[i][j] = `${-dualJ}`;
    dd[i][j] = `${-dualK}`;

    a[j][i] = '-1';
    b[j][i] = '0';
    c[j][i] = '0';
    d[j][i] = '0';
    da[j][i] = '0';
    db[j][i] = `${dualI}`;
    dc[j][i] = `${dualJ}`;
    dd[j][i] = `${dualK}`;
  }

  private clearJudgeMatrix() {
    this.resetQuaternionGrid(this.n, '0');
    this.clearFormationResult();
  }

  private clearFormationResult() {
    this.formationOk = true;
    this.formationFeasible = false;
    this.formationMessage = '请选择功能并点击判定';
    this.formationSummary = '';
    this.formationConditions = [];
    this.formationIndicators = [];
    this.zeroEigenvectorText = '';
    this.underlyingLaplacianText = '';
  }

  private isOffDiagonalNonZero(i: number, j: number): boolean {
    const parts: string[] = [
      this.qa[i][j], this.qb[i][j], this.qc[i][j], this.qd[i][j],
      this.ea[i][j], this.eb[i][j], this.ec[i][j], this.ed[i][j]
    ];
    for (let k = 0; k < parts.length; k++) {
      if (Math.abs(Number(parts[k])) > 1e-9) {
        return true;
      }
    }
    return false;
  }

  private autofillJudgeDegrees() {
    for (let i = 0; i < this.n; i++) {
      let degree: number = 0;
      for (let j = 0; j < this.n; j++) {
        if (i !== j && this.isOffDiagonalNonZero(i, j)) {
          degree++;
        }
      }
      this.qa[i][i] = `${degree}`;
      this.qb[i][i] = '0';
      this.qc[i][i] = '0';
      this.qd[i][i] = '0';
      this.ea[i][i] = '0';
      this.eb[i][i] = '0';
      this.ec[i][i] = '0';
      this.ed[i][i] = '0';
    }
    this.qa = [...this.qa];
    this.qb = [...this.qb];
    this.qc = [...this.qc];
    this.qd = [...this.qd];
    this.ea = [...this.ea];
    this.eb = [...this.eb];
    this.ec = [...this.ec];
    this.ed = [...this.ed];
  }

  private runEigen() {
    this.matrixInput = this.matrixTextFromGrid();
    const result = solveDualQuaternionHermitianEigenvalues(this.matrixInput, this.n);
    if (!result.ok) {
      this.eigenItems = [];
      this.eigenMessage = `计算失败：${result.message}`;
      return;
    }
    this.eigenItems = result.items;
    this.eigenMessage = `已计算 ${result.items.length} 个特征值，数值统一保留 6 位小数。`;
  }

  private runJudge() {
    this.matrixInput = this.matrixTextFromGrid();
    const result = evaluateDualQuaternionFormationFeasibility(this.matrixInput, this.n);
    this.formationOk = result.ok;
    this.formationFeasible = result.feasible;
    this.formationMessage = result.ok ? (result.feasible ? '判定完成：满足论文条件。' : '判定完成：未满足全部论文条件。') :
      `判定失败：${result.message}`;
    this.formationSummary = result.summary;
    this.formationConditions = result.conditions;
    this.formationIndicators = result.indicators;
    this.zeroEigenvectorText = result.zeroEigenvectorText;
    this.underlyingLaplacianText = result.underlyingLaplacianPreview;
  }

  @Builder
  private buildInfoButton(title: string, text: string) {
    Button('?')
      .width(24)
      .height(24)
      .fontSize(12)
      .fontColor('#3554B4')
      .backgroundColor('#E9F0FF')
      .borderRadius(12)
      .padding(0)
      .onClick(() => this.openOverlay(title, text))
  }

  @Builder
  private buildResultCard(item: EigenDisplayItem) {
    Column({ space: 10 }) {
      Row() {
        Text(`λ${item.index}`)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#3554B4')
        Blank()
      }
      .width('100%')

      Text(item.lambdaText)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#17315E')
        .width('100%')

      Row({ space: 12 }) {
        Column({ space: 4 }) {
          Text('标准部')
            .fontSize(12)
            .fontColor('#69758C')
          Text(item.lambdaSText)
            .fontSize(16)
            .fontColor('#22324C')
        }
        .alignItems(HorizontalAlign.Start)

        Column({ space: 4 }) {
          Text('对偶部')
            .fontSize(12)
            .fontColor('#69758C')
          Text(item.lambdaDText)
            .fontSize(16)
            .fontColor('#22324C')
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')

      Button('查看特征向量')
        .height(38)
        .fontSize(14)
        .backgroundColor('#264A99')
        .fontColor('#FFFFFF')
        .borderRadius(20)
        .onClick(() => this.openOverlay(item.vectorTitle, item.vectorText))
    }
    .width('100%')
    .padding({ top: 14, right: 16, bottom: 14, left: 16 })
    .backgroundColor('#F7F9FF')
    .borderRadius(18)
    .border({ width: 1, color: '#D7E0F6' })
  }

  @Builder
  private buildConditionCard(item: FormationConditionItem) {
    Column({ space: 10 }) {
      Row({ space: 8 }) {
        Text(item.label)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#183153')
          .layoutWeight(1)
        this.buildInfoButton(item.helpTitle, item.helpText)
      }
      .width('100%')

      Text(item.statusText)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(item.passed ? '#147A3F' : '#B42318')

      Text(item.passed ? '该条件满足论文要求。' : '该条件当前未满足，需要继续检查输入或图平衡性。')
        .fontSize(13)
        .fontColor('#667085')
        .width('100%')
    }
    .width('100%')
    .padding(14)
    .backgroundColor(item.passed ? '#F1FCF4' : '#FFF6F6')
    .border({ width: 1, color: item.passed ? '#CDEFD6' : '#F2C7C7', radius: 16 })
  }

  @Builder
  private buildIndicatorRow(item: FormationIndicatorItem) {
    Row({ space: 10 }) {
      Row({ space: 6 }) {
        Text(item.label)
          .fontSize(14)
          .fontColor('#344054')
        this.buildInfoButton(item.helpTitle, item.helpText)
      }
      .layoutWeight(1)

      Text(item.valueText)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#183153')
    }
    .width('100%')
    .padding({ top: 10, bottom: 10 })
  }

  @Builder
  private buildMatrixSection(title: string, description: string, isDual: boolean, allowDiagonalEdit: boolean) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#183153')
      Text(description)
        .fontSize(13)
        .fontColor('#667085')

      Scroll() {
        Scroll() {
          Column({ space: 6 }) {
            ForEach(this.indices(this.n), (i: number) => {
              Row({ space: 6 }) {
                ForEach(this.indices(this.n), (j: number) => {
                  Column() {
                    if (i === j) {
                      if (isDual && !allowDiagonalEdit) {
                        Text('0')
                          .width(56)
                          .height(40)
                          .textAlign(TextAlign.Center)
                          .fontSize(16)
                          .fontColor('#98A2B3')
                          .padding({ top: 8 })
                      } else {
                        TextInput({ text: isDual ? this.ea[i][j] : this.qa[i][j] })
                          .width(56)
                          .height(40)
                          .onChange((v: string) => {
                            if (isDual) {
                              this.updateDualCell(i, j, 0, v, allowDiagonalEdit)
                            } else {
                              this.updateStandardCell(i, j, 0, v)
                            }
                          })
                      }
                    } else {
                      Column({ space: 4 }) {
                        Row({ space: 4 }) {
                          TextInput({ text: isDual ? this.ea[i][j] : this.qa[i][j] })
                            .width(48)
                            .height(32)
                            .enabled(i < j)
                            .onChange((v: string) => {
                              if (isDual) {
                                this.updateDualCell(i, j, 0, v, allowDiagonalEdit)
                              } else {
                                this.updateStandardCell(i, j, 0, v)
                              }
                            })
                          TextInput({ text: isDual ? this.eb[i][j] : this.qb[i][j] })
                            .width(48)
                            .height(32)
                            .enabled(i < j)
                            .onChange((v: string) => {
                              if (isDual) {
                                this.updateDualCell(i, j, 1, v, allowDiagonalEdit)
                              } else {
                                this.updateStandardCell(i, j, 1, v)
                              }
                            })
                        }
                        Row({ space: 4 }) {
                          TextInput({ text: isDual ? this.ec[i][j] : this.qc[i][j] })
                            .width(48)
                            .height(32)
                            .enabled(i < j)
                            .onChange((v: string) => {
                              if (isDual) {
                                this.updateDualCell(i, j, 2, v, allowDiagonalEdit)
                              } else {
                                this.updateStandardCell(i, j, 2, v)
                              }
                            })
                          TextInput({ text: isDual ? this.ed[i][j] : this.qd[i][j] })
                            .width(48)
                            .height(32)
                            .enabled(i < j)
                            .onChange((v: string) => {
                              if (isDual) {
                                this.updateDualCell(i, j, 3, v, allowDiagonalEdit)
                              } else {
                                this.updateStandardCell(i, j, 3, v)
                              }
                            })
                        }
                      }
                    }
                  }
                  .padding(4)
                  .border({ width: 1, color: '#D0D7E6', radius: 6 })
                })
              }
            })
          }
          .padding(6)
        }
        .scrollable(ScrollDirection.Vertical)
        .height(280)
      }
      .scrollable(ScrollDirection.Horizontal)
      .width('100%')
      .height(300)
      .border({ width: 1, color: '#D0D7E6', radius: 10 })
    }
    .width('100%')
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: 12 }) {
          Text('EigenFleet')
            .width('100%')
            .textAlign(TextAlign.Center)
            .fontSize(30)
            .fontColor('#2B6DEB')
            .fontWeight(FontWeight.Bold)
          Text('多智能体编队谱分析工具')
            .width('100%')
            .textAlign(TextAlign.Center)
            .fontSize(16)
            .fontColor('#667085')

          Row({ space: 8 }) {
            Button('特征值计算')
              .type(this.mode === 0 ? ButtonType.Capsule : ButtonType.Normal)
              .onClick(() => this.switchMode(0))
            Button('可行性判定')
              .type(this.mode === 1 ? ButtonType.Capsule : ButtonType.Normal)
              .onClick(() => this.switchMode(1))
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)

          Row({ space: 8 }) {
            Text('矩阵阶数 (2~8)')
              .fontSize(14)
            TextInput({ text: this.n.toString() })
              .width(80)
              .onChange((v: string) => this.updateN(v))
            Button(this.mode === 0 ? '随机填充' : '平衡样例')
              .onClick(() => this.fillCurrentExample())
          }

          if (this.mode === 0) {
            this.buildMatrixSection(
              '标准部',
              '主对角仅输入实部；其余输入 a,b,c,d，对应 1,i,j,k 分量；下三角自动按埃尔米特共轭联动。',
              false,
              true
            )
            this.buildMatrixSection(
              '对偶部',
              '主对角允许输入实部；其余输入 a,b,c,d，对应 1,i,j,k 分量；下三角自动按埃尔米特共轭联动。',
              true,
              true
            )

            Button('计算全部特征值')
              .height(42)
              .backgroundColor('#1E429F')
              .fontColor('#FFFFFF')
              .borderRadius(24)
              .onClick(() => this.runEigen())

            Column({ space: 12 }) {
              Row() {
                Text('结果')
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#183153')
                Blank()
                Text(`${this.eigenItems.length} 项`)
                  .fontSize(12)
                  .fontColor('#667085')
              }
              .width('100%')

              Text(this.eigenMessage)
                .width('100%')
                .fontSize(14)
                .fontColor('#5B657A')

              if (this.eigenItems.length === 0) {
                Column({ space: 8 }) {
                  Text('暂无结果')
                    .fontSize(18)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#344054')
                  Text('输入矩阵后点击“计算全部特征值”，这里会生成卡片式结果。')
                    .fontSize(13)
                    .fontColor('#667085')
                    .textAlign(TextAlign.Center)
                }
                .width('100%')
                .padding({ top: 24, bottom: 24 })
              } else {
                Column({ space: 10 }) {
                  ForEach(this.eigenItems, (item: EigenDisplayItem) => {
                    this.buildResultCard(item)
                  })
                }
                .width('100%')
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .border({ width: 1, color: '#D8E1F2', radius: 18 })
          } else {
            Column({ space: 8 }) {
              Row({ space: 8 }) {
              Button('自动回填对角度数')
                .type(ButtonType.Capsule)
                .onClick(() => this.autofillJudgeDegrees())
              Button('非平衡样例')
                .type(ButtonType.Capsule)
                .onClick(() => this.fillUnbalancedJudgeExample())
              }
              .width('100%')
              .justifyContent(FlexAlign.Start)

              Row({ space: 8 }) {
                Button('随机填充')
                  .type(ButtonType.Capsule)
                  .onClick(() => this.randomizeJudgeMatrix())
                Button('清空矩阵')
                  .type(ButtonType.Capsule)
                  .onClick(() => this.clearJudgeMatrix())
              }
              .width('100%')
              .justifyContent(FlexAlign.Start)
            }
            .width('100%')

            this.buildMatrixSection(
              '拉普拉斯矩阵标准部',
              '主对角仅录入节点度数；非对角录入单位增益的负值标准部。这个矩阵应满足 L = D - A(Φ)。',
              false,
              true
            )
            this.buildMatrixSection(
              '拉普拉斯矩阵对偶部',
              '非对角录入单位增益的负值对偶部；主对角对偶部应为 0，所以这里固定为不可编辑。',
              true,
              false
            )

            Button('计算并判定')
              .height(42)
              .backgroundColor('#1E429F')
              .fontColor('#FFFFFF')
              .borderRadius(24)
              .onClick(() => this.runJudge())

            Column({ space: 12 }) {
              Row() {
                Text('判定结果')
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#183153')
                Blank()
                this.buildInfoButton('可行性判定说明', '这里依据论文 Corollary 6.3 判断目标相对构型是否可行。只有三个理论条件同时满足，才能判定为可行。')
              }
              .width('100%')

              Column({ space: 8 }) {
                Text(this.formationOk ? (this.formationFeasible ? '可行' : '不可行') : '判定失败')
                  .fontSize(28)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(!this.formationOk ? '#B42318' : (this.formationFeasible ? '#147A3F' : '#B42318'))
                Text(this.formationMessage)
                  .fontSize(14)
                  .fontColor('#667085')
                if (this.formationSummary.length > 0) {
                  Text(this.formationSummary)
                    .fontSize(13)
                    .fontColor('#344054')
                }
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#F7F9FF')
              .border({ width: 1, color: '#D8E1F2', radius: 16 })

              if (this.formationConditions.length > 0) {
                Column({ space: 10 }) {
                  ForEach(this.formationConditions, (item: FormationConditionItem) => {
                    this.buildConditionCard(item)
                  })
                }
                .width('100%')
              }

              if (this.formationIndicators.length > 0) {
                Column({ space: 0 }) {
                  ForEach(this.formationIndicators, (item: FormationIndicatorItem) => {
                    this.buildIndicatorRow(item)
                  })
                }
                .width('100%')
                .padding(14)
                .backgroundColor('#FFFFFF')
                .border({ width: 1, color: '#D8E1F2', radius: 16 })
              }

              if (this.zeroEigenvectorText.length > 0) {
                Row({ space: 8 }) {
                  Button('查看零特征向量')
                    .type(ButtonType.Capsule)
                    .onClick(() => this.openOverlay('零特征向量', this.zeroEigenvectorText))
                  Button('查看底层图 L(0)')
                    .type(ButtonType.Capsule)
                    .onClick(() => this.openOverlay('底层图 Laplacian L(0)', this.underlyingLaplacianText))
                }
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .border({ width: 1, color: '#D8E1F2', radius: 18 })
          }
        }
        .padding(12)
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      .scrollable(ScrollDirection.Vertical)
      .width('100%')
      .height('100%')

      if (this.showOverlay) {
        Column() {
          Column({ space: 12 }) {
            Row() {
              Text(this.overlayTitle)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#183153')
              Blank()
              Button('关闭')
                .type(ButtonType.Capsule)
                .onClick(() => this.closeOverlay())
            }
            .width('100%')

            Scroll() {
              Text(this.overlayText)
                .width('100%')
                .fontSize(14)
                .fontColor('#344054')
                .textAlign(TextAlign.Start)
                .lineHeight(24)
            }
            .scrollable(ScrollDirection.Vertical)
            .height('70%')
            .width('100%')
          }
          .width('88%')
          .height('68%')
          .padding(18)
          .backgroundColor('#FFFFFF')
          .borderRadius(20)
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#7F0F172A')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
  }
}
