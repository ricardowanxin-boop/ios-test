import SwiftUI

// MARK: - Liquid Glass API
// 核心UI风格：定义了玻璃拟态（Glassmorphism）的配置参数

// 玻璃材质变体
public enum GlassVariant {
    case regular  // 标准磨砂玻璃（用于大多数卡片）
    case clear    // 高透玻璃（用于浮层）
    case identity // 无效果（用于特殊场景）
}

// 玻璃效果配置结构体
public struct Glass {
    let variant: GlassVariant
    var color: Color?          // 玻璃染色（Tint Color）
    var isInteractive: Bool = false // 是否支持交互（暂留接口）
    
    public static let regular = Glass(variant: .regular)
    public static let clear = Glass(variant: .clear)
    public static let identity = Glass(variant: .identity)
    
    // 链式调用：设置染色
    public func tint(_ color: Color) -> Glass {
        var copy = self
        copy.color = color
        return copy
    }
    
    // 链式调用：启用交互
    public func interactive() -> Glass {
        var copy = self
        copy.isInteractive = true
        return copy
    }
}

// MARK: - Glass Effect Container
/// 必须使用 GlassEffectContainer 作为顶层容器，包裹一组玻璃质感的元素。
/// 该容器负责提供统一的光照环境和背景模糊。
/// 设计原理：玻璃效果依赖于背景的复杂性，纯色背景无法体现磨砂质感。
public struct GlassEffectContainer<Content: View>: View {
    let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        ZStack {
            // 全局环境光/背景
            Color.neonBackground.ignoresSafeArea()
            
            // 液态流光背景效果
            // 使用大半径模糊（blur: 60）混合三种品牌色，创造出流动的极光背景
            LinearGradient(
                colors: [
                    Color.neonPrimary.opacity(0.15),   // 主色光晕
                    Color.neonSecondary.opacity(0.1),  // 辅助色光晕
                    Color.neonAccent.opacity(0.05)     // 强调色微光
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .blur(radius: 60) // 关键：高斯模糊融合颜色
            
            content
        }
    }
}


// MARK: - Modifiers

// 核心实现：液态玻璃修改器
// 通过多层 ZStack 叠加实现物理真实的玻璃质感
struct LiquidGlassModifier<S: InsettableShape>: ViewModifier {
    let glass: Glass
    let shape: S
    
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        if glass.variant == .identity {
            content
        } else {
            content
                .background {
                    ZStack {
                        // 1. 基础材质 (Material)
                        // 使用系统提供的 Material 实现高斯模糊和背景透视
                        if glass.variant == .regular {
                            if #available(iOS 15.0, *) {
                                Rectangle()
                                    .fill(.ultraThickMaterial) // 指南推荐 ultraThickMaterial，提供较强的遮盖力
                            } else {
                                Rectangle()
                                    .fill(.ultraThinMaterial)
                            }
                        } else {
                            if #available(iOS 15.0, *) {
                                Rectangle()
                                    .fill(.regularMaterial)
                            } else {
                                Rectangle()
                                    .fill(.thinMaterial)
                            }
                        }
                        
                        // 2. 染色 (Tint)
                        // 在磨砂层上叠加一层半透明品牌色，统一色调
                        if let color = glass.color {
                            color.opacity(0.12)
                        }
                        
                        // 3. 柔和光感 (Soft Lighting) - 模拟高光与折射
                        // 使用 Overlay 混合模式叠加渐变白光，模拟光源从左上角照射的效果
                        LinearGradient(
                            colors: [
                                .white.opacity(colorScheme == .dark ? 0.25 : 0.6), // 高光区
                                .white.opacity(0.0) // 暗部区
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .blendMode(.overlay) // 关键：叠加模式保留下层纹理
                    }
                    .clipShape(shape)
                }
                // 4. 光影边框 (Light Border)
                // 模拟玻璃边缘的反光和厚度感
                .overlay {
                    shape
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    .white.opacity(colorScheme == .dark ? 0.4 : 0.7), // 受光面边缘亮
                                    .white.opacity(0.1),
                                    .clear,
                                    .black.opacity(colorScheme == .dark ? 0.2 : 0.05) // 背光面边缘暗
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5 // 极细边框
                        )
                        .blendMode(.overlay)
                }
                // 5. 弥散阴影 (Diffuse Shadow)
                // 增加深度感，使卡片悬浮于背景之上
                .shadow(
                    color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.08),
                    radius: 12,
                    x: 0,
                    y: 6
                )
        }
    }
}

extension View {
    /// 应用液态玻璃材质
    /// - Parameters:
    ///   - glass: 玻璃样式配置
    ///   - shape: 形状
    func glassEffect<S: InsettableShape>(
        _ glass: Glass = .regular,
        in shape: S = Capsule()
    ) -> some View {
        modifier(LiquidGlassModifier(glass: glass, shape: shape))
    }
    
    /// 几何匹配 ID (用于玻璃元素的平滑过渡)
    func glassEffectID<ID: Hashable>(_ id: ID, in namespace: Namespace.ID) -> some View {
        self.matchedGeometryEffect(id: id, in: namespace)
    }
}

// MARK: - Button Style
// 交互组件：基于玻璃材质的按钮样式
struct GlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            // 交互反馈：按下时改变染色和缩放
            .glassEffect(configuration.isPressed ? .regular.tint(.neonPrimary) : .regular, in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == GlassButtonStyle {
    static var glass: GlassButtonStyle { GlassButtonStyle() }
}
