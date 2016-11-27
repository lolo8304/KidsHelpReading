import Vapor
import VaporPostgreSQL
import VaporMongo
import FluentMongo

let drop = Droplet()
drop.preparations.append(Post.self)
//try drop.addProvider(VaporPostgreSQL.Provider.self)
try drop.addProvider(VaporMongo.Provider.self)

drop.get { req in
    return try drop.view.make("welcome", [
        "message": drop.localization[req.lang, "welcome", "title"],
        "posts": Post.all().makeNode()
    ])
}

drop.get("versionPSQL") { request in
    if let db = drop.database?.driver as? PostgreSQLDriver {
        let version = try db.raw("SELECT version()")
        return try JSON(node: version)
    } else {
        return "No db connection"
    }
}
drop.get("versionMongo") { request in
    if let db = drop.database?.driver as? MongoDriver {
        let version = try db.raw("db.version()")
        return try JSON(node: version)
    } else {
        return "No db connection"
    }
}

drop.get("test") { request in
    let c = try Post.all().count + 1
    var post = Post(content: "This is a title \(c)")
    try post.save()
    return try JSON(node: Post.all().makeNode())
}

drop.resource("posts", PostController())

drop.run()
