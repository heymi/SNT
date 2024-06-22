import SwiftUI

struct NotesView: View {
    @Binding var noteText: String
    @Binding var isModified: Bool
    var addTask: (String) -> Void
    
    var body: some View {
        VStack {
            Text("Notes")
                .font(.headline)
                .padding(.top)
            
            TextEditorWrapper(text: $noteText, onTextSelected: { selectedText in
                addTask(selectedText)
            })
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            .shadow(radius: 2)
            .padding()
            .onChange(of: noteText) { newValue in
                isModified = true
            }
        }
    }
}
