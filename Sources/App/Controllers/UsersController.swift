import Vapor

struct UsersController: RouteCollection {
    
    func boot(router: Router) throws {
        
        let usersRoute = router.grouped("api", "users")
        usersRoute.post(User.self, use: createHandler)
        usersRoute.get(use: getAllHandler)
        usersRoute.get(User.parameter, use: getHandler)
        usersRoute.get(User.parameter, "posts", use: getPostsHandler)
    }
    
    func createHandler(_ req: Request, user: User) throws -> Future<User> {
        return user.save(on: req)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[User]> {
        return User.query(on: req).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<User> {
        return try req.parameters.next(User.self)
    }
    
    // example: api/users/0B70F662-3995-4388-8655-5A5659582C22/posts
    // returns posts for user
    func getPostsHandler(_ req: Request) throws -> Future<[Post]> {
        
        let futureWithSavedUser = try req.parameters.next(User.self)
        
        return futureWithSavedUser.flatMap(to: [Post].self) { user in
           return try user.posts.query(on: req).all()
        }
    }
    
}

