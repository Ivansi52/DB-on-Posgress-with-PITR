--Импорт и экспорт в json
--Импорт продуктов 
CREATE OR REPLACE PROCEDURE import_products_from_json(p_json json)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_item json;
	
BEGIN
    FOR v_item IN SELECT json_array_elements(p_json)
    LOOP
        INSERT INTO Products(name, price, manufacturer, weight, composition)
        VALUES(
            v_item->>'name',
            (v_item->>'price')::numeric,
            v_item->>'manufacturer',
            (v_item->>'weight')::float8,
            v_item->>'composition'
        );
    END LOOP;
	
END;
$$;
--Импорт юзеров
CREATE OR REPLACE PROCEDURE import_users_from_json(p_json json)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_item json;
    v_user_id bigint;
    v_role_id bigint;
BEGIN
    FOR v_item IN SELECT json_array_elements(p_json)
    LOOP
        INSERT INTO Users(username, email, password, status)
        VALUES(
            v_item->>'username',
            v_item->>'email',
            v_item->>'password',
            COALESCE(v_item->>'status', 'active')
        )
        RETURNING user_id INTO v_user_id;
        
        SELECT role_id INTO v_role_id FROM Roles 
        WHERE role_name = v_item->>'role_name';
        
        IF v_role_id IS NOT NULL THEN
            INSERT INTO User_roles(user_id, role_id)
            VALUES(v_user_id, v_role_id);
        END IF;
    END LOOP;
END;
$$;
--Экспорт заказов
CREATE OR REPLACE FUNCTION export_orders_to_json()
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN (
        SELECT json_agg(
            json_build_object(
                'order_id', o.order_id,
                'username', u.username,
                'address', a.address_text,
                'status', os.status_name,
                'total_price', o.total_price,
                'created_at', o.created_at
            )
        )
        FROM Orders o
        JOIN Users u ON o.user_id = u.user_id
        JOIN Addresses a ON o.address_id = a.address_id
        JOIN Order_statuses os ON o.status_id = os.status_id
    );
	
END;
$$;
--Экспорт продуктов
CREATE OR REPLACE FUNCTION export_products_to_json()
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN (
        SELECT json_agg(
            json_build_object(
                'product_id', p.product_id,
                'name', p.name,
                'price', p.price,
                'manufacturer', p.manufacturer,
                'weight', p.weight,
                'composition', p.composition
            )
        )
        FROM Products p
    );
	
END;
$$;