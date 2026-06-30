--ДЛЯ АДМИН РОЛИ
--Процедура create user админ роль
CREATE OR REPLACE PROCEDURE create_user(
	p_username varchar,
	p_email varchar,
	p_password varchar,
	p_role_name varchar
)

LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
	v_user_id bigint;
	v_role_id bigint;
	
BEGIN

--Проверка на существование пользователя с таким именем
IF EXISTS(SELECT 1 FROM Users WHERE username = p_username) THEN
	RAISE EXCEPTION 'Пользователь с таким именем уже существует';
END IF;

--Проверка на существование пользователя с таким email
IF EXISTS(SELECT 1 FROM Users WHERE email=p_email) THEN
	RAISE EXCEPTION 'Пользователь с таким email уже существует';
END IF;

--Создание пользователя
INSERT INTO Users(username, email, password, status)
VALUES(p_username, p_email, p_password, 'active')
RETURNING user_id INTO v_user_id;

--Проверка роли
SELECT role_id INTO v_role_id
FROM Roles
WHERE role_name = p_role_name;

IF v_role_id IS NULL THEN
	RAISE EXCEPTION 'Роль не найдена';
END IF;

INSERT INTO User_roles(user_id, role_id)
VALUES(v_user_id, v_role_id);

END;
$$;

--Удаление пользователя для админ роли
CREATE OR REPLACE PROCEDURE delete_user(p_user_id bigint)

LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$ 	

BEGIN
	IF NOT EXISTS(SELECT 1 FROM Users WHERE user_id = p_user_id) THEN
		RAISE EXCEPTION 'Такого пользователя - нет';
	END IF;
	
	DELETE FROM Users 
	WHERE user_id = p_user_id;

END;
$$;

--Блок юзера для админ роли
CREATE OR REPLACE PROCEDURE block_user(p_user_id bigint)

LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$

BEGIN 
	IF NOT EXISTS(SELECT 1 FROM Users WHERE user_id = p_user_id) THEN
		RAISE EXCEPTION 'Пользователя не существует, блокировать некого';
	END IF;

	IF EXISTS(SELECT 1 FROM Users WHERE status='blocked' AND user_id = p_user_id) THEN
		RAISE EXCEPTION 'Пользователь уже заблокирован';
	END IF;

	UPDATE Users 
	SET status = 'blocked' 
	WHERE user_id = p_user_id;
	END;
	$$;

--Дать роль юзеру для админ роли
CREATE OR REPLACE PROCEDURE add_role(p_user_id bigint, p_role_name varchar)

LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$

DECLARE 
	v_role_id bigint;
		
BEGIN

	IF NOT EXISTS(SELECT 1 FROM Users WHERE user_id = p_user_id) THEN
		RAISE EXCEPTION 'Пользователя не существует';
	END IF;

    SELECT role_id INTO v_role_id FROM Roles WHERE role_name = p_role_name;
		IF v_role_id IS NULL THEN
			RAISE EXCEPTION 'Роль не найдена';
		END IF;

	IF EXISTS(SELECT 1 FROM User_roles WHERE user_id = p_user_id AND role_id = v_role_id) THEN
		RAISE EXCEPTION 'У пользователя уже есть эта роль';
	END IF;
	
	INSERT INTO User_roles(user_id, role_id) 
	VALUES(p_user_id, v_role_id);
END;
$$;	

--Изменение роли пользователя для админ роли
CREATE OR REPLACE PROCEDURE update_role(p_user_id bigint, p_old_role_name varchar, p_new_role_name varchar)

LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$ 

DECLARE 
    old_role_id bigint;
    new_role_id bigint;
	
BEGIN

    IF NOT EXISTS(SELECT 1 FROM Users WHERE user_id = p_user_id) THEN
        RAISE EXCEPTION 'Пользователя не существует';
    END IF;
    
    SELECT role_id INTO old_role_id FROM Roles WHERE role_name = p_old_role_name;
    IF old_role_id IS NULL THEN
        RAISE EXCEPTION 'Старая роль не найдена';
    END IF;
    
    IF NOT EXISTS(SELECT 1 FROM User_roles WHERE user_id = p_user_id AND role_id = old_role_id) THEN
        RAISE EXCEPTION 'У пользователя нет этой роли';
    END IF;
    
    SELECT role_id INTO new_role_id FROM Roles WHERE role_name = p_new_role_name;
    IF new_role_id IS NULL THEN
        RAISE EXCEPTION 'Новая роль не найдена';
    END IF;
    
    IF EXISTS(SELECT 1 FROM User_roles WHERE user_id = p_user_id AND role_id = new_role_id) THEN
        RAISE EXCEPTION 'У пользователя уже есть эта роль';
    END IF;
    
    DELETE FROM User_roles 
	WHERE user_id = p_user_id AND role_id = old_role_id;
	
	INSERT INTO User_roles(user_id, role_id)
	VALUES(p_user_id, new_role_id);
	END;
	$$;

	--Удалить роль для админ роли
	CREATE OR REPLACE PROCEDURE remove_role(
    p_user_id bigint,
    p_role_name varchar
	)
	LANGUAGE plpgsql
	SECURITY DEFINER
	SET search_path = public
	AS $$
	DECLARE
	    v_role_id bigint;
	BEGIN
	    SELECT role_id INTO v_role_id 
	    FROM Roles 
	    WHERE role_name = p_role_name;

		IF NOT EXISTS(SELECT 1 FROM Users WHERE user_id = p_user_id) THEN
   			RAISE EXCEPTION 'Пользователь не найден';
		END IF;
	
	    IF v_role_id IS NULL THEN
	        RAISE EXCEPTION 'Роль не найдена';
	    END IF;
		
		IF NOT EXISTS(SELECT 1 FROM User_roles WHERE user_id = p_user_id AND role_id = v_role_id) THEN
    		RAISE EXCEPTION 'У пользователя нет этой роли';
		END IF;
	
	    DELETE FROM User_roles 
	    WHERE user_id = p_user_id AND role_id = v_role_id;
	
	END;
	$$;

--логирование бэкапа
CREATE OR REPLACE PROCEDURE create_backup(p_backup_type varchar)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_file_name varchar;
BEGIN
    v_file_name := p_backup_type || '_backup_' || to_char(CURRENT_TIMESTAMP, 'YYYY_MM_DD_HH24_MI_SS');
    
    INSERT INTO Backups(file_name, backup_type, status)
    VALUES(v_file_name, p_backup_type, 'completed');
END;
$$;

--логирование восстановлений
CREATE OR REPLACE PROCEDURE log_restore(p_backup_type varchar)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO Backups(file_name, backup_type, status)
    VALUES('restore_' || to_char(CURRENT_TIMESTAMP, 'YYYY_MM_DD_HH24_MI_SS'), p_backup_type, 'restored');
END;
$$;

--создание заказа
CREATE OR REPLACE PROCEDURE create_order(
	p_user_id bigint,
	p_address_id bigint,
	p_total_price numeric(10, 2)
)

LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$

DECLARE
	v_status_id bigint;

BEGIN

	IF NOT EXISTS(SELECT 1 FROM Users WHERE user_id = p_user_id) THEN
		RAISE EXCEPTION 'Пользователь не найден';
	END IF;

	IF NOT EXISTS(SELECT 1 FROM Addresses WHERE address_id = p_address_id) THEN
		RAISE EXCEPTION 'Такого адреса не существует';
	END IF;

	SELECT status_id INTO v_status_id FROM Order_statuses WHERE status_name = 'created';
    IF v_status_id IS NULL THEN
        RAISE EXCEPTION 'Статус created не найден';
    END IF;
    
    INSERT INTO Orders(user_id, address_id, status_id, total_price)
    VALUES(p_user_id, p_address_id, v_status_id, 0);
	
END;
$$;

--изменение заказа
CREATE OR REPLACE PROCEDURE update_order(
	p_order_id bigint,
	p_address_id bigint,
	p_total_price numeric(10, 2)
)

LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$

BEGIN

	IF NOT EXISTS(SELECT 1 FROM Orders WHERE order_id = p_order_id) THEN
		RAISE EXCEPTION 'Такого заказа не существует';
	END IF;

	IF NOT EXISTS(SELECT 1 FROM Addresses WHERE address_id = p_address_id) THEN
    	RAISE EXCEPTION 'Адрес не существует';
	END IF;

	UPDATE Orders 
	SET address_id = p_address_id, total_price = p_total_price 
	WHERE order_id = p_order_id;

END;
$$;

--удаление заказа
CREATE OR REPLACE PROCEDURE delete_order(
	p_order_id bigint
)

LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$

BEGIN

	IF NOT EXISTS(SELECT 1 FROM Orders WHERE order_id = p_order_id) THEN
		RAISE EXCEPTION 'Такого заказа не существует';
	END IF;

	DELETE FROM Order_items WHERE order_id = p_order_id;
	DELETE FROM Order_status_history WHERE order_id = p_order_id;
	DELETE FROM Orders WHERE order_id = p_order_id;

END;
$$;

--Для менеджера
CREATE OR REPLACE PROCEDURE assign_courier(
	p_order_id bigint,
	p_courier_id bigint
)

LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$

BEGIN

	IF NOT EXISTS(SELECT 1 FROM Orders WHERE order_id = p_order_id) THEN
		RAISE EXCEPTION 'Такого заказа не существует';
	END IF;

	IF NOT EXISTS(
	    SELECT 1 FROM Users u
	    JOIN User_roles ur ON u.user_id = ur.user_id
	    JOIN Roles r ON ur.role_id = r.role_id
	    WHERE u.user_id = p_courier_id AND r.role_name = 'courier_role' AND u.status = 'active'
	) THEN
	    RAISE EXCEPTION 'Такого курьера не существует';
	END IF;

	UPDATE Orders 
	SET courier_id = p_courier_id
	WHERE order_id = p_order_id;

END;
$$;

CREATE OR REPLACE PROCEDURE update_order_status(
	p_order_id bigint,
	p_status_name varchar(50),
	p_manager_id bigint
)

LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$

DECLARE 
	v_status_id bigint;

BEGIN

	IF NOT EXISTS(SELECT 1 FROM Orders WHERE order_id = p_order_id) THEN
		RAISE EXCEPTION 'Такого заказа не существует';
	END IF;
	IF NOT EXISTS(SELECT 1 FROM Users WHERE user_id = p_manager_id) THEN
    	RAISE EXCEPTION 'Менеджер не найден';
	END IF;

	SELECT status_id INTO v_status_id FROM Order_statuses WHERE status_name = p_status_name;
    IF v_status_id IS NULL THEN
        RAISE EXCEPTION 'Статус не найден';
    END IF;

	UPDATE Orders 
	SET status_id = v_status_id 
	WHERE order_id = p_order_id;

	INSERT INTO Order_status_history(order_id, status_id, changed_by_user_id)
	VALUES(p_order_id, v_status_id, p_manager_id);

END;
$$;

CREATE OR REPLACE FUNCTION get_reports(
    p_date_from timestamp,
    p_date_to timestamp
)
RETURNS TABLE(
    courier_id bigint,
    courier_name varchar,
    orders_count bigint,
    total_sum numeric
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        o.courier_id,
        u.username,
        COUNT(o.order_id),
		COALESCE(SUM(o.total_price), 0)
	FROM Orders o
    JOIN Users u ON o.courier_id = u.user_id
    WHERE o.created_at BETWEEN p_date_from AND p_date_to
    GROUP BY o.courier_id, u.username;
END;
$$;

--ДЛЯ КЛИЕНТА
CREATE OR REPLACE PROCEDURE register_user(
	p_username varchar(50),
	p_email varchar(100),
	p_password varchar(255)
)

LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$

DECLARE 
	v_user_id bigint;
	v_role_id bigint;

BEGIN

	IF EXISTS(SELECT 1 FROM Users WHERE username = p_username) THEN
		RAISE EXCEPTION 'Такой username уже существует';
	END IF;

	IF EXISTS(SELECT 1 FROM Users WHERE email = p_email) THEN
		RAISE EXCEPTION 'Такой email уже существует';
	END IF;

	SELECT role_id INTO v_role_id FROM Roles WHERE role_name = 'client_role';

	
	IF v_role_id IS NULL THEN
    	RAISE EXCEPTION 'Роль client_role не найдена';
	END IF;

	INSERT INTO Users(username, email, password, status) 
	VALUES(p_username, p_email, p_password, 'active')
	RETURNING user_id INTO v_user_id;
    
    INSERT INTO User_roles(user_id, role_id)
    VALUES(v_user_id, v_role_id);
END;
$$;

CREATE OR REPLACE FUNCTION login_user(
    p_username varchar,
    p_password varchar
)
RETURNS bigint
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id bigint;
BEGIN
    SELECT user_id INTO v_user_id
    FROM Users
    WHERE username = p_username AND password = p_password AND status = 'active';

    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Неверное имя пользователя или пароль, либо аккаунт заблокирован';
    END IF;

    RETURN v_user_id;
END;
$$;

CREATE OR REPLACE FUNCTION get_order_status(
	p_order_id bigint,
	p_user_id bigint
)

RETURNS varchar

LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$

DECLARE 
	v_status_name varchar(50);

BEGIN

	IF NOT EXISTS(SELECT 1 FROM Orders WHERE order_id = p_order_id) THEN
		RAISE EXCEPTION 'Такого заказа не существует';
	END IF;

	IF NOT EXISTS(SELECT 1 FROM Orders WHERE order_id = p_order_id AND user_id = p_user_id) THEN
		RAISE EXCEPTION 'Заказ не принадлежит пользователю';
	END IF;

	SELECT os.status_name INTO v_status_name 
    FROM Orders o
    JOIN Order_statuses os ON o.status_id = os.status_id
    WHERE o.order_id = p_order_id;
    
    RETURN v_status_name;

END;
$$;

CREATE OR REPLACE FUNCTION get_order_history(
    p_user_id bigint
)

RETURNS TABLE(
    order_id bigint,
    created_at timestamp,
    total_price numeric,
    status_name varchar
)

LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$

BEGIN

    IF NOT EXISTS(SELECT 1 FROM Users WHERE user_id = p_user_id) THEN
        RAISE EXCEPTION 'Такого пользователя не существует';
    END IF;
    
    RETURN QUERY
	
    SELECT 
        o.order_id,
        o.created_at,
        o.total_price,
        os.status_name
    FROM Orders o
    JOIN Order_statuses os ON o.status_id = os.status_id
    WHERE o.user_id = p_user_id
    ORDER BY o.created_at DESC;
	
END;
$$;

CREATE OR REPLACE PROCEDURE add_address(
	p_user_id bigint,
	p_address_text varchar
)

LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$

BEGIN

	IF NOT EXISTS(SELECT 1 FROM Users WHERE user_id = p_user_id) THEN
        RAISE EXCEPTION 'Такого пользователя не существует';
    END IF;

	INSERT INTO Addresses(user_id, address_text)
	VALUES(p_user_id, p_address_text);

END;
$$;

CREATE OR REPLACE PROCEDURE add_item_to_order(
    p_order_id bigint,
    p_user_id bigint, -- Проверяем, что это заказ именно этого клиента!
    p_product_id bigint,
    p_quantity int
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_price numeric(10,2);
BEGIN
    -- Проверяем что заказ принадлежит именно этому пользователю
    IF NOT EXISTS (SELECT 1 FROM Orders WHERE order_id = p_order_id AND user_id = p_user_id) THEN
        RAISE EXCEPTION 'Заказ не найден или не принадлежит данному пользователю';
    END IF;

    -- Берем цену товара из таблицы Products
    SELECT price INTO v_price FROM Products WHERE product_id = p_product_id;
    
    IF v_price IS NULL THEN
        RAISE EXCEPTION 'Товар не найден';
    END IF;

    -- Добавление товара в заказ
    INSERT INTO Order_items (order_id, product_id, quantity, price)
    VALUES (p_order_id, p_product_id, p_quantity, v_price);
    
END;
$$;

--Для курьера
CREATE OR REPLACE FUNCTION get_courier_orders(p_courier_id bigint)

RETURNS TABLE(
    order_id bigint,
    created_at timestamp,
    total_price numeric,
    status_name varchar
)

LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$

BEGIN

    IF NOT EXISTS(SELECT 1 FROM Users WHERE user_id = p_courier_id) THEN
        RAISE EXCEPTION 'Такого курьера не существует';
    END IF;
	
    RETURN QUERY
	
    SELECT o.order_id, o.created_at, o.total_price, os.status_name
    FROM Orders o
    JOIN Order_statuses os ON o.status_id = os.status_id
    WHERE o.courier_id = p_courier_id;
	
END;
$$;

CREATE OR REPLACE PROCEDURE update_delivery_status(
    p_order_id bigint,
    p_courier_id bigint,
    p_status_name varchar(50)
)

LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$

DECLARE
    v_status_id bigint;
	
BEGIN

    IF NOT EXISTS(SELECT 1 FROM Orders WHERE order_id = p_order_id) THEN
        RAISE EXCEPTION 'Такого заказа не существует';
    END IF;
	
    IF NOT EXISTS(SELECT 1 FROM Orders WHERE order_id = p_order_id AND courier_id = p_courier_id) THEN
        RAISE EXCEPTION 'Заказ не назначен этому курьеру';
    END IF;
	
    SELECT status_id INTO v_status_id FROM Order_statuses WHERE status_name = p_status_name;
    IF v_status_id IS NULL THEN
        RAISE EXCEPTION 'Статус не найден';
    END IF;
	
    UPDATE Orders SET status_id = v_status_id WHERE order_id = p_order_id;
    INSERT INTO Order_status_history(order_id, status_id, changed_by_user_id)
    VALUES(p_order_id, v_status_id, p_courier_id);
	
END;
$$;

CREATE OR REPLACE PROCEDURE complete_delivery(
    p_order_id bigint,
    p_courier_id bigint
)

LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$

DECLARE
    v_status_id bigint;
	
BEGIN

    IF NOT EXISTS(SELECT 1 FROM Orders WHERE order_id = p_order_id) THEN
        RAISE EXCEPTION 'Такого заказа не существует';
    END IF;
	
    IF NOT EXISTS(SELECT 1 FROM Orders WHERE order_id = p_order_id AND courier_id = p_courier_id) THEN
        RAISE EXCEPTION 'Заказ не назначен этому курьеру';
    END IF;
	
    SELECT status_id INTO v_status_id FROM Order_statuses WHERE status_name = 'delivered';
    IF v_status_id IS NULL THEN
        RAISE EXCEPTION 'Статус delivered не найден';
    END IF;
	
    UPDATE Orders SET status_id = v_status_id WHERE order_id = p_order_id;
    INSERT INTO Order_status_history(order_id, status_id, changed_by_user_id)
    VALUES(p_order_id, v_status_id, p_courier_id);
	
END;
$$;
