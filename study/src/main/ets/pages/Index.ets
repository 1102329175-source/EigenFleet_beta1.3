import { solveDualQuaternionHermitianEigenvalues, evaluateFormationFeasibility } from '../utils/EigenSolver';

@Entry
@Component
struct Index {
  @State mode: number = 0;
  @State n: number = 2;
  @State matrixInput: string = '2,0,0,0,0,0,0,0;1,1,0,0,0,0,0,0\n1,-1,0,0,0,0,0,0;3,0,0,0,0,0,0,0';
  @State laplacianInput: string = '1,-1\n-1,1';
  @State output: string = '请选择功能并点击计算';
  @State qa: string[][] = [];
  @State qb: string[][] = [];
  @State qc: string[][] = [];
  @State qd: string[][] = [];
  @State ea: string[][] = [];
  @State eb: string[][] = [];
  @State ec: string[][] = [];
  @State ed: string[][] = [];

  aboutToAppear() {
    this.resetQuaternionGrid(this.n);
  }

  private updateN(value: string) {
    const k = Number(value);
    if (Number.isNaN(k)) {
      return;
    }
    const nextN = Math.max(2, Math.min(8, Math.floor(k)));
    if (nextN !== this.n) {
      this.n = nextN;
      this.resetQuaternionGrid(nextN);
    }
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

  private resetQuaternionGrid(n: number) {
    const a: string[][] = this.createFilledGrid(n, '0');
    const b: string[][] = this.createFilledGrid(n, '0');
    const c: string[][] = this.createFilledGrid(n, '0');
    const d: string[][] = this.createFilledGrid(n, '0');
    const da: string[][] = this.createFilledGrid(n, '0');
    const db: string[][] = this.createFilledGrid(n, '0');
    const dc: string[][] = this.createFilledGrid(n, '0');
    const dd: string[][] = this.createFilledGrid(n, '0');
    for (let i = 0; i < n; i++) {
      a[i][i] = '1';
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
      b[i][i] = '0';
      c[i][i] = '0';
      d[i][i] = '0';
      da[i][i] = `${this.randomInt(-3, 3)}`;
      db[i][i] = '0';
      dc[i][i] = '0';
      dd[i][i] = '0';
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
    const t = v.trim();
    const x = Number(t);
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
        const a = this.toNumberText(this.qa[i][j]);
        const b = this.toNumberText(this.qb[i][j]);
        const c = this.toNumberText(this.qc[i][j]);
        const d = this.toNumberText(this.qd[i][j]);
        const ea = this.toNumberText(this.ea[i][j]);
        const eb = this.toNumberText(this.eb[i][j]);
        const ec = this.toNumberText(this.ec[i][j]);
        const ed = this.toNumberText(this.ed[i][j]);
        cols.push(`${a},${b},${c},${d},${ea},${eb},${ec},${ed}`);
      }
      lines.push(cols.join(';'));
    }
    return lines.join('\n');
  }

  private updateCellWithPart(i: number, j: number, component: number, value: string, isDual: boolean) {
    if (i > j) {
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
    this.updateCellWithPart(i, j, component, value, false);
  }

  private updateDualCell(i: number, j: number, component: number, value: string) {
    this.updateCellWithPart(i, j, component, value, true);
  }

  private buildLaplacianSample(n: number): string {
    const w: number[][] = [];
    for (let i = 0; i < n; i++) {
      const row: number[] = [];
      for (let j = 0; j < n; j++) {
        row.push(0);
      }
      w.push(row);
    }
    for (let i = 0; i < n - 1; i++) {
      w[i][i + 1] = 1;
      w[i + 1][i] = 1;
    }
    for (let i = 0; i < n; i++) {
      for (let j = i + 2; j < n; j++) {
        if (this.randomInt(0, 1) === 1) {
          w[i][j] = 1;
          w[j][i] = 1;
        }
      }
    }
    const l: number[][] = [];
    for (let i = 0; i < n; i++) {
      const row: number[] = [];
      let degree: number = 0;
      for (let j = 0; j < n; j++) {
        degree += w[i][j];
      }
      for (let j = 0; j < n; j++) {
        if (i === j) {
          row.push(degree);
        } else {
          row.push(-w[i][j]);
        }
      }
      l.push(row);
    }
    return l.map((row) => row.join(',')).join('\n');
  }

  private fillCurrentExample() {
    if (this.mode === 0) {
      this.randomizeQuaternionGrid(this.n);
      this.matrixInput = this.matrixTextFromGrid();
    } else {
      this.laplacianInput = this.buildLaplacianSample(this.n);
    }
  }

  private runEigen() {
    this.matrixInput = this.matrixTextFromGrid();
    const r = solveDualQuaternionHermitianEigenvalues(this.matrixInput, this.n);
    if (!r.ok) {
      this.output = `计算失败: ${r.message}`;
      return;
    }
    const lines: string[] = ['特征值与对应特征向量:'];
    for (let i = 0; i < r.values.length; i++) {
      const vec: string = i < r.vectors.length ? r.vectors[i] : '[]';
      lines.push(`λ${i + 1} = ${r.values[i]}`);
      lines.push(`v${i + 1} = ${vec}`);
    }
    this.output = lines.join('\n');
  }

  private runJudge() {
    const r = evaluateFormationFeasibility(this.laplacianInput, this.n);
    this.output = r.ok ? `拉普拉斯特征值:\n${r.eigenvalues.join(', ')}\n判定: ${r.feasible ? '可行' : '不可行'}\n${r.message}` : `判定失败: ${r.message}`;
  }

  build() {
    Scroll() {
      Column({ space: 10 }) {
        Text('EigenFleet')
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontSize(30)
          .fontColor('#2B6DEB')
          .fontWeight(FontWeight.Bold)
        Text('多智能体编队检定工具')
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontSize(16)
          .fontColor('#7A7A7A')

        Row({ space: 8 }) {
          Button('特征值计算').type(this.mode === 0 ? ButtonType.Capsule : ButtonType.Normal).onClick(() => this.mode = 0)
          Button('编队判定').type(this.mode === 1 ? ButtonType.Capsule : ButtonType.Normal).onClick(() => this.mode = 1)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)

        Row({ space: 8 }) {
          Text('此处输入矩阵阶数(2~8)')
          TextInput({ text: this.n.toString() }).width(80).onChange((v) => this.updateN(v))
          Button('随机填充').onClick(() => this.fillCurrentExample())
        }

        if (this.mode === 0) {
          Text('标准部分：主对角线仅实部；其余元素填写 a,b,c,d（实部/i/j/k），下三角自动共轭联动')
          Scroll() {
            Scroll() {
              Column({ space: 6 }) {
                ForEach(this.indices(this.n), (i: number) => {
                  Row({ space: 6 }) {
                    ForEach(this.indices(this.n), (j: number) => {
                      Column() {
                        if (i === j) {
                          TextInput({ text: this.qa[i][j] })
                            .width(56)
                            .height(40)
                            .onChange((v: string) => this.updateStandardCell(i, j, 0, v))
                        } else {
                          Column({ space: 4 }) {
                            Row({ space: 4 }) {
                              TextInput({ text: this.qa[i][j] })
                                .width(48)
                                .height(32)
                                .enabled(i < j)
                                .onChange((v: string) => this.updateStandardCell(i, j, 0, v))
                              TextInput({ text: this.qb[i][j] })
                                .width(48)
                                .height(32)
                                .enabled(i < j)
                                .onChange((v: string) => this.updateStandardCell(i, j, 1, v))
                            }
                            Row({ space: 4 }) {
                              TextInput({ text: this.qc[i][j] })
                                .width(48)
                                .height(32)
                                .enabled(i < j)
                                .onChange((v: string) => this.updateStandardCell(i, j, 2, v))
                              TextInput({ text: this.qd[i][j] })
                                .width(48)
                                .height(32)
                                .enabled(i < j)
                                .onChange((v: string) => this.updateStandardCell(i, j, 3, v))
                            }
                          }
                        }
                      }
                      .padding(4)
                      .border({ width: 1, color: '#D0D0D0', radius: 4 })
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
          .border({ width: 1, color: '#D0D0D0', radius: 8 })
          Text('对偶部分：主对角线仅实部；其余元素填写 a,b,c,d（实部/i/j/k），下三角自动共轭联动')
          Scroll() {
            Scroll() {
              Column({ space: 6 }) {
                ForEach(this.indices(this.n), (i: number) => {
                  Row({ space: 6 }) {
                    ForEach(this.indices(this.n), (j: number) => {
                      Column() {
                        if (i === j) {
                          TextInput({ text: this.ea[i][j] })
                            .width(56)
                            .height(40)
                            .onChange((v: string) => this.updateDualCell(i, j, 0, v))
                        } else {
                          Column({ space: 4 }) {
                            Row({ space: 4 }) {
                              TextInput({ text: this.ea[i][j] })
                                .width(48)
                                .height(32)
                                .enabled(i < j)
                                .onChange((v: string) => this.updateDualCell(i, j, 0, v))
                              TextInput({ text: this.eb[i][j] })
                                .width(48)
                                .height(32)
                                .enabled(i < j)
                                .onChange((v: string) => this.updateDualCell(i, j, 1, v))
                            }
                            Row({ space: 4 }) {
                              TextInput({ text: this.ec[i][j] })
                                .width(48)
                                .height(32)
                                .enabled(i < j)
                                .onChange((v: string) => this.updateDualCell(i, j, 2, v))
                              TextInput({ text: this.ed[i][j] })
                                .width(48)
                                .height(32)
                                .enabled(i < j)
                                .onChange((v: string) => this.updateDualCell(i, j, 3, v))
                            }
                          }
                        }
                      }
                      .padding(4)
                      .border({ width: 1, color: '#D0D0D0', radius: 4 })
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
          .border({ width: 1, color: '#D0D0D0', radius: 8 })
          Button('计算全部特征值').onClick(() => this.runEigen())
        } else {
          Text('输入 n×n 拉普拉斯矩阵：每行逗号分隔，行与行换行分隔')
          TextArea({ text: this.laplacianInput, placeholder: '' }).height(220).onChange((v) => this.laplacianInput = v)
          Button('计算并判定').onClick(() => this.runJudge())
        }

        Column() {
          Text(this.output)
            .width('100%')
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .padding(12)
        .border({ width: 1, color: '#D0D0D0', radius: 8 })
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
      .padding(12)
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .scrollable(ScrollDirection.Vertical)
    .width('100%')
    .height('100%')
  }
}
