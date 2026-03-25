import { router } from '@kit.ArkUI';
import { EigenDisplayItem, solveDualQuaternionHermitianEigenvalues } from '../utils/EigenSolver';
import { EigenHistoryItem, initHistoryStorage, loadEigenHistory, saveEigenHistory } from '../utils/HistoryStore';
import {
  applyMatrixTextToGrid,
  createRandomHermitianGrid,
  createResetQuaternionGrid,
  formatTimeText,
  MatrixGridData,
  matrixTextFromGrid,
  updateGridCell
} from '../utils/MatrixPageSupport';

@Entry
@Component
struct EigenPage {
  @State n: number = 2;
  @State matrixInput: string = '';
  @State eigenMessage: string = '请输入矩阵后点击“计算全部特征值”。';
  @State eigenItems: EigenDisplayItem[] = [];
  @State showOverlay: boolean = false;
  @State overlayTitle: string = '';
  @State overlayText: string = '';
  @State historyExpanded: boolean = false;
  @State eigenHistory: EigenHistoryItem[] = [];
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
    this.applyGrid(createResetQuaternionGrid(2, '1'));
    this.clearResultState();
    this.closeOverlay();
  }

  private loadHistory() {
    this.eigenHistory = loadEigenHistory();
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
    this.eigenItems = [];
    this.eigenMessage = '请输入矩阵后点击“计算全部特征值”。';
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
      this.applyGrid(createResetQuaternionGrid(nextN, '1'));
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

  private fillCurrentExample() {
    this.applyGrid(createRandomHermitianGrid(this.n));
    this.clearResultState();
  }

  private saveHistory(items: EigenDisplayItem[]) {
    let topEigenText: string = '';
    for (let i = 0; i < items.length; i++) {
      if (i > 0) {
        topEigenText += '\n';
      }
      topEigenText += `λ${i + 1}: ${items[i].lambdaText}`;
    }
    const timestamp: string = `${Date.now()}`;
    const item: EigenHistoryItem = new EigenHistoryItem(
      `eigen_${timestamp}`,
      timestamp,
      this.n,
      this.matrixInput,
      `已计算 ${items.length} 个特征值`,
      items.length,
      topEigenText
    );
    this.eigenHistory = saveEigenHistory(item);
  }

  private restoreHistory(item: EigenHistoryItem) {
    const data: MatrixGridData | null = applyMatrixTextToGrid(item.matrixText, item.n);
    if (data === null) {
      this.openOverlay('历史记录异常', '这条历史记录无法回填，可能是旧版本格式不兼容。');
      return;
    }
    this.n = item.n;
    this.applyGrid(data);
    this.matrixInput = item.matrixText;
    this.eigenItems = [];
    this.eigenMessage = '已从历史记录回填矩阵，请重新点击“计算全部特征值”。';
    this.closeOverlay();
  }

  private openHistorySummary(item: EigenHistoryItem) {
    const detail: string =
      `时间：${formatTimeText(item.timestamp)}\n` +
      `阶数：${item.n}\n` +
      `摘要：${item.resultSummary}\n\n` +
      `${item.topEigenText}`;
    this.openOverlay('历史记录摘要', detail);
  }

  private runEigen() {
    this.matrixInput = matrixTextFromGrid(this.currentGrid(), this.n);
    const result = solveDualQuaternionHermitianEigenvalues(this.matrixInput, this.n);
    if (!result.ok) {
      this.eigenItems = [];
      this.eigenMessage = `计算失败：${result.message}`;
      return;
    }
    this.eigenItems = result.items;
    this.eigenMessage = `已计算 ${result.items.length} 个特征值，数值统一保留 6 位小数。`;
    this.saveHistory(result.items);
  }

  @Builder
  private buildHeader() {
    Row({ space: 12 }) {
      Button('< 返回')
        .type(ButtonType.Capsule)
        .fontSize(14)
        .onClick(() => router.back())
      Column({ space: 2 }) {
        Text('特征值计算')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#17315E')
        Text('对偶四元数 Hermitian 矩阵谱分解')
          .fontSize(13)
          .fontColor('#667085')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
  }

  @Builder
  private buildResultCard(item: EigenDisplayItem) {
    Column({ space: 10 }) {
      Row() {
        Text(`特征值 ${item.index}`)
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
  private buildHistoryCard(item: EigenHistoryItem) {
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

      Text(item.resultSummary)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#183153')
        .width('100%')

      Text(item.topEigenText.length > 0 ? item.topEigenText : '该记录没有可展示的特征值摘要。')
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
        if (this.eigenHistory.length === 0) {
          Text('还没有成功计算的历史记录。')
            .fontSize(13)
            .fontColor('#667085')
            .width('100%')
        } else {
          Column({ space: 10 }) {
            ForEach(this.eigenHistory, (item: EigenHistoryItem) => {
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
            Text('在这里输入对偶四元数 Hermitian 矩阵，应用会计算全部特征值并展示对应特征向量。')
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
            Button('随机填充')
              .type(ButtonType.Capsule)
              .onClick(() => this.fillCurrentExample())
          }
          .width('100%')

          this.buildMatrixSection(
            '标准部',
            '主对角仅输入实部；其余输入 a,b,c,d，对应 1,i,j,k 分量；下三角会自动按 Hermitian 共轭联动。',
            false,
            true
          )
          this.buildMatrixSection(
            '对偶部',
            '主对角允许输入实部；其余输入 a,b,c,d，对应 1,i,j,k 分量；下三角同样自动联动。',
            true,
            true
          )

          Button('计算全部特征值')
            .height(42)
            .backgroundColor('#1E429F')
            .fontColor('#FFFFFF')
            .borderRadius(24)
            .onClick(() => this.runEigen())

          this.buildHistorySection()

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
                Text('计算成功后，这里会以卡片形式展示每个特征值与对应特征向量入口。')
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
