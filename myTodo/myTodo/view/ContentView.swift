//
//  ContentView.swift
//  myTodo
//


import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = TodosViewModel()
    @State private var showingAddView = false
    @State private var selectedTodo: Todo?
    @State private var searchText = ""

    var filteredTodos: [Todo] {
        if searchText.isEmpty {
            return viewModel.todos
        } else {
            return viewModel.todos.filter { todo in
                todo.todo.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText)
                    .padding(.horizontal)

                List {
                    ForEach(filteredTodos) { todo in
                        TodoRowView(viewModel: viewModel, todo: todo)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    viewModel.deleteTodo(todo: todo)
                                } label: {
                                    Label("Delete", systemImage: "trash.circle.fill")
                                }
                                
                                Button {
                                    selectedTodo = todo
                                } label: {
                                    Label("Update", systemImage: "pencil.circle.fill")
                                }
                                .tint(.blue)
                            }
                    }
                    .onDelete(perform: { indexSet in
                        for index in indexSet {
                            let todo = filteredTodos[index]
                            viewModel.deleteTodo(todo: todo)
                        }
                    })
                }
            }
            .navigationBarTitle("Todos")
            .navigationBarItems(trailing: Button(action: {
                showingAddView = true
            }) {
                Image(systemName: "plus")
            })
            .sheet(item: $selectedTodo) { todo in
                UpdateTodoView(todo: todo, viewModel: viewModel)
            }
            .sheet(isPresented: $showingAddView) {
                AddTodoView(viewModel: viewModel)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



