CREATE SCHEMA Blog
	CREATE TABLE Blog (
	blog_id SERIAL NOT NULL,
	blog_title VARCHAR(24) NOT NULL,
	user_id int NOT NULL,
	post_id int NOT NULL,
	created_date DATE NOT NULL,
	last_post TIMESTAMP NOT NULL CONSTRAINT
);

CREATE TABLE POSTS (
	post_id serial INT GENERATED ALWAYS AS IDENTITY,
	post_title VARCHAR (24) NOT NULL
	user_id INT NOT NULL,
	category_id 
	post_date DATE NOT NULL,
	post_meta_id INT NOT NULL
	PRIMARY KEY(post_id)
	CONSTRAINT fk_user
		FOREIGN KEY(user_id)
			REFERENCES USERS(user_id)
			ON DELETE CASCADE
);

CREATE TABLE POSTS (
	post_id serial INT GENERATED ALWAYS AS IDENTITY,
	post_title VARCHAR (24) NOT NULL
	user_id INT NOT NULL,
	category_id 
	post_date DATE NOT NULL,
	post_meta_id INT NOT NULL
	PRIMARY KEY(post_id)
	CONSTRAINT fk_user
		FOREIGN KEY(user_id)
			REFERENCES USERS(user_id)
			ON DELETE CASCADE
);
CREATE TABLE POST_METADATA (
	metadata_id SERIAL AS PRIMARY KEY,
	metadata_string VARCHAR (32) NOT NULL,
	user_id INT NOT NULL,
	post_id INT NULL,
	category_id INT NULL,
	CONSTRAINT "CK_POSTMETADATA_POST_CATEGORY" CHECK (post_id IS NOT NULL) or (category_id IS NOT NULL)
);
CREATE TABLE COMMENT ( 
	comment_id SERIAL AS PRIMARY KEY,
	blog_id INT NOT NULL,
	post_id INT NOT NULL
);