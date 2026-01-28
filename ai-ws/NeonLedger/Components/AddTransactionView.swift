import SwiftUI

// 记账输入界面
struct AddTransactionView: View {
    @State private var amount = ""
    @State private var category = ""
    @State private var note = ""
    @State private var currentStep = 0 // 0: 金额输入, 1: 分类选择, 2: 确认
    @State private var showGlitch = false
    @State private var selectedCategory: TransactionCategory?
    
    let onComplete: () -> Void
    
    // 消费分类枚举
    enum TransactionCategory: String, CaseIterable {
        case food = "餐饮"
        case transportation = "交通"
        case entertainment = "娱乐"
        case shopping = "购物"
        case housing = "住房"
        case utilities = "水电"
        case health = "医疗"
        case education = "教育"
    }
    
    var body: some View {
        GlassEffectContainer {
            // 底部表单面板 - 适配新设计
            VStack(spacing: 0) {
                // 主要内容区域
                ScrollView {
                    VStack(spacing: 30) {
                        // 步骤指示器
                        StepIndicator(currentStep: currentStep)
                        
                        // 金额输入区
                        if currentStep == 0 {
                            AmountInputSection(
                                amount: $amount,
                                note: $note,
                                onNext: {
                                    withAnimation {
                                        currentStep = 1
                                    }
                                }
                            )
                        }
                        
                        // 分类选择区
                        if currentStep == 1 {
                            CategorySelectionSection(
                                selectedCategory: $selectedCategory,
                                onNext: {
                                    withAnimation {
                                        currentStep = 2
                                    }
                                },
                                onPrevious: {
                                    withAnimation {
                                        currentStep = 0
                                    }
                                }
                            )
                        }
                        
                        // 数据确认区
                        if currentStep == 2 {
                            DataConfirmationSection(
                                amount: amount,
                                category: selectedCategory?.rawValue ?? "",
                                onComplete: {
                                    // 直接完成，简化流程
                                    withAnimation {
                                        onComplete()
                                    }
                                },
                                onPrevious: {
                                    withAnimation {
                                        currentStep = 1
                                    }
                                }
                            )
                        }
                    }
                    .padding(20)
                }
            }
        }
        .ignoresSafeArea()
    }
}

// 步骤指示器 - 微信风格
struct StepIndicator: View {
    let currentStep: Int
    
    var body: some View {
        HStack(spacing: 15) {
            StepDot(isActive: currentStep >= 0, label: "金额")
            StepLine(isActive: currentStep >= 1)
            StepDot(isActive: currentStep >= 1, label: "分类")
            StepLine(isActive: currentStep >= 2)
            StepDot(isActive: currentStep >= 2, label: "确认")
        }
        .padding(.vertical, 20)
    }
}

// 步骤点 - 微信风格
struct StepDot: View {
    let isActive: Bool
    let label: String
    
    var body: some View {
        VStack {
            Circle()
                .fill(isActive ? Color.neonPrimary : Color.neonTextTertiary)
                .frame(width: 16, height: 16)
                .shadow(color: isActive ? Color.neonPrimary.opacity(0.4) : Color.clear, radius: 4, x: 0, y: 2)
            
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(isActive ? .neonPrimary : .neonTextTertiary)
                .padding(.top, 5)
        }
    }
}

// 步骤连接线 - 适配新设计
struct StepLine: View {
    let isActive: Bool
    
    var body: some View {
        Rectangle()
            .fill(isActive ? Color.neonPrimary : Color.neonTextTertiary.opacity(0.3))
            .frame(height: 2)
    }
}

// 金额输入区域 - 微信风格
struct AmountInputSection: View {
    @Binding var amount: String
    @Binding var note: String
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            // 金额输入框 - 适配新设计
            TextField("0.00", text: $amount)
                .font(.system(size: 64, weight: .bold))
                .foregroundColor(.neonTextPrimary)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .padding()
                .glassEffect(Glass.regular, in: RoundedRectangle(cornerRadius: 24))
            
            // 货币符号 - 适配新设计
            Text("人民币 (CNY)")
                .font(.system(size: 16))
                .foregroundColor(.neonTextSecondary)
            
            // 备注输入 - 适配新设计
            TextField("添加备注 (可选)", text: $note)
                .font(.system(size: 16))
                .foregroundColor(.neonTextPrimary)
                .padding()
                .glassEffect(Glass.regular, in: RoundedRectangle(cornerRadius: 24))
            
            // 下一步按钮 - 适配新设计
            WechatButton(
                title: "下一步",
                action: onNext,
                color: .neonPrimary
            )
        }
    }
}

// 分类选择区域 - 微信风格
struct CategorySelectionSection: View {
    @Binding var selectedCategory: AddTransactionView.TransactionCategory?
    let onNext: () -> Void
    let onPrevious: () -> Void
    
    // 分类数据 - 适配新设计
    let categories: [(category: AddTransactionView.TransactionCategory, icon: String, color: Color)] = [
        (.food, "fork.knife", .neonPrimary),
        (.transportation, "car.fill", .neonAccent),
        (.entertainment, "gamecontroller.fill", .neonSecondary),
        (.shopping, "bag.fill", .neonAccent),
        (.housing, "house.fill", .neonPrimary),
        (.utilities, "bolt.fill", .neonSecondary),
        (.health, "heart.fill", .neonAccent),
        (.education, "book.fill", .neonPrimary)
    ]
    
    var body: some View {
        VStack(spacing: 30) {
            // 分类网格
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 4), spacing: 20) {
                ForEach(categories, id: \.category) { item in
                    CategoryButton(
                        category: item.category,
                        icon: item.icon,
                        color: item.color,
                        isSelected: selectedCategory == item.category,
                        action: {
                            withAnimation {
                                selectedCategory = item.category
                            }
                        }
                    )
                }
            }
            
            // 按钮组 - 微信风格
            HStack(spacing: 20) {
                WechatButton(
                    title: "上一步",
                    action: onPrevious,
                    color: .neonTextSecondary
                )
                .frame(maxWidth: .infinity)
                
                WechatButton(
                    title: "下一步",
                    action: onNext,
                    color: .neonPrimary
                )
                .frame(maxWidth: .infinity)
            }
        }
    }
}

// 分类按钮 - 微信风格
struct CategoryButton: View {
    let category: AddTransactionView.TransactionCategory
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action)
            {
                VStack(spacing: 10) {
                    // 分类图标 - 微信风格
                    ZStack {
                        Circle()
                            .fill(isSelected ? color.opacity(0.2) : Color.wechatLightBackground)
                            .frame(width: 72, height: 72)
                        
                        Image(systemName: icon)
                            .font(.system(size: 32))
                            .foregroundColor(color)
                    }
                    
                    // 分类名称 - 微信风格
                    Text(category.rawValue)
                        .font(.system(size: 14))
                        .foregroundColor(.wechatBlack)
                }
            }
    }
}

// 数据确认区域 - 微信风格
struct DataConfirmationSection: View {
    let amount: String
    let category: String
    let onComplete: () -> Void
    let onPrevious: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            // 交易详情卡片 - 适配新设计
            VStack(spacing: 20) {
                DetailItem(label: "金额", value: "¥ \(amount)")
                DetailItem(label: "分类", value: category)
                DetailItem(label: "日期", value: getCurrentDate())
            }
            .padding(30)
            .glassEffect(Glass.regular, in: RoundedRectangle(cornerRadius: 24))
            
            // 按钮组 - 适配新设计
            HStack(spacing: 20) {
                WechatButton(
                    title: "上一步",
                    action: onPrevious,
                    color: .neonTextSecondary
                )
                .frame(maxWidth: .infinity)
                
                WechatButton(
                    title: "确认",
                    action: onComplete,
                    color: .neonPrimary
                )
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    // 获取当前日期
    private func getCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}

// 详情项 - 微信风格
struct DetailItem: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 16))
                .foregroundColor(.wechatGray)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.wechatBlack)
        }
    }
}

// 玻璃风格按钮
struct WechatButton: View {
    let title: String
    let action: () -> Void
    let color: Color
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .glassEffect(Glass.regular.tint(color).interactive(), in: Capsule())
        }
        .buttonStyle(.plain)
    }
}
