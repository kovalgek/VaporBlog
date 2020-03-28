import Vapor
import FluentPostgreSQL

final class Post: Codable
{
    var id: Int?
    var body: String
    var userID: User.ID

    init(body: String, userID: User.ID)
    {
        self.body = body
        self.userID = userID
    }
}

extension Post: PostgreSQLModel {}
extension Post: Content {}
extension Post: Parameter {}

extension Post {
    var user: Parent<Post, User> {
        return parent(\.userID)
    }
}

extension Post: Migration {
    
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        
        return Database.create(self, on: connection) { builder in
            
            try addProperties(to: builder)
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}

