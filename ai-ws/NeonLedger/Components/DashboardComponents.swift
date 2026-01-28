import SwiftUI

// MARK: - Dashboard Components

// 资产卡片
struct AssetCard: View {
    @State private var selectedTimeFrame = "month"
    
    var body: some View {
        VStack {
            // 卡片标题和时间维度切换
            HStack {
                Text("总资产")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.neonTextPrimary)
                
                Spacer()
                
                // 时间维度切换按钮组
                HStack(spacing: 10) {
                    TimeFrameButton(label: "日", isSelected: selectedTimeFrame == "day", action: { selectedTimeFrame = "day" })
                    TimeFrameButton(label: "周", isSelected: selectedTimeFrame == "week", action: { selectedTimeFrame = "week" })
                    TimeFrameButton(label: "月", isSelected: selectedTimeFrame == "month", action: { selectedTimeFrame = "month" })
                }
            }
            .padding(.bottom, 20)
            
            // 资产金额
            Text("¥ 12,345.67")
                .font(.system(size: 42, weight: .bold))
                .foregroundColor(.neonTextPrimary)
            
            // 收支统计
            HStack {
                StatItem(label: "收入", value: "¥ 8,901.23", color: .wechatGreen)
                Spacer()
                StatItem(label: "支出", value: "¥ 4,567.89", color: .wechatRed)
            }
            .padding(.top, 20)
        }
        .padding(24)
        .glassEffect(Glass.regular, in: RoundedRectangle(cornerRadius: 24))
    }
}

// 时间维度切换按钮
struct TimeFrameButton: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .neonPrimary : .neonTextSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(isSelected ? Color.neonPrimary.opacity(0.1) : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(isSelected ? Color.neonPrimary : Color.clear, lineWidth: 1)
                        )
                )
        }
    }
}

// 统计项
struct StatItem: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.neonTextSecondary)
            Text(value)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(color)
        }
    }
}

// 快捷操作按钮
struct QuickActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    // 图标背景光晕
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                        .symbolEffect(.bounce, value: true) // iOS 17+ Symbol Effect
                }
                
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(.neonTextPrimary)
            }
            .frame(width: 70)
        }
        .buttonStyle(GlassButtonStyle.glass) // 使用新的玻璃按钮样式
    }
}

// 隐私模式下的操作按钮
struct EncryptedActionButton: View {
    let icon: String
    let label: String
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(.neonTextSecondary)
                
                Text(label)
                    .font(.system(size: 16))
                    .foregroundColor(.neonTextPrimary)
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(GlassButtonStyle.glass)
    }
}

// 账单交易项
struct TransactionItem: View {
    let icon: String
    let category: String
    let subcategory: String
    let amount: String
    let note: String
    let amountColor: Color
    
    var body: some View {
        HStack {
            // 分类图标
            ZStack {
                Circle()
                    .fill(Color.wechatGreen.opacity(0.2))
                    .frame(width: 45, height: 45)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(.wechatGreen)
            }
            
            // 分类信息
            VStack(alignment: .leading) {
                HStack {
                    Text(category)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.neonTextPrimary)
                    
                    if !subcategory.isEmpty {
                        Text(subcategory)
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.wechatGreen)
                            .cornerRadius(8)
                            .padding(.leading, 8)
                    }
                }
                
                if !note.isEmpty {
                    Text(note)
                        .font(.system(size: 14))
                        .foregroundColor(.neonTextSecondary)
                        .padding(.top, 2)
                }
            }
            .padding(.leading, 15)
            
            Spacer()
            
            // 金额
            Text(amount)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(amountColor)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .glassEffect(Glass.regular.tint(Color.neonSurface), in: RoundedRectangle(cornerRadius: 16)) // 为每个项目添加玻璃背景
    }
}
