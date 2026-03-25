import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  @Builder
  private buildHeroCard() {
    Column({ space: 14 }) {
      Text('EigenFleet')
        .fontSize(36)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .width('100%')
        .textAlign(TextAlign.Center)

      Text('对偶四元数矩阵谱分析与编队可行性判定工具')
        .fontSize(16)
        .fontColor('#DCE7FF')
        .width('100%')
        .textAlign(TextAlign.Center)

      Text('提供特征值计算、特征向量查看和连通图可行性判定。')
        .fontSize(13)
        .fontColor('#C7D5F4')
        .lineHeight(22)
        .textAlign(TextAlign.Center)
        .width('100%')
    }
    .width('100%')
    .padding({ top: 28, right: 20, bottom: 28, left: 20 })
    .backgroundColor('#16367C')
    .borderRadius(28)
  }

  @Builder
  private buildEntryCard(title: string, subtitle: string, accent: string, targetUrl: string) {
    Button() {
      Column({ space: 10 }) {
        Text(title)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#102A56')
          .width('100%')
          .textAlign(TextAlign.Start)
        Text(subtitle)
          .fontSize(14)
          .lineHeight(22)
          .fontColor('#4E5D78')
          .width('100%')
          .textAlign(TextAlign.Start)
        Row() {
          Text('进入功能')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(accent)
          Blank()
          Text('>')
            .fontSize(18)
            .fontColor(accent)
        }
        .width('100%')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({ top: 22, right: 20, bottom: 22, left: 20 })
    }
    .width('100%')
    .backgroundColor('#F7F9FF')
    .border({ width: 1.5, color: '#D8E1F2', radius: 24 })
    .onClick(() => router.pushUrl({ url: targetUrl }))
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 18 }) {
          Blank()
            .height(12)

          this.buildHeroCard()

          this.buildEntryCard(
            '特征值计算',
            '输入对偶四元数 Hermitian 矩阵，计算全部特征值并查看对应特征向量。',
            '#2452A5',
            'pages/EigenPage'
          )

          this.buildEntryCard(
            '可行性判定',
            '输入 DQUGG 拉普拉斯矩阵，根据三项条件判断目标相对构型是否可行。',
            '#0E7A53',
            'pages/FeasibilityPage'
          )

          Row() {
            Blank()
            Text('beta1.5')
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor('#667085')
          }
          .width('100%')
          .padding({ top: 4, bottom: 16 })
        }
        .width('100%')
        .padding(18)
      }
      .scrollable(ScrollDirection.Vertical)
      .width('100%')
      .height('100%')
      .backgroundColor('#EEF3FB')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#EEF3FB')
  }
}
