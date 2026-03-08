# tinyOBS

一个轻量级的 macOS 原生视频采集应用，支持采集卡、摄像头和屏幕录制的预览与录制。

## 功能特性

- 📹 支持 USB 采集卡视频输入
- 🎥 支持系统摄像头
- 🖥️ 支持屏幕录制
- 🔄 实时预览和切换视频源
- ⏺️ 录制到本地 MP4 文件
- 🎨 简洁现代的 SwiftUI 界面

## 系统要求

- macOS 13.0 (Ventura) 或更高版本
- Xcode 15.0 或更高版本

## 构建与运行

### 使用 Xcode

1. 打开终端，进入项目目录
2. 运行以下命令生成 Xcode 项目：
   ```bash
   xcodegen generate
   ```
3. 打开生成的 `tinyOBS.xcodeproj`
4. 选择目标设备并运行

### 使用 Swift Package Manager

```bash
swift build
swift run tinyOBS
```

## 权限说明

应用需要以下权限：

- **摄像头** - 用于视频采集
- **麦克风** - 用于音频录制
- **屏幕录制** - 用于屏幕捕获

首次运行时，系统会请求这些权限。

## 项目结构

```
tinyOBS/
├── App/
│   ├── tinyOBSApp.swift      # 应用入口
│   └── ContentView.swift     # 主界面
├── Models/
│   ├── VideoSource.swift     # 视频源模型
│   └── RecordingState.swift  # 录制状态
├── ViewModels/
│   ├── VideoSourceManager.swift  # 视频源管理
│   └── RecordingManager.swift    # 录制管理
├── Views/
│   ├── PreviewView.swift     # 预览视图
│   ├── SourceListView.swift  # 视频源列表
│   ├── ControlBarView.swift  # 控制栏
│   └── RecordingIndicator.swift # 录制指示器
├── Services/
│   ├── ScreenCaptureService.swift # 屏幕录制服务
│   └── VideoWriter.swift     # 视频写入服务
└── Utils/
    └── AVExtensions.swift    # AVFoundation 扩展
```

## 使用方法

1. **选择视频源** - 点击底部的视频源卡片切换输入设备
2. **预览视频** - 在主区域实时预览视频内容
3. **开始录制** - 点击"开始录制"按钮开始录制视频
4. **停止录制** - 点击"停止录制"按钮结束录制

录制的文件会保存在 `~/Documents/` 目录下，文件名格式为 `tinyOBS_Recording_YYYY-MM-DD_HH-mm-ss.mp4`。

## 技术栈

- **语言**: Swift 5.9
- **UI 框架**: SwiftUI
- **视频采集**: AVFoundation
- **屏幕录制**: ScreenCaptureKit
- **录制**: AVAssetWriter

## License

MIT License
