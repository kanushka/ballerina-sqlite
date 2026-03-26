// Copyright (c) 2026 WSO2 LLC. (http://www.wso2.org).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/sql;
import ballerina/test;

// Test client initialization with file-based database
@test:Config {}
function testClientInitialization() returns error? {
    Client testClient = check new ({path: "./test_init.db"});
    check testClient.close();
}

// Test client initialization with in-memory database
@test:Config {}
function testInMemoryDatabase() returns error? {
    Client testClient = check new ({path: ":memory:"});
    check testClient.close();
}

// Test table creation
@test:Config {}
function testTableCreation() returns error? {
    Client testClient = check new ({path: ":memory:"});
    
    _ = check testClient->execute(`
        CREATE TABLE test_users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            age INTEGER NOT NULL
        )
    `);
    
    check testClient.close();
}

// Test insert operation
@test:Config {}
function testInsertOperation() returns error? {
    Client testClient = check new ({path: ":memory:"});
    
    _ = check testClient->execute(`
        CREATE TABLE test_users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            age INTEGER NOT NULL
        )
    `);
    
    string userName = "John Doe";
    int userAge = 30;
    
    sql:ExecutionResult result = check testClient->execute(`
        INSERT INTO test_users (name, age) VALUES (${userName}, ${userAge})
    `);
    
    test:assertTrue(result.lastInsertId is int|string, "Insert should return last insert ID");
    
    check testClient.close();
}

// Test query operation
@test:Config {}
function testQueryOperation() returns error? {
    Client testClient = check new ({path: ":memory:"});
    
    _ = check testClient->execute(`
        CREATE TABLE test_users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            age INTEGER NOT NULL
        )
    `);
    
    _ = check testClient->execute(`INSERT INTO test_users (name, age) VALUES ('Alice', 25)`);
    _ = check testClient->execute(`INSERT INTO test_users (name, age) VALUES ('Bob', 30)`);
    
    stream<record {}, sql:Error?> resultStream = testClient->query(`SELECT * FROM test_users`);
    
    int count = 0;
    check from record {} _ in resultStream
        do {
            count += 1;
        };
    
    test:assertEquals(count, 2, "Should retrieve 2 users");
    
    check testClient.close();
}

// Test queryRow operation
@test:Config {}
function testQueryRowOperation() returns error? {
    Client testClient = check new ({path: ":memory:"});
    
    _ = check testClient->execute(`
        CREATE TABLE test_users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            age INTEGER NOT NULL
        )
    `);
    
    _ = check testClient->execute(`INSERT INTO test_users (name, age) VALUES ('Alice', 25)`);
    
    int searchId = 1;
    record {} userRecord = check testClient->queryRow(`
        SELECT * FROM test_users WHERE id = ${searchId}
    `);
    
    test:assertTrue(userRecord.hasKey("name"), "Result should contain name field");
    test:assertTrue(userRecord.hasKey("age"), "Result should contain age field");
    
    check testClient.close();
}

// Test queryRow with no results
@test:Config {}
function testQueryRowNoResults() returns error? {
    Client testClient = check new ({path: ":memory:"});
    
    _ = check testClient->execute(`
        CREATE TABLE test_users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            age INTEGER NOT NULL
        )
    `);
    
    int searchId = 999;
    record {}|sql:Error result = testClient->queryRow(`
        SELECT * FROM test_users WHERE id = ${searchId}
    `);
    
    test:assertTrue(result is sql:NoRowsError, "Should return NoRowsError when no rows found");
    
    check testClient.close();
}

// Test update operation
@test:Config {}
function testUpdateOperation() returns error? {
    Client testClient = check new ({path: ":memory:"});
    
    _ = check testClient->execute(`
        CREATE TABLE test_users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            age INTEGER NOT NULL
        )
    `);
    
    _ = check testClient->execute(`INSERT INTO test_users (name, age) VALUES ('Alice', 25)`);
    
    int newAge = 26;
    int userId = 1;
    sql:ExecutionResult result = check testClient->execute(`
        UPDATE test_users SET age = ${newAge} WHERE id = ${userId}
    `);
    
    test:assertEquals(result.affectedRowCount, 1, "Should update 1 row");
    
    check testClient.close();
}

// Test delete operation
@test:Config {}
function testDeleteOperation() returns error? {
    Client testClient = check new ({path: ":memory:"});
    
    _ = check testClient->execute(`
        CREATE TABLE test_users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            age INTEGER NOT NULL
        )
    `);
    
    _ = check testClient->execute(`INSERT INTO test_users (name, age) VALUES ('Alice', 25)`);
    
    int userId = 1;
    sql:ExecutionResult result = check testClient->execute(`
        DELETE FROM test_users WHERE id = ${userId}
    `);
    
    test:assertEquals(result.affectedRowCount, 1, "Should delete 1 row");
    
    check testClient.close();
}

// Test batch execute operation
@test:Config {}
function testBatchExecute() returns error? {
    Client testClient = check new ({path: ":memory:"});
    
    _ = check testClient->execute(`
        CREATE TABLE test_users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            age INTEGER NOT NULL
        )
    `);
    
    sql:ParameterizedQuery[] insertQueries = [
        `INSERT INTO test_users (name, age) VALUES ('Alice', 25)`,
        `INSERT INTO test_users (name, age) VALUES ('Bob', 30)`,
        `INSERT INTO test_users (name, age) VALUES ('Carol', 28)`
    ];
    
    sql:ExecutionResult[] results = check testClient->batchExecute(insertQueries);
    
    test:assertEquals(results.length(), 3, "Should execute 3 queries");
    
    check testClient.close();
}

// Test connection pool configuration
@test:Config {}
function testConnectionPoolConfiguration() returns error? {
    sql:ConnectionPool connectionPool = {
        maxOpenConnections: 5,
        maxConnectionLifeTime: 1800,
        minIdleConnections: 2
    };
    
    Client testClient = check new ({
        path: ":memory:",
        connectionPool: connectionPool
    });
    
    _ = check testClient->execute(`
        CREATE TABLE test_users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL
        )
    `);
    
    check testClient.close();
}

// Test with custom options
@test:Config {}
function testCustomOptions() returns error? {
    Options options = {
        properties: {
            "journal_mode": "WAL"
        }
    };
    
    Client testClient = check new ({
        path: ":memory:",
        options: options
    });
    
    _ = check testClient->execute(`
        CREATE TABLE test_users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL
        )
    `);
    
    check testClient.close();
}

// Test parameterized queries with different data types
@test:Config {}
function testParameterizedQueries() returns error? {
    Client testClient = check new ({path: ":memory:"});
    
    _ = check testClient->execute(`
        CREATE TABLE test_data (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            text_col TEXT,
            int_col INTEGER,
            real_col REAL,
            bool_col INTEGER
        )
    `);
    
    string textValue = "test string";
    int intValue = 42;
    float realValue = 3.14;
    boolean boolValue = true;
    
    sql:ExecutionResult result = check testClient->execute(`
        INSERT INTO test_data (text_col, int_col, real_col, bool_col) 
        VALUES (${textValue}, ${intValue}, ${realValue}, ${boolValue})
    `);
    
    test:assertTrue(result.lastInsertId is int|string, "Insert should succeed with various data types");
    
    check testClient.close();
}
