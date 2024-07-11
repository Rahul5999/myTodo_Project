//TodoObject.swift
import RealmSwift

class TodoObject: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var todo: String
    @Persisted var completed: Bool
    @Persisted var userId: Int

    convenience init(todo: Todo) {
        self.init()
        self.id = todo.id
        self.todo = todo.todo
        self.completed = todo.completed
        self.userId = todo.userId
    }
}


