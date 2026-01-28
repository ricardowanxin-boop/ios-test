# ai-ws 项目

## 项目构建

### 构建命令

以下是项目的构建命令：

```bash
xcodebuild -scheme ai-ws -destination 'platform=iOS Simulator,id=EF4A2FD8-1C4E-4569-BACC-D4258275D2D6' -configuration Debug build CODE_SIGN_STYLE=Manual CODE_SIGN_IDENTITY='' CODE_SIGNING_REQUIRED=NO
```

### 构建说明

- `-scheme ai-ws`: 指定构建方案为 ai-ws
- `-destination`: 指定构建目标设备，这里使用的是 iPhone Air 模拟器
- `-configuration Debug`: 使用 Debug 配置
- `CODE_SIGN_STYLE=Manual`: 使用手动签名方式
- `CODE_SIGN_IDENTITY=''`: 不使用签名身份
- `CODE_SIGNING_REQUIRED=NO`: 不需要签名

### 其他构建选项

如果需要在其他设备上构建，可以替换 `-destination` 参数：

```bash
# 在 macOS 上构建
xcodebuild -scheme ai-ws -destination 'platform=macOS,name=My Mac' build

# 在任意 iOS 设备上构建
xcodebuild -scheme ai-ws -destination 'platform=iOS,name=Any iOS Device' build
```

## 项目结构

```
ai-ws/
├── Assets.xcassets/         # 资源文件
│   ├── AccentColor.colorset/ # 强调色
│   └── AppIcon.appiconset/   # 应用图标
├── Features/                # 功能模块
│   ├── Discover/            # 发现模块
│   ├── Home/                # 首页模块
│   ├── Market/              # 市集模块
│   ├── Profile/             # 个人中心模块
│   └── Publish/             # 发布模块
├── img/                     # 图片资源
│   └── app.png              # 应用图标源文件
├── ContentView.swift        # 主视图
└── ai_wsApp.swift           # 应用入口
```

## 开发说明

1. 项目使用 SwiftUI 框架开发
2. 采用模块化结构，每个功能模块独立管理
3. 使用 Xcode 26.1.1 或更高版本构建
4. 支持 iOS 26.1 及以上版本
