import SwiftUI

struct MainView: View {
    @State private var notes: [Note] = []
    @State private var showNoteDetail = false
    @State private var selectedNote: Note?
    @State private var selectedTodo: TodoItem?

    var body: some View {
        ZStack {
            // 背景磨砂效果
            VisualEffectView(material: .sidebar, blendingMode: .behindWindow, state: .active)
                .edgesIgnoringSafeArea(.all)
            
            GeometryReader { geometry in
                HStack(spacing: 16) {
                    // 笔记列表
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Notes")
                            .font(.largeTitle)
                            .padding([.top, .leading])
                        
                        ScrollView {
                            LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 16), count: 5), spacing: 16) {
                                ForEach(notes.sorted(by: { $0.timestamp > $1.timestamp })) { note in
                                    NoteCardView(note: note)
                                        .frame(width: (geometry.size.width * 0.6 / 5) - 16, height: ((geometry.size.width * 0.6 / 5) - 16) * 3 / 4)
                                        .onTapGesture {
                                            selectedNote = note
                                            showNoteDetail = true
                                        }
                                        .contextMenu {
                                            Button(action: {
                                                selectedNote = note
                                                showNoteDetail = true
                                            }) {
                                                Text("Edit")
                                                Image(systemName: "pencil")
                                            }
                                            Button(action: {
                                                if let index = notes.firstIndex(where: { $0.id == note.id }) {
                                                    notes.remove(at: index)
                                                    saveNotes()
                                                }
                                            }) {
                                                Text("Delete")
                                                Image(systemName: "trash")
                                            }
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 16)
                        
                        Button(action: {
                            selectedNote = nil
                            showNoteDetail = true
                        }) {
                            Text("Add New Note")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .shadow(radius: 2)
                        }
                        .padding([.leading, .bottom])
                    }
                    .frame(width: geometry.size.width * 0.6)

                    // 待办事项列表
                    TodoListMainView(notes: $notes)
                        .frame(width: geometry.size.width * 0.4)
                }
                .sheet(isPresented: $showNoteDetail) {
                    NoteDetailView(notes: $notes, note: $selectedNote)
                }
                .onAppear(perform: loadNotes)
            }
        }
    }

    func loadNotes() {
        guard let savedNotesData = UserDefaults.standard.data(forKey: "savedNotes") else { return }
        
        do {
            notes = try JSONDecoder().decode([Note].self, from: savedNotesData)
        } catch {
            print("Failed to load notes: \(error.localizedDescription)")
        }
    }

    func saveNotes() {
        do {
            let encodedData = try JSONEncoder().encode(notes)
            UserDefaults.standard.set(encodedData, forKey: "savedNotes")
        } catch {
            print("Failed to save notes: \(error.localizedDescription)")
        }
    }
}
