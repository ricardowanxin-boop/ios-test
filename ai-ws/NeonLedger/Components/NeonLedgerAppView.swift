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
                    .transition(.move(edge: .bottom).combined(with: .opacity)) // 进场动画
            }
        }
        .environment(modelData) // 注入环境变量
    }
}

// MARK: - Custom Tab Bar
// 自定义底部导航栏组件
// 特点：
// 1. 悬浮设计：不占据布局空间，悬浮在内容之上
// 2. 玻璃拟态：背景采用模糊和半透明效果
// 3. 交互动画：点击时的缩放、颜色渐变和背景滑块动画
struct CustomTabBar: View {
    @Binding var selectedScreen: AppScreen
    var onNavigate: (String) -> Void
    // 命名空间，用于 matchedGeometryEffect 实现滑块平滑移动动画
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppScreen.allCases, id: \.self) { screen in
                Button(action: {
                    handleTabSelection(screen)
                }) {
                    VStack(spacing: 4) {
                        // 图标层
                        Image(systemName: screen.icon)
                            .font(.system(size: 20, weight: .medium))
                            // iOS 17 新特性：符号动画，选中时弹跳
                            .symbolEffect(.bounce, value: selectedScreen == screen)
                        
                        // 文字层
                        Text(screen.name)
                            .font(.system(size: 10, weight: .medium))
                    }
                    // 交互视觉反馈：选中时使用渐变色，未选中时使用深色半透明
                    .foregroundStyle(
                        selectedScreen == screen
                        ? AnyShapeStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.0, green: 0.48, blue: 1.0), // 系统蓝
                                    Color(red: 0.0, green: 0.7, blue: 1.0)    // 亮青蓝
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        : AnyShapeStyle(Color.black.opacity(0.7))
                    )
                    // 选中放大效果
                    .scaleEffect(selectedScreen == screen ? 1.15 : 1.0)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle()) // 扩大点击热区
                    .background {
                        // 选中态背景指示器
                        if selectedScreen == screen {
                            ActiveTabIndicator()
                                // 关键动画：让背景块在不同 Tab 之间平滑流转
                                .matchedGeometryEffect(id: "ActiveTab", in: animation)
                        }
                    }
                }
            }
        }
        // 外部容器样式
        .padding(2)
        // 背景：应用自定义的 GlassEffect 毛玻璃材质
        .glassEffect(Glass.regular, in: Capsule())
        // 阴影：添加弥散阴影，营造悬浮感，提升层次感
        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 20)
        .padding(.bottom, 10) // 底部留白
        .frame(height: 80) // 固定高度，防止动画导致布局跳动
    }
    
    // 处理 Tab 点击事件
    private func handleTabSelection(_ screen: AppScreen) {
        // 0. 触觉反馈：提升交互质感
        // 使用 .light 风格模拟物理按键的清脆回弹感
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()

        // 1. 触发 UI 状态更新（动画）
        // 优化：加快响应速度 (response: 0.2)，减少阻尼感，让交互更"跟手"
        withAnimation(.spring(response: 0.2, dampingFraction: 0.45, blendDuration: 0.2)) {
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

// MARK: - Active Tab Indicator
// 独立的活跃 Tab 指示器视图，优化渲染性能
// 视觉设计：模拟液态玻璃胶囊，具有光晕和高光效果
struct ActiveTabIndicator: View {
    var body: some View {
        Capsule()
            .fill(
                // 液态流动感：使用流光渐变填充
                LinearGradient(
                    colors: [
                        Color(red: 0.0, green: 0.48, blue: 1.0).opacity(0.15), // 浅蓝光晕
                        Color(red: 0.0, green: 0.48, blue: 1.0).opacity(0.02)  // 边缘渐隐
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                // 玻璃边缘高光：模拟表面张力和反光
                Capsule()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.6), // 左上角强烈高光
                                Color.white.opacity(0.1),
                                Color.clear               // 右下角透明
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .background(
                // 磨砂质感：添加超薄材质背景
                Capsule()
                    .fill(.ultraThinMaterial)
                    .opacity(0.5)
            )
    }
}

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
