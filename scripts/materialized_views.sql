--Материализованные представления
-- 1. Статистика по курьерам (только доставленные заказы)
CREATE MATERIALIZED VIEW courier_statistics AS
SELECT 
    o.courier_id, 
    u.username, 
    COUNT(o.order_id) AS total_orders, 
    SUM(o.total_price) AS total_earned
FROM Orders o
JOIN Users u ON o.courier_id = u.user_id
JOIN Order_statuses os ON o.status_id = os.status_id
WHERE os.status_name = 'delivered'
GROUP BY o.courier_id, u.username;

-- 2. Активные заказы (те, что в процессе)
CREATE MATERIALIZED VIEW active_orders AS 
SELECT 
    o.order_id, 
    u.username AS client_name, 
    a.address_text, 
    os.status_name, 
    o.created_at
FROM Orders o
JOIN Users u ON o.user_id = u.user_id
JOIN Addresses a ON o.address_id = a.address_id
JOIN Order_statuses os ON o.status_id = os.status_id
WHERE os.status_name NOT IN ('delivered', 'cancelled');

-- 3. Популярные товары (топ продаж)
CREATE MATERIALIZED VIEW popular_products AS
SELECT 
    p.product_id, 
    p.name, 
    SUM(oi.quantity) AS units_sold, 
    SUM(oi.price * oi.quantity) AS total_revenue
FROM Order_items oi
JOIN Products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.name
ORDER BY units_sold DESC;