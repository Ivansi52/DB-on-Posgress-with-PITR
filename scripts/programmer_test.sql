-- 1. Экспорт данных в JSON (техническая задача)
SELECT export_orders_to_json();

-- 2. Импорт товаров из JSON
CALL import_products_from_json('[{"name": "Пицца", "price": 25.00, "manufacturer": "Пиццерия", "weight": 0.5, "composition": "Тесто, сыр"}]');