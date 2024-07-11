//
//  Todo.swift
//  myTodo
//
//  Created by user261757 on 7/10/24.
//
//Todo.swift

import Foundation

struct Todo: Codable, Identifiable {
     var id: Int
    var todo: String
    var completed: Bool
    var userId: Int
}

struct TodosResponse: Decodable {
    let todos: [Todo]
   // let total: Int
   // let skip: Int
   // let limit: Int
}
struct DeletedTodo: Decodable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
    let isDeleted: Bool
    let deletedOn: String
}



