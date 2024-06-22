import Foundation

struct Note: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var content: String
    var todoItems: [TodoItem]
    var timestamp: Date

    // 实现 Equatable 协议
    static func == (lhs: Note, rhs: Note) -> Bool {
        return lhs.id == rhs.id
    }
}

struct TodoItem: Identifiable, Codable, Equatable, Hashable {
    var id = UUID()
    var text: String
    var isCompleted: Bool = false
    var timestamp: Date
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
