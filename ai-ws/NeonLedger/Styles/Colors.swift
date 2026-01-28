import SwiftUI

// 新版视觉设计系统
// 定义了全局通用的颜色语义，确保 Light/Dark 模式下的视觉一致性
struct NeonTheme {
    // 品牌主色：深空蓝，用于核心操作按钮、选中状态
    static let primary = Color(hex: "#165DFF")
    // 辅助色：浅金，用于VIP标识、次级强调
    static let secondary = Color(hex: "#F5D061")
    // 辅助色：活力橙，用于图表强调、警告提示
    static let accent = Color(hex: "#FF7D00")
    
    // 中性色（适配深色模式）
    // 自动适配系统外观设置，保证文本可读性
    static let textPrimary = Color("TextPrimary") // 需在 Assets 中定义，这里暂时使用系统自适应色
    static let textSecondary = Color("TextSecondary")
    
    // 语义化背景
    static let background = Color(uiColor: .systemGroupedBackground)
    static let surface = Color(uiColor: .secondarySystemGroupedBackground)
}

// 扩展 Color 以支持新设计系统，同时保留兼容性
extension Color {
    // MARK: - New Design System
    static let neonPrimary = NeonTheme.primary
    static let neonSecondary = NeonTheme.secondary
    static let neonAccent = NeonTheme.accent
    
    // 语义化颜色
    // Native Feature: 使用 UIColor 动态闭包适配深色模式 (Dark Mode)
    static let neonBackground = Color(uiColor: UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? UIColor(hex: "#000000")! : UIColor(hex: "#F7F8FA")!
    })
    
    static let neonSurface = Color(uiColor: UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? UIColor(hex: "#1C1C1E")! : UIColor(hex: "#FFFFFF")!
    })
    
    static let neonTextPrimary = Color(uiColor: .label)
    static let neonTextSecondary = Color(uiColor: .secondaryLabel)
    static let neonTextTertiary = Color(uiColor: .tertiaryLabel)
    
    // MARK: - Legacy Compatibility (Mapped to new system where appropriate)
    // 兼容旧版微信风格代码，将其映射到新的 Neon 设计系统
    // 主色调
    static let wechatWhite = Color(hex: "#FFFFFF") // 白色背景
    static let wechatGreen = neonPrimary // 替换为新主色
    static let wechatGray = neonTextPrimary // 替换为新文本色
    
    // 辅助色
    static let wechatLightGray = neonTextSecondary
    static let wechatLighterGray = neonTextTertiary
    static let wechatSeparator = Color(uiColor: .separator)
    static let wechatBackground = neonBackground
    static let wechatOrange = neonAccent
    
    // 中性色
    static let wechatBlack = Color(uiColor: .label)
    static let wechatDarkGray = neonTextSecondary
    static let wechatLightBackground = neonSurface
    
    // 功能色
    static let wechatRed = Color(hex: "#FF4D4F") // 优化后的红色
    static let wechatBlue = Color(hex: "#165DFF") // 优化后的蓝色
    static let wechatYellow = Color(hex: "#F5D061") // 优化后的黄色
    static let wechatPurple = Color(hex: "#722ED1") // 优化后的紫色
    
    // ... (Keep existing gradients if needed, but updated)
    static let wechatGreenGradient = Gradient(colors: [neonPrimary, neonPrimary.opacity(0.8)])
    
    // ... (Keep existing init and other extensions)
    
    // 初始化方法
    // Native Feature: 支持 12-bit (RGB), 24-bit (RGB), 32-bit (ARGB) 的 Hex 颜色解析
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        var a: CGFloat = 1.0
        var r: UInt64 = 0
        var g: UInt64 = 0
        var b: UInt64 = 0
        
        switch hex.count {
        case 3: // RGB (12-bit)
            a = 1.0
            r = (int >> 8) * 17
            g = (int >> 4 & 0xF) * 17
            b = (int & 0xF) * 17
        case 6: // RGB (24-bit)
            a = 1.0
            r = int >> 16
            g = int >> 8 & 0xFF
            b = int & 0xFF
        case 8: // ARGB (32-bit)
            a = CGFloat(int >> 24) / 255
            r = int >> 16 & 0xFF
            g = int >> 8 & 0xFF
            b = int & 0xFF
        default:
            a = 1.0
            r = 0
            g = 0
            b = 0
        }
        self.init(uiColor: UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: a))
    }
}

// 扩展 UIColor 支持 hex 初始化
extension UIColor {
    convenience init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        var a: CGFloat = 1.0
        var r: UInt64 = 0
        var g: UInt64 = 0
        var b: UInt64 = 0
        
        switch hex.count {
        case 3: // RGB (12-bit)
            a = 1.0
            r = (int >> 8) * 17
            g = (int >> 4 & 0xF) * 17
            b = (int & 0xF) * 17
        case 6: // RGB (24-bit)
            a = 1.0
            r = int >> 16
            g = int >> 8 & 0xFF
            b = int & 0xFF
        case 8: // ARGB (32-bit)
            a = CGFloat(int >> 24) / 255
            r = int >> 16 & 0xFF
            g = int >> 8 & 0xFF
            b = int & 0xFF
        default:
            return nil
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: a)
    }
}

// 渐变色彩
extension Gradient {
    static let wechatGreen = Gradient(colors: [.wechatGreen, .wechatGreen.opacity(0.8)])
    static let wechatRed = Gradient(colors: [.wechatRed, .wechatRed.opacity(0.8)])
}

// 渐变样式
extension LinearGradient {
    static let wechatGreen = LinearGradient(gradient: .wechatGreen, startPoint: .leading, endPoint: .trailing)
    static let wechatRed = LinearGradient(gradient: .wechatRed, startPoint: .leading, endPoint: .trailing)
}

// 自定义圆角形状
// UI Style: 实现部分圆角（Partial Corner Radius）效果，如聊天气泡
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// 扩展用于设置特定角的圆角
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

