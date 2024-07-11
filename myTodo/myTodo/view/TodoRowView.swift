//
//  TodoRowView.swift
//  myTodo
//
//

import SwiftUI

struct TodoRowView: View {
    @ObservedObject var viewModel: TodosViewModel
    var todo: Todo

    var body: some View {
        HStack {
            Image(systemName: todo.completed ? "checkmark.circle.fill" : "circle")
                .foregroundColor(todo.completed ? .green : .red)
                .onTapGesture {
                    toggleCompletion()
                }

            VStack(alignment: .leading) {
                Text(todo.todo)
                    .font(.headline)
                    .strikethrough(todo.completed, color: .gray)
                    .foregroundColor(todo.completed ? .gray : .primary)
                Text("User ID: \(todo.userId)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(todo.completed ? "Done" : "Pending")
                .foregroundColor(todo.completed ? .green : .red)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(todo.completed ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                .cornerRadius(8)
        }
        .padding(.vertical, 8)
    }

    private func toggleCompletion() {
        var updatedTodo = todo
        updatedTodo.completed.toggle()
        viewModel.updateTodo(todo: updatedTodo)
    }
}




struct TodoRowView_Previews: PreviewProvider {
    static var previews: some View {
        TodoRowView(viewModel: TodosViewModel(), todo: Todo(id: 1, todo: "Sample Todo", completed: false, userId: 1))
            .previewLayout(.fixed(width: 300, height: 80)) // Adjust size as needed
    }
}

