import SwiftUI

@main
struct NoteSmartTodoApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .onAppear {
                    hideTitleBar()
                }
        }
    }

    private func hideTitleBar() {
        DispatchQueue.main.async {
            if let window = NSApplication.shared.windows.first {
                window.titleVisibility = .hidden
                window.titlebarAppearsTransparent = true
                window.styleMask.insert(.fullSizeContentView)
                window.isMovableByWindowBackground = true
            }
        }
    }
}
