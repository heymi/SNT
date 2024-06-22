import SwiftUI
import UniformTypeIdentifiers

struct TodoListView: View {
    @Binding var extractedTasks: [TodoItem]
    @Binding var editingTaskID: UUID?
    @Binding var editedTaskText: String
    @Binding var dragItem: TodoItem?
    @Binding var isModified: Bool
    
    var syncTodoStatus: (TodoItem) -> Void
    var deleteTask: (TodoItem) -> Void

    var body: some View {
        List {
            ForEach($extractedTasks) { $task in
                HStack {
                    Button(action: {
                        withAnimation {
                            task.isCompleted.toggle()
                            isModified = true
                            syncTodoStatus(task)
                        }
                    }) {
                        Image(systemName: task.isCompleted ? "checkmark.square" : "square")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, 8)

                    if editingTaskID == task.id {
                        TextField("", text: $editedTaskText, onCommit: {
                            if let index = extractedTasks.firstIndex(where: { $0.id == task.id }) {
                                extractedTasks[index].text = editedTaskText
                                editingTaskID = nil
                                isModified = true
                                syncTodoStatus(extractedTasks[index])
                            }
                        })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        VStack(alignment: .leading) {
                            Text(task.text)
                                .strikethrough(task.isCompleted, color: .black)
                            Text(DateFormatter.localizedString(from: task.timestamp, dateStyle: .short, timeStyle: .none)) // 显示日期
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .contextMenu {
                    Button(action: {
                        editedTaskText = task.text
                        editingTaskID = task.id
                    }) {
                        Text("Edit")
                        Image(systemName: "pencil")
                    }
                    Button(action: {
                        deleteTask(task)
                    }) {
                        Text("Delete")
                        Image(systemName: "trash")
                    }
                }
                .onDrag {
                    dragItem = task
                    return NSItemProvider(object: String(task.text) as NSString)
                }
                .onDrop(of: [UTType.text], delegate: DragRelocateDelegate(item: task, listData: $extractedTasks, current: $dragItem))
            }
        }
    }
}
