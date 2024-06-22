import SwiftUI
import AppKit

struct WindowAccessor: NSViewRepresentable {
    var callback: (NSWindow?) -> ()

    func makeNSView(context: Context) -> NSView {
        let nsView = NSView()
        DispatchQueue.main.async {
            self.callback(nsView.window)
        }
        return nsView
    }

    func updateNSView(_ nsView: NSView, context: Context) { }
}
