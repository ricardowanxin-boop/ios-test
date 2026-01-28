import SwiftUI
import Charts

struct HomeView: View {
    @Environment(ModelData.self) var modelData
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 资产卡片
                AssetCard()
                    .padding(.horizontal)
                
                // 快捷功能卡片
                HStack(spacing: 0) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 30) {
                            NavigationLink(value: "addTransaction") {
                                VStack(spacing: 8) {
                                    ZStack {
                                        // 图标背景光晕
                                        Circle()
                                            .fill(Color.wechatGreen.opacity(0.1))
                                            .frame(width: 48, height: 48)
                                        
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
                    if #available(iOS 16.0, *) {
                        Chart {
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
                        .glassEffect(Glass.regular, in: RoundedRectangle(cornerRadius: 24))
                        .padding(.horizontal, 15)
                    }
                    
                    // 示例列表
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
