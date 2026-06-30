-- Создать заказ для клиента №1
CALL create_order(1, 1, 150.00); 
SELECT order_id, user_id, status_id, total_price, created_at 
FROM Orders 
WHERE user_id = 1 
ORDER BY created_at DESC LIMIT 1;

-- Назначить курьера (ID из диапазона 16-25)
CALL assign_courier(32, 16); 
SELECT order_id, user_id, courier_id 
FROM Orders 
WHERE order_id = 1;

-- Изменить статус (менеджер №11)
CALL update_order_status(32, 'accepted', 11);

SELECT o.order_id, os.status_name 
FROM Orders o
JOIN Order_statuses os ON o.status_id = os.status_id
WHERE o.order_id = 1;

--Проверка работы триггера записи в лог
SELECT * FROM Order_status_history 
WHERE order_id = 1 
ORDER BY changed_at DESC;

-- Отчёт
SELECT * FROM get_reports('2026-01-01'::timestamp, '2026-12-31'::timestamp);
