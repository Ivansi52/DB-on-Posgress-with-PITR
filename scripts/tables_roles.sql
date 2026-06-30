--Tables
CREATE TABLE Roles (
	role_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	role_name varchar(50) NOT NULL
);

CREATE TABLE Users (
	user_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
	username varchar(50) NOT NULL UNIQUE,
	password varchar(255) NOT NULL,
	email varchar(100) NOT NULL UNIQUE, 
	created_at timestamp DEFAULT CURRENT_TIMESTAMP,
	status varchar(20)
);

CREATE TABLE User_roles (
	user_id bigint REFERENCES Users(user_id) ON DELETE CASCADE,
	role_id bigint REFERENCES Roles(role_id),
	 PRIMARY KEY (user_id, role_id)
);

CREATE TABLE Order_statuses (
	status_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY ,
	status_name varchar(50) NOT NULL 
);

CREATE TABLE Products (
	product_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	name varchar(100),
	price numeric(10, 2) CHECK (price >= 0),
	manufacturer varchar(40),
	weight float8,
	composition varchar
);

CREATE TABLE Addresses (
	address_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	user_id bigint REFERENCES Users(user_id) ON DELETE CASCADE,
	address_text varchar NOT NULL
);

CREATE TABLE Orders (
	order_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	user_id bigint REFERENCES Users(user_id) ON DELETE CASCADE,
	courier_id bigint REFERENCES Users(user_id) ON DELETE SET NULL,
	address_id bigint REFERENCES Addresses(address_id) ON DELETE SET NULL,
	status_id bigint NOT NULL REFERENCES Order_statuses(status_id),
	created_at timestamp DEFAULT CURRENT_TIMESTAMP,
	total_price numeric(10, 2)
);

CREATE TABLE Order_items(
	order_item_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	order_id bigint REFERENCES Orders(order_id) ON DELETE CASCADE,
	product_id bigint REFERENCES Products(product_id),
	quantity int,
	price numeric(10, 2)
);

CREATE TABLE Order_status_history(
	history_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	order_id bigint REFERENCES Orders(order_id) ON DELETE CASCADE,
	status_id bigint REFERENCES Order_statuses(status_id),
	changed_at timestamp DEFAULT CURRENT_TIMESTAMP,
	changed_by_user_id bigint REFERENCES Users(user_id)
);

CREATE TABLE Backups(
	backup_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	file_name varchar,
	created_at timestamp DEFAULT CURRENT_TIMESTAMP,
	backup_type varchar(50),
	status varchar(20),
	user_id bigint REFERENCES Users(user_id) ON DELETE CASCADE
);



--Roles

-- Роль администратора системы
CREATE ROLE supervisor_role 
WITH 
LOGIN
CREATEDB
CREATEROLE;

-- Роль менеджера
CREATE ROLE manager_role
WITH
LOGIN;

-- Роль курьера
CREATE ROLE courier_role 
WITH 
LOGIN;

-- Роль клиента
CREATE ROLE client_role
WITH
LOGIN;

-- Роль программиста
CREATE ROLE programmer_role
WITH
LOGIN;

