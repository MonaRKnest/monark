import Vapor
import VaporMongo
import FluentMongo


let drop = Droplet()
//try drop.addProvider(VaporMongo.Provider.self)

let mongo = try VaporMongo.Provider(database: "monarkdb", user: "admin", password: "admin")

drop.addProvider(mongo)

drop.get { req in
    let lang = req.headers["Accept-Language"]?.string ?? "en"
    return try drop.view.make("welcome", [
        "message": Node.string(drop.localization[lang, "welcome", "title"])
        ])
}

drop.get("version") { request in
    return try JSON(node: [
        "version": "1.0"
        ])
}

drop.post("json") { request in
    debugPrint(request.json!)
    guard let name = request.json?["name"]?.string else {
        throw Abort.badRequest
    }

    return "Hello, \(name)!"
}
//
//drop.post("json") { request in
//    debugPrint(request.json)
//    guard let name = request.json?["name"]?.string else {
//        throw Abort.badRequest
//    }
//
//    return "Hello, \(name)!"
//}

drop.get("version") { request in
    return try JSON(node: [
        "version": "1.0"
        ])
}

drop.resource("posts", PostController())


drop.get("dbversion") { requset in
    if let db = drop.database?.driver as? MongoDriver {
        let version = try db.raw("SELECT version()")
        return try JSON(node : version)
    } else {
        return "No db connection"
    }
    
}

drop.run()

