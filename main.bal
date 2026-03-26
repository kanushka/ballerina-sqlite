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

import ballerina/io;
import ballerina/sql;

public function main() returns error? {
    io:println("=== SQLite Connector Demo ===\n");
    
    // Initialize SQLite client with a file-based database
    Client sqliteClient = check new ({path: "./sample.db"});
    io:println("✓ SQLite client initialized");
    
    // Create a table
    _ = check sqliteClient->execute(`
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            age INTEGER NOT NULL,
            email TEXT
        )
    `);
    io:println("✓ Table created/verified\n");
    
    // Insert data
    io:println("--- INSERT Operations ---");
    string userName = "Alice";
    int userAge = 30;
    string userEmail = "alice@example.com";
    
    sql:ExecutionResult insertResult = check sqliteClient->execute(`
        INSERT INTO users (name, age, email) 
        VALUES (${userName}, ${userAge}, ${userEmail})
    `);
    int|string? lastId = insertResult.lastInsertId;
    io:println(string `✓ Inserted user: ${userName}, ID: ${lastId.toString()}`);
    
    // Batch insert
    sql:ParameterizedQuery[] insertQueries = [
        `INSERT INTO users (name, age, email) VALUES ('Bob', 25, 'bob@example.com')`,
        `INSERT INTO users (name, age, email) VALUES ('Carol', 28, 'carol@example.com')`,
        `INSERT INTO users (name, age, email) VALUES ('David', 35, 'david@example.com')`
    ];
    
    sql:ExecutionResult[] batchResults = check sqliteClient->batchExecute(insertQueries);
    io:println(string `✓ Batch insert completed: ${batchResults.length()} users added\n`);
    
    // Query all data
    io:println("--- SELECT Operations ---");
    stream<record {}, sql:Error?> resultStream = sqliteClient->query(`
        SELECT * FROM users ORDER BY id
    `);
    
    io:println("All users:");
    check from record {} user in resultStream
        do {
            io:println("  ", user);
        };
    
    // Query single row
    io:println("\n--- Query Single Row ---");
    int searchId = 1;
    record {}|sql:Error userRecord = sqliteClient->queryRow(`
        SELECT * FROM users WHERE id = ${searchId}
    `);
    
    if userRecord is record {} {
        io:println(string `✓ Found user with ID ${searchId}:`, userRecord);
    }
    
    // Update operation
    io:println("\n--- UPDATE Operation ---");
    int updateId = 2;
    int newAge = 26;
    sql:ExecutionResult updateResult = check sqliteClient->execute(`
        UPDATE users SET age = ${newAge} WHERE id = ${updateId}
    `);
    int? affectedRows = updateResult.affectedRowCount;
    io:println(string `✓ Updated user ID ${updateId}, rows affected: ${affectedRows.toString()}`);
    
    // Delete operation
    io:println("\n--- DELETE Operation ---");
    int deleteId = 4;
    sql:ExecutionResult deleteResult = check sqliteClient->execute(`
        DELETE FROM users WHERE id = ${deleteId}
    `);
    int? deletedRows = deleteResult.affectedRowCount;
    io:println(string `✓ Deleted user ID ${deleteId}, rows affected: ${deletedRows.toString()}`);
    
    // Final count
    io:println("\n--- Final Count ---");
    record {} countRecord = check sqliteClient->queryRow(`SELECT COUNT(*) as total FROM users`);
    io:println("✓ Total users remaining:", countRecord);
    
    // Close the client
    check sqliteClient.close();
    io:println("\n✓ SQLite client closed successfully");
    io:println("\n=== Demo Complete ===");
}
