import SwiftUI
import Observation

enum AppScreen: Hashable, Identifiable, CaseIterable {
    case home
    case stats
    case assets
    case profile
    case ai
    
    var id: AppScreen { self }
    
    var name: String {
        switch self {
        case .home: return "首页"
        case .stats: return "统计"
        case .assets: return "资产"
        case .profile: return "我的"
        case .ai: return "AI"
        }
    }
    
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

struct NeonLedgerAppView: View {
    @State private var modelData = ModelData()
    @State private var selectedScreen: AppScreen = .home
    @State private var path: [String] = []

    var body: some View {
        GlassEffectContainer {
            ZStack(alignment: .bottom) {
                // Main Content
                NavigationStack(path: $path) {
                    // 始终以 Home 为根视图，确保二级页面能返回到首页
                    ScreenContent(screen: .home, onSwitchToHome: {
                        selectedScreen = .home
                        path = []
                    })
                    .navigationDestination(for: String.self) { destination in
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
                            VStack {
                                Text("统计功能开发中...")
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .glassEffect(Glass.regular, in: Capsule())
                            .padding()
                            .navigationTitle("统计")
                        } else if destination == "assets" {
                            VStack {
                                Text("资产管理功能开发中...")
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .glassEffect(Glass.regular, in: Capsule())
                            .padding()
                            .navigationTitle("资产")
                        } else if destination == "profile" {
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
                .padding(.bottom, 80) // 始终保留底部空间给导航栏
                // 监听 path 变化，当返回首页时重置选中状态
                .onChange(of: path) { newPath in
                    if newPath.isEmpty {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.65, blendDuration: 0.5)) {
                            selectedScreen = .home
                        }
                    } else if let last = newPath.last {
                        // 支持从子页面手势返回时更新 Tab 状态（可选，视需求而定，目前保持 Home 逻辑即可）
                        // 如果希望在子页面返回时 Tab 也能跟随变化，可以在这里添加逻辑
                        // 但由于 Tab 是 push 模式，保持对应 Tab 高亮通常更好
                        switch last {
                        case "assistant": selectedScreen = .ai
                        case "stats": selectedScreen = .stats
                        case "assets": selectedScreen = .assets
                        case "profile": selectedScreen = .profile
                        default: break
                        }
                    }
                }

                // Custom Tab Bar
                CustomTabBar(selectedScreen: $selectedScreen, onNavigate: { screen in
                     if screen == "home" {
                         path = []
                     } else {
                         path = [screen]
                     }
                })
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .environment(modelData)
    }
}

struct CustomTabBar: View {
    @Binding var selectedScreen: AppScreen
    var onNavigate: (String) -> Void
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppScreen.allCases, id: \.self) { screen in
                Button(action: {
                    handleTabSelection(screen)
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: screen.icon)
                            .font(.system(size: 20, weight: .medium))
                            .symbolEffect(.bounce, value: selectedScreen == screen)
                        
                        Text(screen.name)
                            .font(.system(size: 10, weight: .medium))
                    }
                    // 交互细节：图标颜色渐变
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
                        : AnyShapeStyle(Color.black.opacity(0.7)) // 未选中态深色
                    )
                    .scaleEffect(selectedScreen == screen ? 1.15 : 1.0)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                    .background {
                        if selectedScreen == screen {
                            ActiveTabIndicator()
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
        // 阴影：添加弥散阴影，营造悬浮感
        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
        .frame(height: 80) // 限制高度，防止动画变形
    }
    
    private func handleTabSelection(_ screen: AppScreen) {
        // 1. 触发选中动画
        // 优化：加快响应速度 (response: 0.3)，减少阻尼感，让交互更"跟手"
        withAnimation(.spring(response: 0.3, dampingFraction: 0.75, blendDuration: 0.2)) {
            selectedScreen = screen
        }
        
        // 2. 执行导航逻辑
        // 优化：移除人为延迟，立即响应用户点击，解决"不跟手"的问题
        navigate(to: screen)
    }
    
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

// 独立的活跃 Tab 指示器视图，优化渲染性能
struct ActiveTabIndicator: View {
    var body: some View {
        Capsule()
            .fill(
                // 液态流动：使用流光渐变
                LinearGradient(
                    colors: [
                        Color(red: 0.0, green: 0.48, blue: 1.0).opacity(0.15), // 浅蓝光晕
                        Color(red: 0.0, green: 0.48, blue: 1.0).opacity(0.02)  // 渐隐
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                // 形状变形与高光：模拟玻璃表面张力
                Capsule()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.6), // 强烈的高光
                                Color.white.opacity(0.1),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .background(
                // 添加模糊层增强玻璃质感
                Capsule()
                    .fill(.ultraThinMaterial)
                    .opacity(0.5)
            )
            // 性能优化：移除 .blendMode(.hardLight) 以减少离屏渲染开销
            // 性能优化：移除额外的 shadow，减少渲染压力
    }
}

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
            VStack {
                Text("统计功能开发中...")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .glassEffect(Glass.regular, in: Capsule())
            .padding()
            .navigationTitle("统计")
        case .assets:
            VStack {
                Text("资产管理功能开发中...")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .glassEffect(Glass.regular, in: Capsule())
            .padding()
            .navigationTitle("资产")
        case .profile:
            VStack {
                Text("个人中心功能开发中...")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .glassEffect(Glass.regular, in: Capsule())
            .padding()
            .navigationTitle("我的")
        case .ai:
            SmartAssistantView(onClose: {
                withAnimation {
                    onSwitchToHome()
                }
            })
            .navigationBarHidden(true)
        }
    }
}
