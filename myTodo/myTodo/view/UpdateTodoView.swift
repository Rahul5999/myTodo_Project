//
//  UpdateTodoView.swift
import SwiftUI

struct UpdateTodoView: View {
    @State var todo: Todo
    @ObservedObject var viewModel: TodosViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Todo Details")) {
                    TextField("Todo", text: $todo.todo)
                    TextField("User ID", value: $todo.userId, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                }
            }
            .navigationBarTitle("Update Todo", displayMode: .inline)
            .navigationBarItems(trailing: Button("Save") {
                viewModel.updateTodo(todo: todo)
                presentationMode.wrappedValue.dismiss() // Dismiss the view
            })
        }
    }
}

#Preview {
    UpdateTodoView(todo: Todo(id: 1, todo: "Sample Todo", completed: false, userId: 1), viewModel: TodosViewModel())
}

