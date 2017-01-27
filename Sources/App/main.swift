import Vapor
import MongoKitten

let drop = Droplet()

do {
    // Connect to the MongoDB server
    let mongoDatabase = try Database(mongoURL: "mongodb://localhost/mydatabase")
    // Select a database and collection
    let users = mongoDatabase["users"]
    
    
    //    drop.get { req in
    //        let lang = req.headers["Accept-Language"]?.string ?? "en"
    //        return try drop.view.make("welcome", [
    //            "message": Node.string(drop.localization[lang, "welcome", "title"])
    //            ])
    //    }
    
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
    drop.get("/") { request in
        // Check if there is a Vapor session.. Should always be the case
        let session = try request.session()
        // Find the user's ID if there is any
        if let userID = session.data["user"]?.string {
            // Check if the user is someone we know
            guard let userDocument = try users.findOne(matching: "_id" == ObjectId(userID)) else {
                // If we don't know the user (should never occur)
                return "I don't know you.."
            }
            // If we know the user
            return "Welcome, \(userDocument["username"] as String? ?? "")."
        }
        // If the user has sent his username and password over POST, PUT, GET or DELETE
        
        
        if let username = request.data["username"]?.string , let password = request.data["password"]?.string {
            let passwordHash = try drop.hash.make(password)
            
            // When the user wants to register
            if request.data["register"]?.bool == true {
                // If the username already exists
                guard try users.count(matching: "username" == username) == 0 else {
                    return "User with that username already exists"
                }
                // Register the user by inserting his information in the database
                guard let id = try users.insert(["username": username, "password": passwordHash] as Document).string else {
                    return "Unable to automatically log in"
                }
                session.data["user"] = Node.string(id.string ?? "")
                return "Thank you for registering \(username). You are automatically logged in"
            }
            // try to log in the user
            guard let user = try users.findOne(matching: "username" == username && "password" == passwordHash), let userId = user["_id"] as String?
                else {
                    return "The username or password is incorrect."
            }
            // Create a session for this user
            session.data["user"] = Node.string(userId)
            return "Your login as \(username) was successful"
        }
        // If there is no submitted username or password AND the user isn't logged in
        return "Welcome to this homepage!"
    }
    drop.resource("posts", PostController())
    drop.run()
} catch {
    print("Cannot connect to MongoDB")
}
