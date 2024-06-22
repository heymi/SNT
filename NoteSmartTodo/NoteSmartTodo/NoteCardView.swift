import SwiftUI

struct NoteCardView: View {
    var note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(note.title)
                .font(.headline)
                .lineLimit(1)
                .foregroundColor(.black) // 设置字体颜色
            Text("待办：\(note.todoItems.filter { !$0.isCompleted }.count) / \(note.todoItems.filter { $0.isCompleted }.count)")
                .font(.subheadline)
                .foregroundColor(.black) // 设置字体颜色
            Text(note.timestamp, formatter: dateFormatter)
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 2)
    }
}

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter
}()
