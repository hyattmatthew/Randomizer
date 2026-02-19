import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var eventMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            // White dice icon for menu bar — crop to content and resize
            if let url = Bundle.module.url(forResource: "icon_menubar", withExtension: "png", subdirectory: "Resources"),
               let original = NSImage(contentsOf: url),
               let cropped = cropToContent(original) {
                cropped.isTemplate = false
                cropped.size = NSSize(width: 22, height: 22)
                button.image = cropped
                button.imagePosition = .imageOnly
            } else {
                button.title = " 🎲 "
            }
            button.action = #selector(togglePopover)
            button.target = self
        }

        let contentView = ContentView()
        let hostingController = TranslucentHostingController(rootView: contentView)

        popover = NSPopover()
        popover.contentSize = NSSize(width: 340, height: 460)
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = hostingController

        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            if let popover = self?.popover, popover.isShown {
                popover.performClose(nil)
            }
        }
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}

// MARK: - Crop image to non-transparent content

private func cropToContent(_ image: NSImage) -> NSImage? {
    guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }

    let width = cgImage.width
    let height = cgImage.height

    guard let data = cgImage.dataProvider?.data,
          let ptr = CFDataGetBytePtr(data) else { return nil }

    let bytesPerPixel = cgImage.bitsPerPixel / 8
    let bytesPerRow = cgImage.bytesPerRow

    var minX = width, minY = height, maxX = 0, maxY = 0

    for y in 0..<height {
        for x in 0..<width {
            let offset = y * bytesPerRow + x * bytesPerPixel
            let alpha = bytesPerPixel >= 4 ? ptr[offset + 3] : 255
            if alpha > 20 {
                minX = min(minX, x)
                minY = min(minY, y)
                maxX = max(maxX, x)
                maxY = max(maxY, y)
            }
        }
    }

    guard maxX > minX && maxY > minY else { return image }

    let padding = 2
    let cropRect = CGRect(
        x: max(0, minX - padding),
        y: max(0, minY - padding),
        width: min(width - minX, maxX - minX + 2 * padding),
        height: min(height - minY, maxY - minY + 2 * padding)
    )

    guard let cropped = cgImage.cropping(to: cropRect) else { return image }
    return NSImage(cgImage: cropped, size: NSSize(width: cropped.width, height: cropped.height))
}

// MARK: - Translucent Hosting Controller
// Makes the popover window background transparent so our SwiftUI view shows through

class TranslucentHostingController<Content: View>: NSHostingController<Content> {

    override func viewDidAppear() {
        super.viewDidAppear()
        makeWindowTranslucent()
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        makeWindowTranslucent()
    }

    private func makeWindowTranslucent() {
        guard let window = view.window else { return }
        window.isOpaque = false
        window.backgroundColor = .clear

        // Also make the popover's frame view transparent
        if let frameView = window.contentView?.superview {
            frameView.wantsLayer = true
            // Keep the popover arrow but make background see-through
            for subview in frameView.subviews {
                if subview !== window.contentView {
                    subview.wantsLayer = true
                    subview.layer?.opacity = 0.85
                }
            }
        }
    }
}
