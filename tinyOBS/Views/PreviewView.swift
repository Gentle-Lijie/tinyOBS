import SwiftUI
import AVFoundation
import Combine

struct PreviewView: NSViewRepresentable {
    var captureSession: AVCaptureSession?
    var screenCapture: ScreenCaptureService?

    func makeNSView(context: Context) -> NSView {
        let view = PreviewNSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.black.cgColor
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        // 更新捕获会话
        if let session = captureSession {
            context.coordinator.setupPreviewLayer(
                for: session,
                in: nsView
            )
            context.coordinator.currentMode = .captureSession
        } else if let screenCapture = screenCapture, screenCapture.isCapturing {
            context.coordinator.currentMode = .screenCapture
            context.coordinator.screenCapture = screenCapture
            context.coordinator.setupScreenCaptureView(in: nsView)
        } else {
            context.coordinator.clearPreview(in: nsView)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
        var screenCaptureView: NSImageView?
        var currentMode: PreviewMode = .none
        var screenCapture: ScreenCaptureService?
        var cancellables = Set<AnyCancellable>()

        enum PreviewMode {
            case none
            case captureSession
            case screenCapture
        }

        func setupPreviewLayer(for session: AVCaptureSession, in view: NSView) {
            // 移除旧的预览层
            previewLayer?.removeFromSuperlayer()

            // 创建新的预览层
            let layer = AVCaptureVideoPreviewLayer(session: session)
            layer.videoGravity = .resizeAspect
            layer.frame = view.bounds

            view.layer?.addSublayer(layer)
            previewLayer = layer

            // 设置自动调整大小
            layer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        }

        func setupScreenCaptureView(in view: NSView) {
            // 移除旧的视图
            screenCaptureView?.removeFromSuperview()

            // 创建图像视图
            let imageView = NSImageView(frame: view.bounds)
            imageView.imageScaling = .scaleProportionallyUpOrDown
            imageView.autoresizingMask = [.width, .height]

            view.addSubview(imageView)
            screenCaptureView = imageView

            // 订阅图像更新
            screenCapture?.$previewImage
                .receive(on: DispatchQueue.main)
                .sink { [weak self] cgImage in
                    if let cgImage = cgImage {
                        self?.screenCaptureView?.image = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
                    }
                }
                .store(in: &cancellables)
        }

        func clearPreview(in view: NSView) {
            previewLayer?.removeFromSuperlayer()
            previewLayer = nil
            screenCaptureView?.removeFromSuperview()
            screenCaptureView = nil
        }
    }
}

// 自定义 NSView 来处理预览
class PreviewNSView: NSView {
    override var wantsUpdateLayer: Bool {
        return true
    }

    override func layout() {
        super.layout()

        // 更新子层的大小
        if let previewLayer = layer?.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = bounds
        }
    }
}
