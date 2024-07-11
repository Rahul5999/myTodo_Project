//AddTodoView.swift
import SwiftUI

struct AddTodoView: View {
    @State private var todoText: String = ""
    @State private var isCompleted: Bool = false
    @State private var userId: Int = 1 // Assuming a default user ID
    @ObservedObject var viewModel: TodosViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("New Todo Details")) {
                    TextField("Todo", text: $todoText)
                    Toggle(isOn: $isCompleted) {
                        Text("Completed")
                    }
                    TextField("User ID", value: $userId, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                }
            }
            .navigationBarTitle("Add Todo", displayMode: .inline)
            .navigationBarItems(trailing: Button("Add") {
                let newTodo = Todo(id: Int.random(in: 1000..<9999), todo: todoText, completed: isCompleted, userId: userId)
                viewModel.addTodo(todo: newTodo)
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

#Preview {
    AddTodoView(viewModel: TodosViewModel())
}

