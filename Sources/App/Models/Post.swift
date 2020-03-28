import Vapor
import FluentPostgreSQL

final class Post: Codable
{
    var id: Int?
    var body: String
    
    init(body: String)
    {
        self.body = body
    }
}

extension Post: PostgreSQLModel {}
extension Post: Migration {}
extension Post: Content {}

