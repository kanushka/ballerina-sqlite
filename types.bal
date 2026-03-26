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

# Represents SQLite client options.
#
# + properties - Additional properties for the SQLite connection
public type Options record {|
    map<anydata> properties?;
|};

# Represents SQLite client configuration.
#
# + path - Path to the SQLite database file (e.g., "./mydb.db" or ":memory:" for in-memory database)
# + options - SQLite client options
# + connectionPool - Connection pool configuration
public type ClientConfiguration record {|
    string path;
    Options options?;
    sql:ConnectionPool connectionPool?;
|};
