---
aliases: 
color: ""
state: Drafting
tags: []
---
### <font color="#8db3e2">Creating a New Database</font>
	
You can create a new database using the `createdb` command or directly within `psql` (PostgreSQL's command-line tool).
	    
**Example Using `psql`:**
```sql
CREATE DATABASE game_db;
CREATE DATABASE game_server_db;	CREATE DATABASE personal_website_db;
CREATE DATABASE development_website_db;
```
	
**Example Using `createdb` Command:**
```Bash
createdb -U postgres game_db
createdb -U postgres game_server_db
createdb -U postgres personal_website_db
createdb -U postgres development_website_db
```
### <font color="#8db3e2">Accessing Databases</font>

* To connect to a specific database, you specify the database name when connecting via `psql` or any other PostgreSQL client.

Example:
```Bash
psql -U postgres -d game_db
psql -U postgres -d game_server_db
```

### <font color="#8db3e2">Managing User Access</font>

- You can create different users and assign them specific roles and permissions for each database. This way, you can control who has access to which database and what operations they can perform.

Example:
```sql
CREATE USER game_user WITH PASSWORD 'securepassword';
GRANT ALL PRIVILEGES ON DATABASE game_db TO game_user;

CREATE USER web_user WITH PASSWORD 'anotherpassword';
GRANT ALL PRIVILEGES ON DATABASE personal_website_db TO web_user;
```
