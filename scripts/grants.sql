-- Отнимаем вообще всё у всех ролей и у публичной группы (PUBLIC) в схеме public
REVOKE ALL ON SCHEMA public FROM public, supervisor_role, manager_role, courier_role, client_role, programmer_role;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM public, supervisor_role, manager_role, courier_role, client_role, programmer_role;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM public, supervisor_role, manager_role, courier_role, client_role, programmer_role;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM public, supervisor_role, manager_role, courier_role, client_role, programmer_role;
REVOKE ALL ON ALL PROCEDURES IN SCHEMA public FROM public, supervisor_role, manager_role, courier_role, client_role, programmer_role;

-- ШАГ 2: БАЗОВЫЙ ДОСТУП
-- Разрешаем ролям "видеть" схему public, иначе они не смогут к ней обратиться
GRANT USAGE ON SCHEMA public TO supervisor_role, manager_role, courier_role, client_role, programmer_role;


-- ШАГ 3: ПРАВА ДЛЯ БИЗНЕС-РОЛЕЙ (ТОЛЬКО ЗАПУСК ФУНКЦИЙ)
-- У этих ролей НЕТ прав на SELECT/INSERT/UPDATE таблиц. 
-- Доступ только через SECURITY DEFINER процедуры.

-- КЛИЕНТ (client_role)
GRANT EXECUTE ON PROCEDURE register_user(varchar, varchar, varchar) TO client_role;
GRANT EXECUTE ON FUNCTION login_user(varchar, varchar) TO client_role;
GRANT EXECUTE ON PROCEDURE create_order(bigint, bigint, numeric) TO client_role;
GRANT EXECUTE ON FUNCTION get_order_status(bigint, bigint) TO client_role;
GRANT EXECUTE ON FUNCTION get_order_history(bigint) TO client_role;
GRANT EXECUTE ON PROCEDURE add_address(bigint, varchar) TO client_role;
GRANT EXECUTE ON PROCEDURE add_item_to_order(bigint, bigint, bigint, int) TO client_role;

-- МЕНЕДЖЕР (manager_role)
GRANT EXECUTE ON PROCEDURE create_order(bigint, bigint, numeric) TO manager_role;
GRANT EXECUTE ON PROCEDURE update_order(bigint, bigint, numeric) TO manager_role;
GRANT EXECUTE ON PROCEDURE delete_order(bigint) TO manager_role;
GRANT EXECUTE ON PROCEDURE assign_courier(bigint, bigint) TO manager_role;
GRANT EXECUTE ON PROCEDURE update_order_status(bigint, varchar, bigint) TO manager_role;
GRANT EXECUTE ON FUNCTION get_reports(timestamp, timestamp) TO manager_role;

-- КУРЬЕР (courier_role)
GRANT EXECUTE ON FUNCTION get_courier_orders(bigint) TO courier_role;
GRANT EXECUTE ON PROCEDURE update_delivery_status(bigint, bigint, varchar) TO courier_role;
GRANT EXECUTE ON PROCEDURE complete_delivery(bigint, bigint) TO courier_role;


-- ШАГ 4: ПРАВА ДЛЯ ТЕХНИЧЕСКИХ РОЛЕЙ (ПОЛНЫЙ ДОСТУП)

-- АДМИНИСТРАТОР (supervisor_role)
-- Нужен полный доступ для управления пользователями и запуска pg_dump
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO supervisor_role;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO supervisor_role;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO supervisor_role;
GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA public TO supervisor_role;

-- ПРОГРАММИСТ (programmer_role)
-- Нужен доступ для изменения процедур, создания индексов и тестов производительности
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO programmer_role;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO programmer_role;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO programmer_role;
GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA public TO programmer_role;