import Vapor
import Fluent

struct PostsController: RouteCollection {
    
    func boot(router: Router) throws {
        
        let postsRoutes = router.grouped("api", "posts")
        postsRoutes.post(use: createHandler)
        postsRoutes.get(use: getAllHandler)
        postsRoutes.get(Post.parameter, use: getHandler)
        postsRoutes.put(Post.parameter, use: updateHandler)
        postsRoutes.delete(Post.parameter, use: deleteHandler)
        postsRoutes.get("search", use: searchHandler)
        postsRoutes.get(Post.parameter, "user", use: getUserHandler)
    }
    
    func createHandler(_ req: Request) throws -> Future<Post> {
        
        // returns future
        let future = try req.content.decode(Post.self)
        
        // extract post from future and save it
        return future.flatMap(to: Post.self, { post in
            return post.save(on: req)
        })
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Post]> {
        return Post.query(on: req).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<Post> {
        return try req.parameters.next(Post.self)
    }
    
    func updateHandler(_ req: Request) throws -> Future<Post> {
        
        let futureWithSavedPost = try req.parameters.next(Post.self)
        let futureWithDecodedPost = try req.content.decode(Post.self)

        return flatMap(to: Post.self, futureWithSavedPost, futureWithDecodedPost) { post, updatedPost in
            post.body = updatedPost.body
            post.userID = updatedPost.userID
            return post.save(on: req)
        }
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        
        let futureWithSavedPost = try req.parameters.next(Post.self)
        return futureWithSavedPost.delete(on: req).transform(to: .noContent)
    }
    
    func searchHandler(_ req: Request) throws -> Future<[Post]> {
        
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        
        return Post.query(on: req).filter(\.body == searchTerm).all()
    }
    
    // example: api/posts/3/user
    // returns user for post
    func getUserHandler(_ req: Request) throws -> Future<User> {
        
        let futureWithSavedPost = try req.parameters.next(Post.self)

        return futureWithSavedPost.flatMap(to: User.self) { post in
            post.user.get(on: req)
        }
    }
}
