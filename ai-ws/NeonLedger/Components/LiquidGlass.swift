import SwiftUI

// MARK: - Liquid Glass API

public enum GlassVariant {
    case regular
    case clear
    case identity
}

public struct Glass {
    let variant: GlassVariant
    var color: Color?
    var isInteractive: Bool = false
    
    public static let regular = Glass(variant: .regular)
    public static let clear = Glass(variant: .clear)
    public static let identity = Glass(variant: .identity)
    
    public func tint(_ color: Color) -> Glass {
        var copy = self
        copy.color = color
        return copy
    }
    
    public func interactive() -> Glass {
        var copy = self
        copy.isInteractive = true
        return copy
    }
}

// MARK: - Glass Effect Container
/// 必须使用 GlassEffectContainer 作为顶层容器，包裹一组玻璃质感的元素。
/// 该容器负责提供统一的光照环境和背景模糊。
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
            LinearGradient(
                colors: [
                    Color.neonPrimary.opacity(0.15),
                    Color.neonSecondary.opacity(0.1),
                    Color.neonAccent.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .blur(radius: 60)
            
            content
        }
    }
}


// MARK: - Modifiers

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
                        if glass.variant == .regular {
                            if #available(iOS 15.0, *) {
                                Rectangle()
                                    .fill(.ultraThickMaterial) // 指南推荐 ultraThickMaterial
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
                        if let color = glass.color {
                            color.opacity(0.12)
                        }
                        
                        // 3. 柔和光感 (Soft Lighting) - 模拟高光与折射
                        LinearGradient(
                            colors: [
                                .white.opacity(colorScheme == .dark ? 0.25 : 0.6),
                                .white.opacity(0.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .blendMode(.overlay)
                    }
                    .clipShape(shape)
                }
                // 4. 光影边框 (Light Border)
                .overlay {
                    shape
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    .white.opacity(colorScheme == .dark ? 0.4 : 0.7),
                                    .white.opacity(0.1),
                                    .clear,
                                    .black.opacity(colorScheme == .dark ? 0.2 : 0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                        .blendMode(.overlay)
                }
                // 5. 弥散阴影 (Diffuse Shadow)
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
struct GlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .glassEffect(configuration.isPressed ? .regular.tint(.neonPrimary) : .regular, in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == GlassButtonStyle {
    static var glass: GlassButtonStyle { GlassButtonStyle() }
}
