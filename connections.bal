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

import ballerinax/java.jdbc;
import ballerina/sql;

# Represents a SQLite database client.
# This client wraps the JDBC client and provides SQLite-specific functionality.
public isolated client class Client {
    private final jdbc:Client jdbcClient;

    # Initializes the SQLite Client.
    #
    # + config - SQLite client configuration
    # + return - An `sql:Error` if the client creation fails
    public isolated function init(ClientConfiguration config) returns sql:Error? {
        string jdbcUrl = string `jdbc:sqlite:${config.path}`;
        
        jdbc:Options? jdbcOptions = ();
        Options? sqliteOptions = config.options;
        if sqliteOptions is Options {
            jdbcOptions = {
                properties: sqliteOptions.properties
            };
        }
        
        self.jdbcClient = check new (
            url = jdbcUrl,
            options = jdbcOptions,
            connectionPool = config.connectionPool
        );
    }

    # Executes the query, which may return multiple results.
    # When processing the stream, make sure to consume all fetched data or close the stream.
    #
    # + sqlQuery - The SQL query such as `` `SELECT * FROM users WHERE id = ${userId}` ``
    # + return - Stream of records or an `sql:Error`
    isolated remote function query(sql:ParameterizedQuery sqlQuery) 
            returns stream<record {}, sql:Error?> {
        return self.jdbcClient->query(sqlQuery);
    }

    # Queries the database and returns at most one row.
    # If the query returns multiple rows, it returns the first row.
    #
    # + sqlQuery - The SQL query such as `` `SELECT * FROM users WHERE id = ${userId}` ``
    # + return - Result record or an `sql:Error`
    isolated remote function queryRow(sql:ParameterizedQuery sqlQuery) 
            returns record {}|sql:Error {
        stream<record {}, sql:Error?> queryStream = self.jdbcClient->query(sqlQuery);
        record {|record {} value;|}? result = check queryStream.next();
        check queryStream.close();
        
        if result is () {
            return error sql:NoRowsError("Query did not retrieve any rows.");
        }
        
        return result.value;
    }

    # Executes the SQL query. Only the metadata of the execution is returned (not the results from the query).
    #
    # + sqlQuery - The SQL query such as `` `INSERT INTO users (name, age) VALUES (${name}, ${age})` ``
    # + return - Metadata of the query execution as an `sql:ExecutionResult` or an `sql:Error`
    isolated remote function execute(sql:ParameterizedQuery sqlQuery) 
            returns sql:ExecutionResult|sql:Error {
        return self.jdbcClient->execute(sqlQuery);
    }

    # Executes a batch of SQL queries.
    #
    # + sqlQueries - An array of SQL queries such as `` `INSERT INTO users (name) VALUES (${name})` ``
    # + return - Metadata of the query execution as an `sql:ExecutionResult[]` or an `sql:Error`
    isolated remote function batchExecute(sql:ParameterizedQuery[] sqlQueries) 
            returns sql:ExecutionResult[]|sql:Error {
        sql:ExecutionResult[] results = [];
        
        foreach sql:ParameterizedQuery sqlQuery in sqlQueries {
            sql:ExecutionResult result = check self.jdbcClient->execute(sqlQuery);
            results.push(result);
        }
        
        return results;
    }

    # Closes the SQLite client and shuts down the connection pool.
    # The client must be closed only at the end of the application lifetime.
    #
    # + return - Possible error when closing the client
    public isolated function close() returns sql:Error? {
        return self.jdbcClient.close();
    }
}
