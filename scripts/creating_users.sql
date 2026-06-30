-- Клиент
CREATE USER test_client WITH PASSWORD 'user123';
GRANT client_role TO test_client;

-- Менеджер
CREATE USER test_manager WITH PASSWORD 'manager123';
GRANT manager_role TO test_manager;

-- Курьер
CREATE USER test_courier WITH PASSWORD 'courier123';
GRANT courier_role TO test_courier;

-- Программист
CREATE USER test_programmer WITH PASSWORD 'programmer123';
GRANT programmer_role TO test_programmer;

--Админ
CREATE USER test_admin WITH PASSWORD 'admin123';
GRANT supervisor_role TO test_admin;