import SwiftUI
import Charts

// 首页视图
// 核心业务：展示资产概览、快捷入口和近期账单
// 交互设计：采用垂直滚动布局，配合水平滚动的快捷操作区
struct HomeView: View {
    @Environment(ModelData.self) var modelData
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 资产卡片
                // UI组件：位于顶部的核心数据展示，使用玻璃拟态背景
                AssetCard()
                    .padding(.horizontal)
                
                // 快捷功能卡片
                // 交互设计：水平滚动区域，支持动态扩展功能入口
                HStack(spacing: 0) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 30) {
                            // 记账入口
                            NavigationLink(value: "addTransaction") {
                                VStack(spacing: 8) {
                                    ZStack {
                                        // 图标背景光晕
                                        Circle()
                                            .fill(Color.wechatGreen.opacity(0.1))
                                            .frame(width: 48, height: 48)
                                        
                                        // Native Feature: 使用 SF Symbols 5.0 的 symbolEffect 实现弹性动画
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(.wechatGreen)
                                            .symbolEffect(.bounce, value: true)
                                    }
                                    
                                    Text("记账")
                                        .font(.system(size: 12))
                                        .foregroundColor(.neonTextPrimary)
                                }
                                .frame(width: 70)
                            }
                            .buttonStyle(GlassButtonStyle.glass)
                            
                            QuickActionButton(
                                icon: "arrow.up.arrow.down.circle.fill",
                                label: "转账",
                                color: .wechatBlue,
                                action: {}
                            )
                            
                            QuickActionButton(
                                icon: "chart.pie.fill",
                                label: "统计",
                                color: .wechatOrange,
                                action: {}
                            )
                            
                            QuickActionButton(
                                icon: "qrcode.viewfinder",
                                label: "收付款",
                                color: .wechatPurple,
                                action: {}
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                // 账单列表
                VStack(spacing: 16) {
                    HStack {
                        Text("本月收支")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.neonTextPrimary)
                        
                        Spacer()
                        
                        Button("查看全部") {}
                            .font(.system(size: 14))
                            .foregroundColor(.wechatBlue)
                    }
                    .padding(.horizontal, 20)
                    
                    // 账单图表
                    // Native Feature: 使用 Swift Charts 框架绘制原生图表
                    if #available(iOS 16.0, *) {
                        Chart {
                            // 使用 BarMark 绘制柱状图，支持声明式数据绑定
                            BarMark(
                                x: .value("类别", "早餐"),
                                y: .value("金额", 0)
                            )
                            .foregroundStyle(Color.wechatGreen)
                            
                            BarMark(
                                x: .value("类别", "交通"),
                                y: .value("金额", 11)
                            )
                            .foregroundStyle(Color.wechatRed)
                            
                            BarMark(
                                x: .value("类别", "午餐"),
                                y: .value("金额", 25)
                            )
                            .foregroundStyle(Color.wechatRed)
                            
                            BarMark(
                                x: .value("类别", "工资"),
                                y: .value("金额", 10000)
                            )
                            .foregroundStyle(Color.wechatGreen)
                        }
                        .frame(height: 200)
                        .padding(20)
                        // UI Style: 应用自定义玻璃拟态效果，提升视觉层级
                        .glassEffect(Glass.regular, in: RoundedRectangle(cornerRadius: 24))
                        .padding(.horizontal, 15)
                    }
                    
                    // 示例列表
                    // 性能优化：使用 LazyVStack 实现列表的按需加载
                    LazyVStack(spacing: 12) {
                        TransactionItem(
                            icon: "fork.knife",
                            category: "午餐",
                            subcategory: "餐饮",
                            amount: "-¥ 25.00",
                            note: "麦当劳",
                            amountColor: .wechatRed
                        )
                        
                        TransactionItem(
                            icon: "bus.fill",
                            category: "交通",
                            subcategory: "地铁",
                            amount: "-¥ 5.00",
                            note: "上班",
                            amountColor: .wechatRed
                        )
                        
                         TransactionItem(
                            icon: "briefcase.fill",
                            category: "工资",
                            subcategory: "收入",
                            amount: "+¥ 10,000.00",
                            note: "12月工资",
                            amountColor: .wechatGreen
                        )
                    }
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
    }
}
