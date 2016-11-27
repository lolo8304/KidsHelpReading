import Vapor
import Fluent
import Foundation

final class Post: Model {
    var id: Node?
    var exists: Bool = false
    var content: String
    
    init(id: Node, content: String) {
        self.id = id
        self.content = content
    }
    init(content: String) {
        self.id = nil
        self.content = content
    }

    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        content = try node.extract("content")
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "content": content
        ])
    }
}

extension Post: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create("posts", closure: { posts in
            posts.id()
            posts.string("content")
        })
    }

    static func revert(_ database: Database) throws {
        try database.delete("posts")
    }
}
