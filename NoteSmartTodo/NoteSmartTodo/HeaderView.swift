import SwiftUI

struct HeaderView: View {
    @Binding var note: Note?
    var saveNote: () -> Void
    var cancelEditing: () -> Void
    @Binding var showCancelConfirmation: Bool
    
    var body: some View {
        HStack {
            Text(note != nil ? "Edit Note" : "New Note")
                .font(.largeTitle)
                .padding()
            Spacer()
            HStack {
                Button(action: saveNote) {
                    Text("Save Note")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .shadow(radius: 2)
                }
                Button(action: cancelEditing) {
                    Text("Cancel")
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .shadow(radius: 2)
                }
                .alert(isPresented: $showCancelConfirmation) {
                    Alert(
                        title: Text("Unsaved Changes"),
                        message: Text("You have unsaved changes. Are you sure you want to cancel?"),
                        primaryButton: .destructive(Text("Cancel Changes")) {
                            showCancelConfirmation = false
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            .padding()
        }
    }
}
