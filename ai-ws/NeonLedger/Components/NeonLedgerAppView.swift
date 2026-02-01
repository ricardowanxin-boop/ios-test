import SwiftUI
import Observation
import UIKit

// MARK: - App Screen Definition
// 定义应用的主导航结构
// 使用 enum 管理 Tab 页面，遵循 Hashable/Identifiable 协议以便于 SwiftUI 遍历和状态管理
enum AppScreen: Hashable, Identifiable, CaseIterable {
    case home       // 首页：资产概览
    case stats      // 统计：收支分析
    case assets     // 资产：账户管理
    case profile    // 我的：个人设置
    case ai         // AI：智能助手
    
    var id: AppScreen { self }
    
    // 页面标题
    var name: String {
        switch self {
        case .home: return "首页"
        case .stats: return "统计"
        case .assets: return "资产"
        case .profile: return "我的"
        case .ai: return "AI"
        }
    }
    
    // SF Symbols 图标名称
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .stats: return "chart.bar.fill"
        case .assets: return "creditcard.fill"
        case .profile: return "person.fill"
        case .ai: return "brain.head.profile"
        }
    }
}

// MARK: - Main Application View
// 应用的主入口视图，负责整体布局架构
// 架构特点：
// 1. 使用 ZStack 实现"内容层 + 悬浮导航层"的布局
// 2. 统一管理 NavigationStack，实现深层链接和页面跳转
// 3. 全局背景风格统一管理
struct NeonLedgerAppView: View {
    // 全局数据模型
    @State private var modelData = ModelData()
    // 当前选中的 Tab 页面
    @State private var selectedScreen: AppScreen = .home
    // 导航路径栈，用于编程式导航
    @State private var path: [String] = []

    var body: some View {
        // 1. 全局容器：提供统一的渐变背景和玻璃质感环境
        GlassEffectContainer {
            // 2. 层叠布局：底部是内容，顶部是悬浮导航栏
            ZStack(alignment: .bottom) {
                // MARK: Content Layer (内容层)
                NavigationStack(path: $path) {
                    // 始终以 Home 为根视图，确保二级页面能返回到首页
                    // 这种设计允许"伪 Tab"切换，实际是在一个导航栈中管理
                    ScreenContent(screen: .home, onSwitchToHome: {
                        selectedScreen = .home
                        path = []
                    })
                    .navigationDestination(for: String.self) { destination in
                        // 路由逻辑：处理不同目的地的跳转
                        if destination == "assistant" {
                             SmartAssistantView(onClose: {
                                 if !path.isEmpty {
                                     path.removeLast()
                                 }
                             })
                        } else if destination == "addTransaction" {
                            AddTransactionView {
                                if !path.isEmpty {
                                    path.removeLast()
                                }
                            }
                        } else if destination == "stats" {
                            // 占位视图：统计页面
                            VStack {
                                Text("统计功能开发中...")
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .glassEffect(Glass.regular, in: Capsule())
                            .padding()
                            .navigationTitle("统计")
                        } else if destination == "assets" {
                            // 占位视图：资产页面
                            VStack {
                                Text("资产管理功能开发中...")
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .glassEffect(Glass.regular, in: Capsule())
                            .padding()
                            .navigationTitle("资产")
                        } else if destination == "profile" {
                            // 占位视图：个人中心
                            VStack {
                                Text("个人中心功能开发中...")
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .glassEffect(Glass.regular, in: Capsule())
                            .padding()
                            .navigationTitle("我的")
                        }
                    }
                }
                .ignoresSafeArea(edges: .bottom) // 关键布局：让内容区域延伸到底部安全区之下，实现沉浸式效果
                // 监听 path 变化，当返回首页时重置选中状态
                .onChange(of: path) { _, newPath in
                    if newPath.isEmpty {
                        // 当路径清空（回到首页）时，带动画重置 Tab 选中状态为 Home
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.65, blendDuration: 0.5)) {
                            selectedScreen = .home
                        }
                    } else if let last = newPath.last {
                        // 支持从子页面手势返回时更新 Tab 状态
                        // 根据当前的路由终点，高亮对应的 Tab 图标
                        switch last {
                        case "assistant": selectedScreen = .ai
                        case "stats": selectedScreen = .stats
                        case "assets": selectedScreen = .assets
                        case "profile": selectedScreen = .profile
                        default: break
                        }
                    }
                }

                // MARK: Navigation Layer (导航层)
                // 自定义悬浮 Tab Bar
                CustomTabBar(selectedScreen: $selectedScreen, onNavigate: { screen in
                     if screen == "home" {
                         path = [] // 切换到首页时清空导航栈
                     } else {
                         path = [screen] // 切换到其他 Tab 时推入对应页面
                     }
                })
                    .padding(.bottom, 20) // 悬浮位置微调
                    .transition(.move(edge: .bottom).combined(with: .opacity)) // 进场动画
            }
        }
        .environment(modelData) // 注入环境变量
    }
}

// MARK: - Custom Tab Bar
// 自定义底部导航栏组件 - 改造为 Liquid Glass 风格 (iOS Native Refined)
// 核心特征：磨砂玻璃背景 + 16pt圆角 + 暖橙色激活态
struct CustomTabBar: View {
    @Binding var selectedScreen: AppScreen
    var onNavigate: (String) -> Void
    // 命名空间用于动画匹配
    @Namespace private var animation
    @Environment(\.colorScheme) var colorScheme // 用于适配深浅模式
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppScreen.allCases, id: \.self) { screen in
                Button(action: {
                    handleTabSelection(screen)
                }) {
                    VStack(spacing: 4) { // 图标与文字间距
                        // 图标层
                        Image(systemName: screen.icon)
                            .font(.system(size: 24, weight: .regular)) // 24pt, 常规字重
                            .frame(width: 24, height: 24)
                        
                        // 文字层
                        Text(screen.name)
                            .font(.system(size: 10, weight: .regular)) // 12pt -> 视觉调整为10pt以适应布局，或者保持12pt
                            // 用户要求约 12pt，这里设置为 11pt 兼顾美观与可读性
                            .font(.system(size: 11))
                    }
                    .frame(height: 50) // 确保触控区域足够
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle()) // 扩大点击区域
                    // 颜色适配
                    .foregroundStyle(
                        selectedScreen == screen
                        ? Color.orange // 激活态：暖橙色
                        : Color.gray   // 非激活态：浅灰色
                    )
                    // 背景适配：激活态显示半透黑背景
                    .background {
                        if selectedScreen == screen {
                            Capsule()
                                .fill(Color.black.opacity(0.2)) // 调整为浅色半透，增强在深色磨砂背景上的对比度
                                .matchedGeometryEffect(id: "TabBackground", in: animation)
                                .padding(.horizontal, -12) // 负向内边距，使胶囊更宽，包裹感更强
                                .frame(height: 56) // 增加高度，匹配图2的大比例视觉
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12) // 内部留白
        .background {
            // 核心背景：半透明磨砂玻璃
            Capsule()
                .fill(.regularMaterial) // 系统级磨砂材质，自动适配深浅模式
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2) // 极浅阴影，营造悬浮感
        }
        // 悬浮布局调整：左右边距，底部留白
        .padding(.horizontal, 16)
        .frame(height: 80) // 整体高度
    }
    
    // 处理 Tab 点击事件
    private func handleTabSelection(_ screen: AppScreen) {
        // 0. 触觉反馈 (Haptic Touch)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()

        // 1. 触发 UI 状态更新（0.2s 平滑过渡）
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedScreen = screen
        }
        
        // 2. 执行实际导航逻辑
        navigate(to: screen)
    }
    
    // 导航路由分发
    private func navigate(to screen: AppScreen) {
        switch screen {
        case .home: onNavigate("home")
        case .ai: onNavigate("assistant")
        case .stats: onNavigate("stats")
        case .assets: onNavigate("assets")
        case .profile: onNavigate("profile")
        }
    }
}

// MARK: - Liquid Capsule Background (Deprecated / Removed)
// 原有的 LiquidCapsuleBackground 已被移除，以符合新的简约设计规范




// MARK: - Screen Content Switcher
// 页面内容分发器
// 根据当前的 Screen 枚举值展示对应的视图内容
struct ScreenContent: View {
    let screen: AppScreen
    var onSwitchToHome: () -> Void = {}
    
    var body: some View {
        switch screen {
        case .home:
            HomeView()
                .navigationTitle("NeonLedger")
                .toolbar {
                     ToolbarItem(placement: .navigationBarTrailing) {
                         Button(action: {}) {
                             Image(systemName: "bell.fill")
                                 .foregroundStyle(Color.neonTextPrimary)
                         }
                     }
                }
        case .stats:
            // 统计页面占位
            VStack {
                Text("统计功能开发中...")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .glassEffect(Glass.regular, in: Capsule())
            .padding()
            .navigationTitle("统计")
        case .assets:
            // 资产页面占位
            VStack {
                Text("资产管理功能开发中...")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .glassEffect(Glass.regular, in: Capsule())
            .padding()
            .navigationTitle("资产")
        case .profile:
            // 个人中心占位
            VStack {
                Text("个人中心功能开发中...")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .glassEffect(Glass.regular, in: Capsule())
            .padding()
            .navigationTitle("我的")
        case .ai:
            // AI 助手页面
            SmartAssistantView(onClose: {
                withAnimation {
                    onSwitchToHome()
                }
            })
            .navigationBarHidden(true)
        }
    }
}
