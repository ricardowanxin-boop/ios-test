import SwiftUI

// 微信iOS风格动画体系
// 核心设计：定义统一的动画时长和曲线，确保全局交互体验的一致性

// 动画时长常量
// 定义了三种标准时长，适应不同场景的反馈需求
enum WechatAnimationDuration {
    static let quick: TimeInterval = 0.2 // 用于即时反馈，如点击高亮
    static let normal: TimeInterval = 0.5 // 用于页面跳转、弹窗出现
    static let slow: TimeInterval = 1.0 // 用于加载动画、背景渐变
}

// 动画曲线常量
// 封装 SwiftUI Animation，提供语义化的调用方式
enum WechatAnimationCurve {
    static func linear(duration: TimeInterval) -> Animation {
        Animation.linear(duration: duration)
    }
    
    static func easeIn(duration: TimeInterval) -> Animation {
        Animation.easeIn(duration: duration)
    }
    
    static func easeOut(duration: TimeInterval) -> Animation {
        Animation.easeOut(duration: duration)
    }
    
    static func easeInOut(duration: TimeInterval) -> Animation {
        Animation.easeInOut(duration: duration)
    }
    
    // 弹性动画：模拟物理世界的阻尼效果，提升交互质感
    static let spring = Animation.spring(response: 0.5, dampingFraction: 0.7)
}

// 微信风格视图扩展
// UI Style: 提供便捷的修饰符，快速应用标准化的阴影、圆角和边框
extension View {
    // 微信风格阴影效果
    func wechatShadow() -> some View {
        self
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
    }
    
    // 微信风格圆角
    func wechatCornerRadius(_ radius: CGFloat = 8) -> some View {
        self
            .cornerRadius(radius)
    }
    
    // 微信风格边框
    func wechatBorder(color: Color = .wechatSeparator, width: CGFloat = 1) -> some View {
        self
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(color, lineWidth: width)
            )
    }
}
