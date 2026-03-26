## Overview

The `kanushka/sqlite` package provides a native Ballerina connector for SQLite databases. This connector enables seamless integration with SQLite, offering a simple and type-safe API for database operations.

SQLite is a lightweight, serverless, self-contained SQL database engine that is widely used for embedded database applications, mobile apps, and local data storage.

## Features

- **Easy initialization** - Simple client setup with file-based or in-memory databases
- **Type-safe operations** - Parameterized queries with compile-time type checking
- **Connection pooling** - Built-in connection pool management for optimal performance
- **CRUD operations** - Complete support for Create, Read, Update, and Delete operations
- **Batch operations** - Execute multiple SQL statements efficiently
- **Stream processing** - Handle large result sets with stream-based query results
- **Auto-create databases** - Automatically creates database files if they don't exist

## Quickstart

### AI Agent Quick Start 🤖

Use this prompt with your AI coding assistant to quickly get started:

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

The AI will generate a complete working example using this connector!

---

### Manual Quick Start

#### Step 1: Install the package

Execute the command below to add the `kanushka/sqlite` package as a dependency to your Ballerina project.

```bash
bal add kanushka/sqlite
```

#### Step 2: Import the package

Import the `kanushka/sqlite` package into your Ballerina program.

```ballerina
import kanushka/sqlite;
import ballerina/io;
```

#### Step 3: Initialize the SQLite client

Create a SQLite client by providing the database file path.

```ballerina
sqlite:Client sqliteClient = check new ({path: "./myapp.db"});
```

#### Step 4: Execute database operations

#### Create a table

```ballerina
_ = check sqliteClient->execute(`
    CREATE TABLE IF NOT EXISTS products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER DEFAULT 0
    )
`);
```

#### Insert data

```ballerina
string productName = "Laptop";
float productPrice = 999.99;
int productQuantity = 10;

sql:ExecutionResult result = check sqliteClient->execute(`
    INSERT INTO products (name, price, quantity) 
    VALUES (${productName}, ${productPrice}, ${productQuantity})
`);

io:println("Inserted product with ID: ", result.lastInsertId);
```

#### Query data

```ballerina
stream<record {}, sql:Error?> productStream = 
    sqliteClient->query(`SELECT * FROM products WHERE price > 500`);

check from record {} product in productStream
    do {
        io:println("Product: ", product);
    };
```

#### Query single row

```ballerina
int productId = 1;
record {}|sql:Error product = 
    sqliteClient->queryRow(`SELECT * FROM products WHERE id = ${productId}`);

if product is record {} {
    io:println("Found product: ", product);
}
```

#### Update data

```ballerina
int newQuantity = 15;
int productId = 1;

sql:ExecutionResult updateResult = check sqliteClient->execute(`
    UPDATE products SET quantity = ${newQuantity} WHERE id = ${productId}
`);

io:println("Rows affected: ", updateResult.affectedRowCount);
```

#### Delete data

```ballerina
int productId = 1;

sql:ExecutionResult deleteResult = check sqliteClient->execute(`
    DELETE FROM products WHERE id = ${productId}
`);
```

### Step 5: Close the client

Always close the client when done to release resources.

```ballerina
check sqliteClient.close();
```

## AI Agent Prompts for Common Use Cases 🤖

Copy and paste these prompts to quickly build common SQLite applications:

### REST API with SQLite Backend
```
Create a Ballerina REST API service using kanushka/sqlite connector with these endpoints:
- POST /products - Create a new product (name, price, stock)
- GET /products - List all products
- GET /products/{id} - Get a specific product
- PUT /products/{id} - Update product details
- DELETE /products/{id} - Delete a product

Include proper error handling, HTTP status codes, and database connection management.
```

### Data Migration Script
```
Create a Ballerina program using kanushka/sqlite that:
1. Reads data from a CSV file
2. Creates a SQLite database with appropriate schema
3. Imports all CSV records into the database using batch operations
4. Validates the import by counting records
5. Handles errors gracefully and provides progress updates
```

### In-Memory Cache with Persistence
```
Build a Ballerina caching service using kanushka/sqlite with:
- In-memory SQLite database for fast access
- Key-value store functionality (set, get, delete)
- TTL (time-to-live) support for cache entries
- Periodic cleanup of expired entries
- Statistics endpoint showing cache hit/miss rates
```

### Data Analytics Query Tool
```
Create a Ballerina CLI tool using kanushka/sqlite that:
1. Connects to an existing SQLite database
2. Accepts SQL queries from user input
3. Executes queries and displays results in a formatted table
4. Supports exporting results to JSON or CSV
5. Includes query history and favorites
```

---

## Examples

### Example 1: File-based database

```ballerina
import kanushka/sqlite;
import ballerina/io;
import ballerina/sql;

public function main() returns error? {
    // Initialize client with file-based database
    sqlite:Client db = check new ({path: "./users.db"});
    
    // Create table
    _ = check db->execute(`
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            email TEXT NOT NULL,
            created_at INTEGER DEFAULT (strftime('%s', 'now'))
        )
    `);
    
    // Insert user
    string username = "john_doe";
    string email = "john@example.com";
    
    sql:ExecutionResult insertResult = check db->execute(`
        INSERT INTO users (username, email) VALUES (${username}, ${email})
    `);
    
    io:println("User created with ID: ", insertResult.lastInsertId);
    
    // Query all users
    stream<record {}, sql:Error?> users = db->query(`SELECT * FROM users`);
    
    check from record {} user in users
        do {
            io:println("User: ", user);
        };
    
    check db.close();
}
```

### Example 2: In-memory database

```ballerina
import kanushka/sqlite;
import ballerina/io;
import ballerina/sql;

public function main() returns error? {
    // Initialize in-memory database (data lost when connection closes)
    sqlite:Client db = check new ({path: ":memory:"});
    
    // Create temporary table
    _ = check db->execute(`
        CREATE TABLE temp_data (
            id INTEGER PRIMARY KEY,
            value TEXT
        )
    `);
    
    // Insert temporary data
    _ = check db->execute(`INSERT INTO temp_data VALUES (1, 'temporary')`);
    
    // Query data
    record {}|sql:Error result = db->queryRow(`SELECT * FROM temp_data WHERE id = 1`);
    
    if result is record {} {
        io:println("Temp data: ", result);
    }
    
    check db.close();
}
```

### Example 3: Batch operations

```ballerina
import kanushka/sqlite;
import ballerina/io;
import ballerina/sql;

public function main() returns error? {
    sqlite:Client db = check new ({path: "./inventory.db"});
    
    _ = check db->execute(`
        CREATE TABLE IF NOT EXISTS items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            stock INTEGER NOT NULL
        )
    `);
    
    // Batch insert multiple items
    sql:ParameterizedQuery[] insertQueries = [
        `INSERT INTO items (name, stock) VALUES ('Item A', 100)`,
        `INSERT INTO items (name, stock) VALUES ('Item B', 200)`,
        `INSERT INTO items (name, stock) VALUES ('Item C', 150)`
    ];
    
    sql:ExecutionResult[] results = check db->batchExecute(insertQueries);
    io:println("Inserted ", results.length(), " items");
    
    check db.close();
}
```

### Example 4: Connection pooling

```ballerina
import kanushka/sqlite;
import ballerina/sql;

public function main() returns error? {
    // Configure connection pool
    sql:ConnectionPool connectionPool = {
        maxOpenConnections: 10,
        maxConnectionLifeTime: 1800,
        minIdleConnections: 5
    };
    
    sqlite:Client db = check new ({
        path: "./app.db",
        connectionPool: connectionPool
    });
    
    // Use the client for database operations
    // Connection pool manages connections automatically
    
    check db.close();
}
```

### Example 5: Using with custom properties

```ballerina
import kanushka/sqlite;
import ballerina/sql;

public function main() returns error? {
    // Configure SQLite-specific properties
    sqlite:Options options = {
        properties: {
            "journal_mode": "WAL",
            "synchronous": "NORMAL"
        }
    };
    
    sqlite:Client db = check new ({
        path: "./app.db",
        options: options
    });
    
    // Use the client
    
    check db.close();
}
```

## Configuration

### Client configuration

The `ClientConfiguration` record supports the following fields:

| Field | Type | Description | Required |
|-------|------|-------------|----------|
| `path` | `string` | Path to the SQLite database file (e.g., `"./mydb.db"`) or `":memory:"` for in-memory database | Yes |
| `options` | `Options?` | SQLite-specific options including custom properties | No |
| `connectionPool` | `sql:ConnectionPool?` | Connection pool configuration | No |

### Connection pool configuration

The `sql:ConnectionPool` record supports the following fields:

| Field | Type | Description | Default |
|-------|------|-------------|---------|
| `maxOpenConnections` | `int` | Maximum number of open connections | 15 |
| `maxConnectionLifeTime` | `decimal` | Maximum lifetime of a connection in seconds | 1800 |
| `minIdleConnections` | `int` | Minimum number of idle connections | Same as `maxOpenConnections` |
| `connectionTimeout` | `decimal` | Maximum time to wait for a connection in seconds | 30 |

## Best practices

1. **Always close the client** - Call `close()` when done to release resources
2. **Use parameterized queries** - Prevent SQL injection by using parameterized queries with `${}` syntax
3. **Handle errors properly** - Use `check` or explicit error handling for all database operations
4. **Configure connection pools** - Adjust pool settings based on your application's needs
5. **Use transactions** - For multiple related operations, consider using transactions (if supported)
6. **Stream large results** - Use query streams for large result sets to avoid memory issues

## Issues and projects

If you encounter any issues or have suggestions, please report them in the [GitHub repository](https://github.com/kanushka/ballerina-sqlite).

## Useful links

- [SQLite Official Documentation](https://www.sqlite.org/docs.html)
- [Ballerina SQL Package](https://lib.ballerina.io/ballerina/sql/latest)
- [Ballerina JDBC Package](https://lib.ballerina.io/ballerinax/java.jdbc/latest)
