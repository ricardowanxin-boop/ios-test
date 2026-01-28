import SwiftUI

// 微信iOS风格动画体系

// 动画时长常量
enum WechatAnimationDuration {
    static let quick: TimeInterval = 0.2
    static let normal: TimeInterval = 0.5
    static let slow: TimeInterval = 1.0
}

// 动画曲线常量
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
    
    static let spring = Animation.spring(response: 0.5, dampingFraction: 0.7)
}

// 微信风格视图扩展
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
