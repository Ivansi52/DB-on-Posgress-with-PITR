-- Посмотреть заказы для курьера №16
SELECT * FROM get_courier_orders(16);

-- Курьер №16 берет заказ №1
CALL update_delivery_status(32, 16, 'delivering');
SELECT * FROM Order_status_history WHERE order_id = 1 ORDER BY changed_at DESC;

-- Подтвердить доставку
CALL complete_delivery(32, 16);
SELECT * FROM get_courier_orders(16) WHERE order_id = 32;

