import SwiftUI

struct DragRelocateDelegate: DropDelegate {
    let item: TodoItem
    @Binding var listData: [TodoItem]
    @Binding var current: TodoItem?

    func performDrop(info: DropInfo) -> Bool {
        current = nil
        return true
    }

    func dropEntered(info: DropInfo) {
        guard let current = current,
              current != item,
              let from = listData.firstIndex(of: current),
              let to = listData.firstIndex(of: item) else { return }
        
        withAnimation {
            listData.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
        }
    }
}
