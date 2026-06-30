--Индексы
--Для продуктов (поиск по имени продукта)
CREATE INDEX idx_products_name ON Products(name);

-- Для авторизации (поиск пользователя по email и логину)
CREATE INDEX idx_users_email ON Users(email);
CREATE INDEX idx_users_username ON Users(username);

-- Для клиента (чтобы история заказов открывалась мгновенно)
CREATE INDEX idx_orders_user_id ON Orders(user_id);

-- Для курьера (чтобы список назначенных заказов не тормозил)
CREATE INDEX idx_orders_courier_id ON Orders(courier_id);

-- Для менеджера (быстрая фильтрация по статусам)
CREATE INDEX idx_orders_status_id ON Orders(status_id);

-- Для работы с составом заказов (связь Orders + Order_items)
CREATE INDEX idx_order_items_order_id ON Order_items(order_id);