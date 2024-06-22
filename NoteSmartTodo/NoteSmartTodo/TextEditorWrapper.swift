import SwiftUI

struct TextEditorWrapper: NSViewRepresentable {
    @Binding var text: String
    var onTextSelected: (String) -> Void

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeNSView(context: Context) -> NSTextView {
        let textView = NSTextView()
        textView.delegate = context.coordinator
        textView.isEditable = true
        textView.isSelectable = true
        textView.allowsUndo = true
        textView.textContainerInset = NSSize(width: 5, height: 5)
        textView.backgroundColor = NSColor.controlBackgroundColor
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }

    func updateNSView(_ nsView: NSTextView, context: Context) {
        if nsView.string != text {
            let selectedRange = nsView.selectedRange()
            nsView.string = text
            nsView.setSelectedRange(selectedRange)
        }
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: TextEditorWrapper

        init(parent: TextEditorWrapper) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            if let textView = notification.object as? NSTextView {
                parent.text = textView.string
            }
        }

        func textViewDidChangeSelection(_ notification: Notification) {
            if let textView = notification.object as? NSTextView {
                let selectedText = (textView.string as NSString).substring(with: textView.selectedRange())
                if !selectedText.isEmpty {
                    let menu = NSMenu()
                    let menuItem = NSMenuItem(title: "生成待办事项", action: #selector(addTodoItem), keyEquivalent: "")
                    menuItem.target = self
                    menu.addItem(menuItem)
                    NSMenu.popUpContextMenu(menu, with: NSApp.currentEvent!, for: textView)
                }
            }
        }

        @objc func addTodoItem() {
            if let textView = NSApplication.shared.keyWindow?.firstResponder as? NSTextView {
                let selectedText = (textView.string as NSString).substring(with: textView.selectedRange())
                if !selectedText.isEmpty {
                    parent.onTextSelected(selectedText)
                }
            }
        }
    }
}
