TRUNCATE 
User_roles,
Order_items,
Order_status_history,
Orders,
Addresses,
Users
RESTART IDENTITY CASCADE;

-- 1. Заполняем справочник ролей в таблицу 
INSERT INTO Roles (role_name) VALUES 
('supervisor_role'), 
('manager_role'), 
('courier_role'), 
('client_role'), 
('programmer_role');

SELECT * FROM Roles;


-- 2. Заполняем справочник статусов
INSERT INTO Order_statuses (status_name) VALUES 
('accepted'),
('created'), 
('delivering'), 
('delivered'), 
('cancelled');

SELECT * FROM Order_statuses;


-- 3. Заполняем таблицу продуктов (100 тысяч записей)
INSERT INTO Products (name, price, manufacturer, weight, composition)
SELECT 
    'Товар №' || i, 
    (random() * 500 + 10)::numeric(10,2), 
    'Завод-' || (i % 50), 
    random() * 5, 
    'Техническое описание для товара номер ' || i
FROM generate_series(1, 100000) i;

SELECT * FROM Products WHERE name = 'Товар №99999';

-- Users
INSERT INTO Users(username, password, email, status) VALUES
('client1', 'pass123', 'client1@mail.com', 'active'),
('client2', 'pass123', 'client2@mail.com', 'active'),
('client3', 'pass123', 'client3@mail.com', 'active'),
('client4', 'pass123', 'client4@mail.com', 'active'),
('client5', 'pass123', 'client5@mail.com', 'active'),
('client6', 'pass123', 'client6@mail.com', 'active'),
('client7', 'pass123', 'client7@mail.com', 'active'),
('client8', 'pass123', 'client8@mail.com', 'active'),
('client9', 'pass123', 'client9@mail.com', 'active'),
('client10', 'pass123', 'client10@mail.com', 'active'),
('manager1', 'pass123', 'manager1@mail.com', 'active'),
('manager2', 'pass123', 'manager2@mail.com', 'active'),
('manager3', 'pass123', 'manager3@mail.com', 'active'),
('manager4', 'pass123', 'manager4@mail.com', 'active'),
('manager5', 'pass123', 'manager5@mail.com', 'active'),
('courier1', 'pass123', 'courier1@mail.com', 'active'),
('courier2', 'pass123', 'courier2@mail.com', 'active'),
('courier3', 'pass123', 'courier3@mail.com', 'active'),
('courier4', 'pass123', 'courier4@mail.com', 'active'),
('courier5', 'pass123', 'courier5@mail.com', 'active'),
('courier6', 'pass123', 'courier6@mail.com', 'active'),
('courier7', 'pass123', 'courier7@mail.com', 'active'),
('courier8', 'pass123', 'courier8@mail.com', 'active'),
('courier9', 'pass123', 'courier9@mail.com', 'active'),
('courier10', 'pass123', 'courier10@mail.com', 'active'),
('programmer1', 'pass123', 'programmer1@mail.com', 'active'),
('programmer2', 'pass123', 'programmer2@mail.com', 'active'),
('programmer3', 'pass123', 'programmer3@mail.com', 'active'),
('admin1', 'pass123', 'admin1@mail.com', 'active'),
('admin2', 'pass123', 'admin2@mail.com', 'active');

SELECT user_id FROM Users ORDER BY user_id;

-- User_roles (role_id: 1=supervisor, 2=manager, 3=courier, 4=client, 5=programmer)
INSERT INTO User_roles(user_id, role_id) VALUES
(1,4),(2,4),(3,4),(4,4),(5,4),(6,4),(7,4),(8,4),(9,4),(10,4),
(11,2),(12,2),(13,2),(14,2),(15,2),
(16,3),(17,3),(18,3),(19,3),(20,3),(21,3),(22,3),(23,3),(24,3),(25,3),
(26,5),(27,5),(28,5),
(29,1),(30,1);

SELECT * FROM User_roles;

-- Addresses
INSERT INTO Addresses(user_id, address_text) VALUES
(1,'ул. Ленина 1, кв. 1'),(2,'ул. Ленина 2, кв. 2'),
(3,'ул. Ленина 3, кв. 3'),(4,'ул. Ленина 4, кв. 4'),
(5,'ул. Ленина 5, кв. 5'),(6,'ул. Ленина 6, кв. 6'),
(7,'ул. Ленина 7, кв. 7'),(8,'ул. Ленина 8, кв. 8'),
(9,'ул. Ленина 9, кв. 9'),(10,'ул. Ленина 10, кв. 10'),
(1,'ул. Пушкина 1, кв. 1'),(2,'ул. Пушкина 2, кв. 2'),
(3,'ул. Пушкина 3, кв. 3'),(4,'ул. Пушкина 4, кв. 4'),
(5,'ул. Пушкина 5, кв. 5'),(6,'ул. Пушкина 6, кв. 6'),
(7,'ул. Пушкина 7, кв. 7'),(8,'ул. Пушкина 8, кв. 8'),
(9,'ул. Пушкина 9, кв. 9'),(10,'ул. Пушкина 10, кв. 10'),
(1,'ул. Гагарина 1, кв. 1'),(2,'ул. Гагарина 2, кв. 2'),
(3,'ул. Гагарина 3, кв. 3'),(4,'ул. Гагарина 4, кв. 4'),
(5,'ул. Гагарина 5, кв. 5'),(6,'ул. Гагарина 6, кв. 6'),
(7,'ул. Гагарина 7, кв. 7'),(8,'ул. Гагарина 8, кв. 8'),
(9,'ул. Гагарина 9, кв. 9'),(10,'ул. Гагарина 10, кв. 10');

SELECT address_id FROM Addresses ORDER BY address_id;

-- Orders (status_id: 1=created, 2=delivering, 3=delivered, 4=cancelled, 5=accepted)
INSERT INTO Orders(user_id, courier_id, address_id, status_id, total_price) VALUES
(1,16,1,2,15.50),(2,17,2,2,22.30),(3,18,3,2,8.70),
(4,19,4,2,31.20),(5,20,5,5,12.40),(6,21,6,5,19.80),
(7,22,7,1,7.60),(8,23,8,1,25.90),(9,24,9,4,14.30),	
(10,25,10,4,33.70),(1,16,11,2,18.20),(2,17,12,2,9.50),
(3,18,13,2,27.80),(4,19,14,5,11.60),(5,20,15,1,16.40),	
(6,21,16,2,23.10),(7,22,17,2,5.80),(8,23,18,5,38.90),
(9,24,19,1,13.70),(10,25,20,4,29.40),(1,16,21,2,17.30),
(2,17,22,2,21.60),(3,18,23,5,9.80),(4,19,24,1,34.50),
(5,20,25,2,12.90),(6,21,26,2,8.40),(7,22,27,5,26.70),
(8,23,28,1,15.20),(9,24,29,4,19.60),(10,25,30,2,41.30);

SELECT * FROM Orders;

-- Order_items
-- 1. Переводим все заказы в статус 'created', 
-- чтобы защитный триггер разрешил обновить цену
-- 1. Выключаем все триггеры
ALTER TABLE Orders DISABLE TRIGGER ALL;
ALTER TABLE Order_items DISABLE TRIGGER ALL;

-- 2. INSERT, чтобы было без ошибок
INSERT INTO Order_items(order_id, product_id, quantity, price) VALUES
(1,1,2,2.50),(1,2,1,1.20),
(2,3,1,3.80),(2,4,1,5.50),
(3,5,2,2.80),(3,6,1,1.50),
(4,7,1,1.10),(4,8,2,1.80),
(5,9,3,2.10),(5,10,2,1.30),
(6,11,1,1.90),(6,12,2,2.20),
(7,13,1,1.70),(7,14,3,1.40),
(8,15,1,4.50),(8,16,2,3.20),
(11,21,2,0.60),(11,22,1,0.50),
(12,23,2,0.70),(12,24,1,1.20),
(13,25,1,1.50),(13,26,2,1.30),
(14,27,3,1.10),(14,28,2,1.60),
(15,29,1,2.50),(15,30,1,4.50);

-- 3. Включаем всё обратно
ALTER TABLE Orders ENABLE TRIGGER ALL;
ALTER TABLE Order_items ENABLE TRIGGER ALL;

SELECT * FROM Order_items;

-- Order_status_history
INSERT INTO Order_status_history(order_id, status_id, changed_by_user_id, changed_at) VALUES
-- Заказ 1
(1, 1, 11, CURRENT_TIMESTAMP - interval '10 hours'),
(1, 2, 11, CURRENT_TIMESTAMP - interval '9 hours'),
(1, 3, 16, CURRENT_TIMESTAMP - interval '8 hours'),
-- Заказ 2
(2, 1, 12, CURRENT_TIMESTAMP - interval '7 hours'),
(2, 2, 12, CURRENT_TIMESTAMP - interval '6 hours'),
(2, 3, 17, CURRENT_TIMESTAMP - interval '5 hours'),
-- Заказ 3
(3, 1, 13, CURRENT_TIMESTAMP - interval '4 hours'),
(3, 2, 13, CURRENT_TIMESTAMP - interval '3 hours'),
-- Заказы в разных стадиях
(4, 1, 11, CURRENT_TIMESTAMP - interval '2 hours'),
(4, 2, 11, CURRENT_TIMESTAMP - interval '1 hour'),
(5, 1, 12, CURRENT_TIMESTAMP - interval '50 minutes'),
(6, 1, 13, CURRENT_TIMESTAMP - interval '40 minutes'),
(7, 1, 14, CURRENT_TIMESTAMP - interval '30 minutes'),
(8, 1, 15, CURRENT_TIMESTAMP - interval '20 minutes'),
-- Завершенные (те самые 9 и 10, которые ты не трогал в items)
(9, 1, 11, CURRENT_TIMESTAMP - interval '15 hours'),
(9, 4, 16, CURRENT_TIMESTAMP - interval '14 hours'),
(10, 1, 12, CURRENT_TIMESTAMP - interval '13 hours'),
(10, 4, 17, CURRENT_TIMESTAMP - interval '12 hours');

SELECT * FROM Order_status_history;

-- Имитация истории бэкапов для отчета
-- Типы: FULL (pg_dump), WAL (архив логов)
INSERT INTO Backups(file_name, backup_type, status, user_id, created_at) VALUES
('full_dump_2026_04_20.dump', 'FULL', 'SUCCESS', 29, CURRENT_TIMESTAMP - interval '9 days'),
('wal_archive_2026_04_21.log', 'WAL', 'SUCCESS', 29, CURRENT_TIMESTAMP - interval '8 days'),
('wal_archive_2026_04_22.log', 'WAL', 'SUCCESS', 30, CURRENT_TIMESTAMP - interval '7 days'),
('full_dump_2026_04_27.dump', 'FULL', 'SUCCESS', 29, CURRENT_TIMESTAMP - interval '2 days'),
('wal_archive_2026_04_28.log', 'WAL', 'SUCCESS', 30, CURRENT_TIMESTAMP - interval '1 day');

SELECT * FROM Backups;


SELECT user_id, username, email FROM Users WHERE username = 'test_client31';

SELECT address_id, user_id, address_text FROM Addresses WHERE user_id = 31;

SELECT order_id, user_id, status_id, total_price, created_at 
FROM Orders 
WHERE user_id = 31 
ORDER BY created_at DESC LIMIT 1;

SELECT order_id, total_price, status_id FROM Orders WHERE order_id = 31;

SELECT * FROM Order_items WHERE order_id = 31;
