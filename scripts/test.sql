--импорт json
--Импорт продуктов
CALL import_products_from_json('[
    {"name": "Молоко", "price": 2.50, "manufacturer": "Савушкин", "weight": 1.0, "composition": "Молоко цельное"},
    {"name": "Хлеб", "price": 1.20, "manufacturer": "Хлебозавод", "weight": 0.5, "composition": "Мука, вода, соль"},
    {"name": "Масло", "price": 3.80, "manufacturer": "Савушкин", "weight": 0.2, "composition": "Сливки"}
]');

SELECT * FROM Products WHERE name IN ('Молоко', 'Хлеб', 'Масло');

--Из файла
DO $$
DECLARE
    v_json json;
BEGIN
    SELECT pg_read_file('D:/course_proj_DB/imports/products.json')::json 
    INTO v_json;
    
    CALL import_products_from_json(v_json);
END;
$$;

SELECT * FROM Products ORDER BY product_id DESC LIMIT 10;
--экпорт json
COPY (SELECT export_products_to_json()) 
TO 'D:/course_proj_DB/exports/products.json';