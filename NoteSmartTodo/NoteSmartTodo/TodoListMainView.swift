import SwiftUI
import UniformTypeIdentifiers

struct TodoListMainView: View {
    @Binding var notes: [Note]
    @State private var selectedTodo: TodoItem?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("All To-Do Items")
                .font(.largeTitle)
                .padding([.top, .leading])
            List {
                ForEach(allTodos) { todo in
                    HStack {
                        Button(action: {
                            withAnimation {
                                toggleTodoCompletion(todo)
                            }
                        }) {
                            Image(systemName: todo.isCompleted ? "checkmark.square" : "square")
                        }
                        .buttonStyle(PlainButtonStyle())

                        VStack(alignment: .leading) {
                            Text(todo.text)
                                .strikethrough(todo.isCompleted, color: .black)
                            Text(DateFormatter.localizedString(from: todo.timestamp, dateStyle: .short, timeStyle: .none)) // 显示日期
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        Button(action: {
                            selectedTodo = todo
                        }) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
    }

    var allTodos: [TodoItem] {
        var seenTodos = Set<UUID>()
        let todos = notes.flatMap { $0.todoItems }
            .sorted {
                if $0.isCompleted == $1.isCompleted {
                    return ($0.timestamp) > ($1.timestamp)
                } else {
                    return !$0.isCompleted && $1.isCompleted
                }
            }
            .filter { seenTodos.insert($0.id).inserted }
        return todos
    }

    func toggleTodoCompletion(_ todo: TodoItem) {
        if let noteIndex = notes.firstIndex(where: { $0.todoItems.contains(todo) }),
           let todoIndex = notes[noteIndex].todoItems.firstIndex(where: { $0.id == todo.id }) {
            notes[noteIndex].todoItems[todoIndex].isCompleted.toggle()
            notes[noteIndex].todoItems[todoIndex].timestamp = Date()  // 更新任务的时间戳
            saveNotes()
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
