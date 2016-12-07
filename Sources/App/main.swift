import Vapor

let drop = Droplet()

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


drop.run()

