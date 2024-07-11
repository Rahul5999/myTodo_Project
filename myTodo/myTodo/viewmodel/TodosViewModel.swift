// TodosViewModel
import SwiftUI
import Alamofire
import RealmSwift

class TodosViewModel: ObservableObject {
    @Published var todos = [Todo]()
    private var realm: Realm?

    init() {
        do {
            realm = try Realm()
            print("Realm Database Path: \(String(describing: realm?.configuration.fileURL?.path))")
            loadTodosFromRealm()
        } catch {
            print("Error initializing Realm: \(error.localizedDescription)")
        }
    }

    func loadTodosFromRealm() {
        guard let realm = realm else { return }
        let todoObjects = realm.objects(TodoObject.self)
        self.todos = todoObjects.map { Todo(id: $0.id, todo: $0.todo, completed: $0.completed, userId: $0.userId) }

        if self.todos.isEmpty {
            fetchTodos { error in
                if let error = error {
                    print("Error fetching todos: \(error.localizedDescription)")
                }
            }
        }
    }

    func fetchTodos(completion: @escaping (Error?) -> Void) {
        AF.request("https://dummyjson.com/todos")
            .validate()
            .responseDecodable(of: TodosResponse.self) { response in
                switch response.result {
                case .success(let todosResponse):
                    DispatchQueue.main.async {
                        self.saveTodosToRealm(todos: todosResponse.todos)
                        self.todos = todosResponse.todos
                        completion(nil)
                    }
                case .failure(let error):
                    print("Error fetching todos: \(error.localizedDescription)")
                    completion(error)
                }
            }
    }

    private func saveTodosToRealm(todos: [Todo]) {
        guard let realm = realm else { return }

        do {
            try realm.write {
                for todo in todos {
                    let todoObject = TodoObject(todo: todo)
                    realm.add(todoObject, update: .modified)
                }
            }
            print("Todos saved to RealmDB successfully.")
        } catch {
            print("Error saving todos to RealmDB: \(error.localizedDescription)")
        }
    }

    func updateTodo(todo: Todo) {
        updateApi(todo: todo) { success in
            if success {
                print("Todo updated successfully in API.")
            } else {
                print("Failed to update todo in API.")
            }
        }

        guard let realm = realm else { return }

        do {
            try realm.write {
                if let todoObject = realm.object(ofType: TodoObject.self, forPrimaryKey: todo.id) {
                    todoObject.todo = todo.todo
                    todoObject.completed = todo.completed
                    todoObject.userId = todo.userId
                    realm.add(todoObject, update: .modified)
                }
            }

            if let index = todos.firstIndex(where: { $0.id == todo.id }) {
                todos[index] = todo
            }

            print("Todo updated successfully in local database.")
        } catch {
            print("Error updating todo in local database: \(error.localizedDescription)")
        }
    }

    func deleteTodo(todo: Todo) {
        deleteApi(todo: todo) { success in
            if success {
                print("Todo deleted successfully in API.")
            } else {
                print("Failed to delete todo in API.")
            }

            // Proceed to delete the todo from the local database regardless of the API response
            guard let realm = self.realm else { return }

            do {
                try realm.write {
                    if let todoObject = realm.object(ofType: TodoObject.self, forPrimaryKey: todo.id) {
                        realm.delete(todoObject)
                    }
                }

                if let index = self.todos.firstIndex(where: { $0.id == todo.id }) {
                    self.todos.remove(at: index)
                }

                print("Todo deleted successfully in local database.")
            } catch {
                print("Error deleting todo in local database: \(error.localizedDescription)")
            }
        }
    }

    func addTodo(todo: Todo) {
        addApi(todo: todo) { [weak self] newTodo in
            guard let self = self else { return }

            // Generate a unique ID locally starting from 256
            let uniqueID = self.generateUniqueID(startingFrom: 256)
            let newTodoWithUniqueID = Todo(id: uniqueID, todo: newTodo?.todo ?? todo.todo, completed: newTodo?.completed ?? todo.completed, userId: newTodo?.userId ?? todo.userId)

            do {
                let realm = try Realm()
                try realm.write {
                    let todoObject = TodoObject(todo: newTodoWithUniqueID)
                    realm.add(todoObject, update: .modified)
                }
                DispatchQueue.main.async {
                    self.todos.append(newTodoWithUniqueID)
                    print("Todo added successfully.")
                }
            } catch {
                print("Error adding todo to Realm: \(error.localizedDescription)")
            }
        }
    }

    private func addApi(todo: Todo, completion: @escaping (Todo?) -> Void) {
        let url = "https://dummyjson.com/todos/add"
        let parameters: [String: Any] = [
            "todo": todo.todo,
            "completed": todo.completed,
            "userId": todo.userId
        ]

        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .responseDecodable(of: Todo.self) { response in
                switch response.result {
                case .success(let newTodo):
                    print("new Todo: \(newTodo) from the api")
                    completion(newTodo)
                case .failure(let error):
                    print("Error adding todo in API: \(error.localizedDescription)")
                    completion(nil)
                }
            }
    }

    private func updateApi(todo: Todo, completion: @escaping (Bool) -> Void) {
        let url = "https://dummyjson.com/todos/\(todo.id)"
        let parameters: [String: Any] = [
            "todo": todo.todo,
            "completed": todo.completed,
            "userId": todo.userId
        ]

        AF.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .responseDecodable(of: Todo.self) { response in
                switch response.result {
                case .success(let updatedTodo):
                    print("Updated Todo: \(updatedTodo) from the api")
                    completion(true)
                case .failure(let error):
                    print("Error updating todo in API: \(error.localizedDescription)")
                    completion(false)
                }
            }
    }


    private func deleteApi(todo: Todo, completion: @escaping (Bool) -> Void) {
        let url = "https://dummyjson.com/todos/\(todo.id)"

        AF.request(url, method: .delete)
            .validate()
            .responseDecodable(of: DeletedTodo.self) { response in
                switch response.result {
                case .success(let deletedTodo):
                    print("Deleted Todo: \(deletedTodo) received from the api")
                    completion(true)
                case .failure(let error):
                    print("Error deleting todo in API: \(error.localizedDescription)")
                    completion(false)
                }
            }
    }
    private func generateUniqueID(startingFrom startID: Int) -> Int {
        // Generate a unique ID starting from startID
        var uniqueID = startID
        let existingIDs = Set(todos.map { $0.id })

        while existingIDs.contains(uniqueID) {
            uniqueID += 1
        }

        return uniqueID
    }
}

