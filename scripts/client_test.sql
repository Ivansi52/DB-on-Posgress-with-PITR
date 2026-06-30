-- Регистрация
CALL register_user('test_client31', 'client31@mail.com', 'pass123');
SELECT user_id, username, email FROM Users WHERE username = 'test_client31';

--Авторизация
SELECT login_user('test_client31', 'pass123') AS authorized_id;

-- Добавить адрес
CALL add_address(31, 'ул. Ленина 15, кв. 5');
SELECT address_id, user_id, address_text FROM Addresses WHERE user_id = 31;
	
-- Создать заказ
CALL create_order(31, 31, 0);
SELECT order_id, user_id, status_id, total_price, created_at 
FROM Orders 
WHERE user_id = 31 
ORDER BY created_at DESC LIMIT 1;

CALL add_item_to_order(31, 31, 1, 3); -- 3 шт. товара 1
CALL add_item_to_order(31, 31, 5, 1); -- 1 шт товара 5

-- Посмотреть статус заказа
SELECT get_order_status(31, 31) AS "Текущий статус заказа";

-- История заказов
SELECT * FROM get_order_history(31);
