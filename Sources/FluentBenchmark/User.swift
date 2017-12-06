import Async
import JunkDrawer
import Fluent
import Foundation

public final class User<D: Database>: Model, Timestampable {
    /// See Model.Database
    public typealias Database = D

    /// See Model.ID
    public typealias ID = UUID

    /// See Model.idKey
    public static var idKey: IDKey { return \.id }

    /// See Model.name
    public static var entity: String {
        return "users"
    }

    /// See Model.keyStringMap
    public static var keyStringMap: KeyStringMap {
        return [
            key(\.id): "id",
            key(\.name): "name",
            key(\.age): "age",
            key(\.createdAt): "createdAt",
            key(\.updatedAt): "updatedAt"
        ]
    }

    /// See Model.database
    public static var database: DatabaseIdentifier<D> {
        return .init("test")
    }

    /// Foo's identifier
    var id: UUID?

    /// Name string
    var name: String

    /// Age int
    var age: Int

    /// Timestampable.createdAt
    public var createdAt: Date?

    /// Timestampable.updatedAt
    public var updatedAt: Date?

    /// Create a new foo
    init(id: ID? = nil, name: String, age: Int) {
        self.id = id
        self.name = name
        self.age = age
    }
}

// MARK: Relations

extension User {
    /// A relation to this user's pets.
    var pets: Children<User, Pet<Database>> {
        return children(\.ownerID)
    }
}

// MARK: Migration

internal struct UserMigration<D: Database>: Migration
    where D.Connection: SchemaSupporting
{
    /// See Migration.database
    typealias Database = D

    /// See Migration.prepare
    static func prepare(on connection: Database.Connection) -> Future<Void> {
        return connection.create(User<Database>.self) { builder in
            try builder.field(
                type: Database.Connection.FieldType.makeSchemaFieldType(for: .uuid),
                for: \User<Database>.id,
                isIdentifier: true
            )
            try builder.field(
                type: Database.Connection.FieldType.makeSchemaFieldType(for: .string),
                for: \User<Database>.name
            )
            try builder.field(
                type: Database.Connection.FieldType.makeSchemaFieldType(for: .int),
                for: \User<Database>.age
            )
            try builder.field(
                type: Database.Connection.FieldType.makeSchemaFieldType(for: .date),
                for: \User<Database>.createdAt
            )
            try builder.field(
                type: Database.Connection.FieldType.makeSchemaFieldType(for: .date),
                for: \User<Database>.updatedAt
            )
        }
    }

    /// See Migration.revert
    static func revert(on connection: Database.Connection) -> Future<Void> {
        return connection.delete(User<Database>.self)
    }
}
