import { router } from '@kit.ArkUI';
import {
  evaluateDualQuaternionFormationFeasibility,
  FormationConditionItem,
  FormationIndicatorItem
} from '../utils/EigenSolver';
import {
  FeasibilityHistoryItem,
  initHistoryStorage,
  loadFeasibilityHistory,
  saveFeasibilityHistory
} from '../utils/HistoryStore';
import {
  applyMatrixTextToGrid,
  autoFillJudgeDegrees,
  createBalancedJudgeExample,
  createRandomJudgeGrid,
  createResetQuaternionGrid,
  createUnbalancedJudgeExample,
  formatTimeText,
  MatrixGridData,
  matrixTextFromGrid,
  updateGridCell
} from '../utils/MatrixPageSupport';

@Entry
@Component
struct FeasibilityPage {
  @State n: number = 2;
  @State matrixInput: string = '';
  @State formationOk: boolean = true;
  @State formationFeasible: boolean = false;
  @State formationMessage: string = '请输入拉普拉斯矩阵后点击“计算并判定”。';
  @State formationSummary: string = '';
  @State formationConditions: FormationConditionItem[] = [];
  @State formationIndicators: FormationIndicatorItem[] = [];
  @State zeroEigenvectorText: string = '';
  @State underlyingLaplacianText: string = '';
  @State showOverlay: boolean = false;
  @State overlayTitle: string = '';
  @State overlayText: string = '';
  @State historyExpanded: boolean = false;
  @State feasibilityHistory: FeasibilityHistoryItem[] = [];
  @State qa: string[][] = [];
  @State qb: string[][] = [];
  @State qc: string[][] = [];
  @State qd: string[][] = [];
  @State ea: string[][] = [];
  @State eb: string[][] = [];
  @State ec: string[][] = [];
  @State ed: string[][] = [];

  aboutToAppear() {
    initHistoryStorage();
    this.resetPage();
    this.loadHistory();
  }

  private resetPage() {
    this.n = 2;
    this.matrixInput = '';
    this.applyGrid(createResetQuaternionGrid(2, '0'));
    this.clearResultState();
    this.closeOverlay();
  }

  private loadHistory() {
    this.feasibilityHistory = loadFeasibilityHistory();
  }

  private applyGrid(data: MatrixGridData) {
    this.qa = data.qa;
    this.qb = data.qb;
    this.qc = data.qc;
    this.qd = data.qd;
    this.ea = data.ea;
    this.eb = data.eb;
    this.ec = data.ec;
    this.ed = data.ed;
  }

  private currentGrid(): MatrixGridData {
    const data: MatrixGridData = new MatrixGridData();
    data.qa = this.qa;
    data.qb = this.qb;
    data.qc = this.qc;
    data.qd = this.qd;
    data.ea = this.ea;
    data.eb = this.eb;
    data.ec = this.ec;
    data.ed = this.ed;
    return data;
  }

  private clearResultState() {
    this.formationOk = true;
    this.formationFeasible = false;
    this.formationMessage = '请输入拉普拉斯矩阵后点击“计算并判定”。';
    this.formationSummary = '';
    this.formationConditions = [];
    this.formationIndicators = [];
    this.zeroEigenvectorText = '';
    this.underlyingLaplacianText = '';
  }

  private indices(n: number): number[] {
    const arr: number[] = [];
    for (let i = 0; i < n; i++) {
      arr.push(i);
    }
    return arr;
  }

  private updateN(value: string) {
    const parsed = Number(value);
    if (Number.isNaN(parsed)) {
      return;
    }
    const nextN = Math.max(2, Math.min(8, Math.floor(parsed)));
    if (nextN !== this.n) {
      this.n = nextN;
      this.applyGrid(createResetQuaternionGrid(nextN, '0'));
      this.clearResultState();
    }
  }

  private updateStandardCell(i: number, j: number, component: number, value: string) {
    this.applyGrid(updateGridCell(this.currentGrid(), i, j, component, value, false, true));
  }

  private updateDualCell(i: number, j: number, component: number, value: string, allowDiagonalEdit: boolean = true) {
    this.applyGrid(updateGridCell(this.currentGrid(), i, j, component, value, true, allowDiagonalEdit));
  }

  private openOverlay(title: string, text: string) {
    this.overlayTitle = title;
    this.overlayText = text;
    this.showOverlay = true;
  }

  private closeOverlay() {
    this.showOverlay = false;
  }

  private fillBalancedExample() {
    this.n = 3;
    this.applyGrid(createBalancedJudgeExample());
    this.clearResultState();
  }

  private fillUnbalancedExample() {
    this.n = 3;
    this.applyGrid(createUnbalancedJudgeExample());
    this.clearResultState();
  }

  private randomizeJudgeMatrix() {
    this.applyGrid(createRandomJudgeGrid(this.n));
    this.clearResultState();
  }

  private autoFillDegrees() {
    this.applyGrid(autoFillJudgeDegrees(this.currentGrid(), this.n));
    this.clearResultState();
  }

  private clearJudgeMatrix() {
    this.applyGrid(createResetQuaternionGrid(this.n, '0'));
    this.clearResultState();
  }

  private saveHistory() {
    let errText: string = '未计算';
    for (let i = 0; i < this.formationIndicators.length; i++) {
      if (this.formationIndicators[i].key === 'err') {
        errText = this.formationIndicators[i].valueText;
        break;
      }
    }
    let flagText: string = '';
    for (let i = 0; i < this.formationConditions.length; i++) {
      if (i > 0) {
        flagText += '/';
      }
      flagText += this.formationConditions[i].passed ? 'T' : 'F';
    }
    const timestamp: string = `${Date.now()}`;
    const item: FeasibilityHistoryItem = new FeasibilityHistoryItem(
      `feasibility_${timestamp}`,
      timestamp,
      this.n,
      this.matrixInput,
      this.formationFeasible,
      this.formationSummary.length > 0 ? this.formationSummary : this.formationMessage,
      flagText,
      errText
    );
    this.feasibilityHistory = saveFeasibilityHistory(item);
  }

  private restoreHistory(item: FeasibilityHistoryItem) {
    const data: MatrixGridData | null = applyMatrixTextToGrid(item.matrixText, item.n);
    if (data === null) {
      this.openOverlay('历史记录异常', '这条历史记录无法回填，可能是旧版本格式不兼容。');
      return;
    }
    this.n = item.n;
    this.applyGrid(data);
    this.matrixInput = item.matrixText;
    this.clearResultState();
    this.formationMessage = '已从历史记录回填矩阵，请重新点击“计算并判定”。';
    this.closeOverlay();
  }

  private openHistorySummary(item: FeasibilityHistoryItem) {
    const detail: string =
      `时间：${formatTimeText(item.timestamp)}\n` +
      `阶数：${item.n}\n` +
      `结果：${item.feasible ? '可行' : '不可行'}\n` +
      `条件：${item.conditionFlags}\n` +
      `Err：${item.errText}\n\n` +
      `${item.summary}`;
    this.openOverlay('历史记录摘要', detail);
  }

  private runJudge() {
    this.matrixInput = matrixTextFromGrid(this.currentGrid(), this.n);
    const result = evaluateDualQuaternionFormationFeasibility(this.matrixInput, this.n);
    this.formationOk = result.ok;
    this.formationFeasible = result.feasible;
    this.formationMessage = result.ok ? (result.feasible ? '判定完成：满足全部条件。' : '判定完成：未满足全部条件。') :
      `判定失败：${result.message}`;
    this.formationSummary = result.summary;
    this.formationConditions = result.conditions;
    this.formationIndicators = result.indicators;
    this.zeroEigenvectorText = result.zeroEigenvectorText;
    this.underlyingLaplacianText = result.underlyingLaplacianPreview;
    if (result.ok) {
      this.saveHistory();
    }
  }

  @Builder
  private buildHeader() {
    Row({ space: 12 }) {
      Button('< 返回')
        .type(ButtonType.Capsule)
        .fontSize(14)
        .onClick(() => router.back())
      Column({ space: 2 }) {
        Text('可行性判定')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#17315E')
        Text('三项条件数值判定')
          .fontSize(13)
          .fontColor('#667085')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
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

      Text(item.passed ? '这条条件当前已满足。' : '这条条件当前未满足，请继续检查输入矩阵和图结构。')
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
  private buildHistoryCard(item: FeasibilityHistoryItem) {
    Column({ space: 8 }) {
      Row() {
        Text(formatTimeText(item.timestamp))
          .fontSize(13)
          .fontColor('#667085')
        Blank()
        Text(`${item.n} 阶`)
          .fontSize(12)
          .fontColor('#3554B4')
      }
      .width('100%')

      Text(item.feasible ? '可行' : '不可行')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(item.feasible ? '#147A3F' : '#B42318')
        .width('100%')

      Text(item.summary)
        .fontSize(13)
        .fontColor('#667085')
        .width('100%')

      Row({ space: 8 }) {
        Button('回填')
          .type(ButtonType.Capsule)
          .onClick(() => this.restoreHistory(item))
        Button('查看摘要')
          .type(ButtonType.Capsule)
          .onClick(() => this.openHistorySummary(item))
      }
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#FFFFFF')
    .border({ width: 1, color: '#D8E1F2', radius: 16 })
  }

  @Builder
  private buildHistorySection() {
    Column({ space: 10 }) {
      Row() {
        Text('历史记录')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#183153')
        Blank()
        Button(this.historyExpanded ? '收起' : '展开')
          .type(ButtonType.Capsule)
          .onClick(() => {
            this.historyExpanded = !this.historyExpanded;
          })
      }
      .width('100%')

      if (this.historyExpanded) {
        if (this.feasibilityHistory.length === 0) {
          Text('还没有完成判定的历史记录。')
            .fontSize(13)
            .fontColor('#667085')
            .width('100%')
        } else {
          Column({ space: 10 }) {
            ForEach(this.feasibilityHistory, (item: FeasibilityHistoryItem) => {
              this.buildHistoryCard(item)
            })
          }
          .width('100%')
        }
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#F7F9FF')
    .border({ width: 1, color: '#D8E1F2', radius: 18 })
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
                              this.updateDualCell(i, j, 0, v, allowDiagonalEdit);
                            } else {
                              this.updateStandardCell(i, j, 0, v);
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
                                this.updateDualCell(i, j, 0, v, allowDiagonalEdit);
                              } else {
                                this.updateStandardCell(i, j, 0, v);
                              }
                            })
                          TextInput({ text: isDual ? this.eb[i][j] : this.qb[i][j] })
                            .width(48)
                            .height(32)
                            .enabled(i < j)
                            .onChange((v: string) => {
                              if (isDual) {
                                this.updateDualCell(i, j, 1, v, allowDiagonalEdit);
                              } else {
                                this.updateStandardCell(i, j, 1, v);
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
                                this.updateDualCell(i, j, 2, v, allowDiagonalEdit);
                              } else {
                                this.updateStandardCell(i, j, 2, v);
                              }
                            })
                          TextInput({ text: isDual ? this.ed[i][j] : this.qd[i][j] })
                            .width(48)
                            .height(32)
                            .enabled(i < j)
                            .onChange((v: string) => {
                              if (isDual) {
                                this.updateDualCell(i, j, 3, v, allowDiagonalEdit);
                              } else {
                                this.updateStandardCell(i, j, 3, v);
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
        Column({ space: 14 }) {
          this.buildHeader()

          Column({ space: 4 }) {
            Text('在这里输入拉普拉斯矩阵，系统会根据三项条件给出可行性判定。')
              .fontSize(14)
              .fontColor('#5B657A')
              .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#F7F9FF')
          .border({ width: 1, color: '#D8E1F2', radius: 18 })

          Row({ space: 8 }) {
            Text('矩阵阶数 (2~8)')
              .fontSize(14)
            TextInput({ text: this.n.toString() })
              .width(80)
              .onChange((v: string) => this.updateN(v))
          }
          .width('100%')

          Column({ space: 8 }) {
            Row({ space: 8 }) {
              Button('自动回填对角度数')
                .type(ButtonType.Capsule)
                .onClick(() => this.autoFillDegrees())
              Button('平衡样例')
                .type(ButtonType.Capsule)
                .onClick(() => this.fillBalancedExample())
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)

            Row({ space: 8 }) {
              Button('非平衡样例')
                .type(ButtonType.Capsule)
                .onClick(() => this.fillUnbalancedExample())
              Button('随机填充')
                .type(ButtonType.Capsule)
                .onClick(() => this.randomizeJudgeMatrix())
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)

            Row({ space: 8 }) {
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
            '主对角仅录入节点度数；非对角录入单位增益负值的标准部，整体需满足 L = D - A(Φ)。',
            false,
            true
          )
          this.buildMatrixSection(
            '拉普拉斯矩阵对偶部',
            '非对角录入单位增益负值的对偶部；主对角对偶部应为 0，因此这里固定为不可编辑。',
            true,
            false
          )

          Button('计算并判定')
            .height(42)
            .backgroundColor('#1E429F')
            .fontColor('#FFFFFF')
            .borderRadius(24)
            .onClick(() => this.runJudge())

          this.buildHistorySection()

          Column({ space: 12 }) {
            Row() {
              Text('判定结果')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#183153')
              Blank()
              this.buildInfoButton('可行性判定说明', '这里会根据三个条件判断目标相对构型是否可行。只有三条条件同时成立时，结果才会显示为可行。')
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
            .height('72%')
            .width('100%')

            Row() {
              Blank()
              Button('关闭')
                .type(ButtonType.Capsule)
                .onClick(() => this.closeOverlay())
            }
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
