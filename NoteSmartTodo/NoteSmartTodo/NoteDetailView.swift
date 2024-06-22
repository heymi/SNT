import SwiftUI

struct NoteDetailView: View {
    @Binding var notes: [Note]
    @Binding var note: Note?
    @Environment(\.presentationMode) var presentationMode

    @State private var noteText: String = ""
    @State private var extractedTasks: [TodoItem] = []
    @State private var initialNoteText: String = ""
    @State private var initialExtractedTasks: [TodoItem] = []
    @State private var editedTaskText: String = ""
    @State private var editingTaskID: UUID?
    @State private var dragItem: TodoItem?
    @State private var noteTitle: String = ""
    @State private var showCancelConfirmation = false
    @State private var isModified = false

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(note: $note, saveNote: saveNote, cancelEditing: cancelEditing, showCancelConfirmation: $showCancelConfirmation)
            Divider()
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    NotesView(noteText: $noteText, isModified: $isModified, addTask: addTask)
                        .frame(width: geometry.size.width * 0.65, height: geometry.size.height)
                        .background(Color(NSColor.windowBackgroundColor))
                    TodoListView(
                        extractedTasks: $extractedTasks,
                        editingTaskID: $editingTaskID,
                        editedTaskText: $editedTaskText,
                        dragItem: $dragItem,
                        isModified: $isModified,
                        syncTodoStatus: syncTodoStatus,
                        deleteTask: { task in
                            if let index = extractedTasks.firstIndex(of: task) {
                                extractedTasks.remove(at: index)
                                isModified = true
                                print("Task deleted: \(task.text)")
                            }
                        }
                    )
                    .frame(width: geometry.size.width * 0.35, height: geometry.size.height)
                    .background(Color(NSColor.windowBackgroundColor))
                }
            }
            .frame(minWidth: 800, minHeight: 600)
        }
        .onAppear(perform: loadNoteDetails)
    }

    func analyzeNotes() {
        let text = noteText
        let tasks = extractTasks(from: text)
        
        for task in tasks {
            if !extractedTasks.contains(where: { $0.text == task.text }) {
                extractedTasks.insert(task, at: 0)
            }
        }
        
        isModified = true
    }

    func addTask(from text: String) {
        if !extractedTasks.contains(where: { $0.text == text }) {
            extractedTasks.insert(TodoItem(text: text, timestamp: formatDateString(for: text)), at: 0)
            isModified = true
        }
    }

    func deleteTask(at offsets: IndexSet) {
        extractedTasks.remove(atOffsets: offsets)
        isModified = true
    }
    
    func saveNote() {
        analyzeNotes()
        
        if let existingNote = note {
            if let index = notes.firstIndex(where: { $0.id == existingNote.id }) {
                notes[index].title = noteText.isEmpty ? "Untitled Note \(Date().description(with: .current))" : String(noteText.prefix(20))
                notes[index].content = noteText
                notes[index].todoItems = Array(Set(extractedTasks)) // 去重
                notes[index].timestamp = Date()
            }
        } else {
            let newNote = Note(
                title: noteText.isEmpty ? "Untitled Note \(Date().description(with: .current))" : String(noteText.prefix(20)),
                content: noteText,
                todoItems: Array(Set(extractedTasks)), // 去重
                timestamp: Date()
            )
            notes.append(newNote)
        }
        saveNotes()
        presentationMode.wrappedValue.dismiss()
        // 调试：打印出提取任务的日期
          for task in extractedTasks {
              print("Task: \(task.text), Date: \(task.timestamp)")
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
    
    func loadNoteDetails() {
        if let existingNote = note {
            noteText = existingNote.content
            extractedTasks = Array(Set(existingNote.todoItems)) // 去重
            noteTitle = existingNote.title
            initialNoteText = existingNote.content
            initialExtractedTasks = Array(Set(existingNote.todoItems)) // 去重
        } else {
            noteText = ""
            extractedTasks = []
            noteTitle = ""
            initialNoteText = ""
            initialExtractedTasks = []
        }
        isModified = false
    }
    
    func cancelEditing() {
        if noteText != initialNoteText || extractedTasks != initialExtractedTasks {
            showCancelConfirmation = true
        } else {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    func syncTodoStatus(_ task: TodoItem) {
        if let noteIndex = notes.firstIndex(where: { $0.id == note?.id }),
           let todoIndex = notes[noteIndex].todoItems.firstIndex(where: { $0.id == task.id }) {
            notes[noteIndex].todoItems[todoIndex].isCompleted = task.isCompleted
            notes[noteIndex].todoItems[todoIndex].timestamp = Date()  // 更新任务的时间戳
            saveNotes()
        }
    }
}

struct NoteDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NoteDetailView(notes: .constant([]), note: .constant(nil))
    }
}
