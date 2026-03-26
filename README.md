# Ballerina SQLite Connector

[![Build](https://img.shields.io/badge/build-passing-brightgreen)]()
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)

A native Ballerina connector for SQLite databases, providing a simple and type-safe API for database operations.

## 🤖 Quick Start for AI Agents

**Copy-paste this prompt to your AI coding assistant:**

```bash
Create a Ballerina program using the kanushka/sqlite connector from Ballerina Central.

Requirements:
1. Add the package: bal add kanushka/sqlite
2. Create a SQLite database with a "users" table (id, name, email, age)
3. Insert 3 sample users
4. Query and display all users
5. Update one user's age
6. Delete one user
7. Show final count

Use proper error handling, parameterized queries, and close the connection when done.
```

**That's it!** The AI will fetch the connector from Ballerina Central and create a working example.

---

## Overview

The SQLite connector enables Ballerina applications to interact with SQLite databases seamlessly. SQLite is a lightweight, serverless, self-contained SQL database engine perfect for embedded applications, mobile apps, and local data storage.

## Features

- ✅ **Easy initialization** - Simple client setup with file-based or in-memory databases
- ✅ **Type-safe operations** - Parameterized queries with compile-time type checking
- ✅ **Connection pooling** - Built-in connection pool management
- ✅ **CRUD operations** - Complete support for Create, Read, Update, and Delete
- ✅ **Batch operations** - Execute multiple SQL statements efficiently
- ✅ **Stream processing** - Handle large result sets with streams
- ✅ **Auto-create databases** - Automatically creates database files if they don't exist

## Installation

Add the SQLite connector to your Ballerina project:

```bash
bal add kanushka/sqlite
```

## Quick Start

```ballerina
import kanushka/sqlite;
import ballerina/io;
import ballerina/sql;

public function main() returns error? {
    // Initialize SQLite client
    sqlite:Client db = check new ({path: "./myapp.db"});
    
    // Create table
    _ = check db->execute(`
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL
        )
    `);
    
    // Insert data
    string userName = "Alice";
    string userEmail = "alice@example.com";
    
    sql:ExecutionResult result = check db->execute(`
        INSERT INTO users (name, email) VALUES (${userName}, ${userEmail})
    `);
    
    io:println("User created with ID: ", result.lastInsertId);
    
    // Query data
    stream<record {}, sql:Error?> users = db->query(`SELECT * FROM users`);
    
    check from record {} user in users
        do {
            io:println("User: ", user);
        };
    
    // Close the client
    check db.close();
}
```

## Usage Examples

### File-based Database

```ballerina
sqlite:Client db = check new ({path: "./myapp.db"});
```

### In-memory Database

```ballerina
sqlite:Client db = check new ({path: ":memory:"});
```

### With Connection Pool

```ballerina
sql:ConnectionPool pool = {
    maxOpenConnections: 10,
    maxConnectionLifeTime: 1800
};

sqlite:Client db = check new ({
    path: "./myapp.db",
    connectionPool: pool
});
```

### Query Single Row

```ballerina
int userId = 1;
record {}|sql:Error user = db->queryRow(`SELECT * FROM users WHERE id = ${userId}`);

if user is record {} {
    io:println("Found user: ", user);
}
```

### Batch Operations

```ballerina
sql:ParameterizedQuery[] queries = [
    `INSERT INTO users (name, email) VALUES ('Bob', 'bob@example.com')`,
    `INSERT INTO users (name, email) VALUES ('Carol', 'carol@example.com')`
];

sql:ExecutionResult[] results = check db->batchExecute(queries);
```

## API Documentation

### Client Operations

| Method | Description |
|--------|-------------|
| `query()` | Execute SELECT queries and get a stream of results |
| `queryRow()` | Get a single row from the database |
| `execute()` | Execute INSERT, UPDATE, DELETE, or DDL statements |
| `batchExecute()` | Execute multiple SQL statements in batch |
| `close()` | Close the client and release resources |

### Configuration

| Field | Type | Description | Required |
|-------|------|-------------|----------|
| `path` | `string` | Database file path or `:memory:` | Yes |
| `options` | `Options?` | SQLite-specific options | No |
| `connectionPool` | `sql:ConnectionPool?` | Connection pool configuration | No |

## Best Practices

1. **Always close the client** when done to release resources
2. **Use parameterized queries** to prevent SQL injection
3. **Handle errors properly** using `check` or explicit error handling
4. **Configure connection pools** based on your application's needs
5. **Use streams** for large result sets to avoid memory issues

## Requirements

- Ballerina 2201.13.2 or later
- Java 17 or later

## Building from Source

```bash
git clone https://github.com/kanushka/ballerina-sqlite.git
cd ballerina-sqlite
bal pack
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Support

For issues, questions, or contributions, please visit the [GitHub repository](https://github.com/kanushka/ballerina-sqlite).

## Useful Links

- [Ballerina Documentation](https://ballerina.io/learn/)
- [SQLite Documentation](https://www.sqlite.org/docs.html)
- [Ballerina SQL Package](https://lib.ballerina.io/ballerina/sql/latest)
