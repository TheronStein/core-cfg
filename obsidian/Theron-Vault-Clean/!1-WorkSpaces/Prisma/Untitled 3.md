CREATE SCHEMA Person
	CREATE TABLE USERS (
		user_id SERIAL PRIMARY KEY,
		user_name VARCHAR (16) NOT NULL,
		password VARCHAR (50) NOT NULL,
		user_picture VARCHAR (255)
		email VARCHAR (255) UNIQUE NOT NULL,
		created_at TIMESTAMP NOT NULL, 
		last_login TIMESTAMP,
		group_id int NOT NULL REFERENCES groups,
		post_id bigint REFERENCES posts,
	);
	CREATE TABLE ADV_USERS (
  	first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    full_name VARCHAR(101) GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED,
) INHERITS (USERS);
	CREATE TABLE ROLES ( 
	role_id SERIAL PRIMARY KEY,
	role_name VARCHAR(16) NOT NULL,
	role_type VARCHAR(16) NOT NULL,
	role_color VARCHAR(12) 
)
	CREATE TABLE passwd (
	  user_id INT NOT NULL,
	  PasswordHash VARCHAR(128) NOT NULL,
	  ModifiedDate TIMESTAMP NOT NULL CONSTRAINT "DF_Password_ModifiedDate" DEFAULT (NOW())
	);


08 Databases/Theron-Database/Users



CREATE TABLE CATEGORY (
	id smallint
	category_title VARCHAR (255) NOT NULL
	category_meta TEXT []
);





CREATE ROLE admin;  -- Administrator
CREATE ROLE user;    -- Normal user

CREATE TABLE groups (group_id int PRIMARY KEY,
                     group_name text NOT NULL);
					 
					 
 INSERT INTO groups VALUES
  (1, 'low'),
  (2, 'medium'),
  (5, 'high');
  
  
CREATE TABLE Projects (
   project_id serial PRIMARY KEY,
   project_title VARCHAR (512) NOT NULL,
   project_url VARCHAR (1024) NOT NULL
);





CREATE TABLE PERMISSIONS (
	permission_id SERIAL PRIMARY KEY
	permission_name VARCHAR (24) NOT NULL,
	group_id int NOT NULL REFERENCES groups
)


dv.pages('#Asian').where(p => p.haircolor==="blonde")

dv.pages('#AI').where(p => p.ethnicity==="asian")