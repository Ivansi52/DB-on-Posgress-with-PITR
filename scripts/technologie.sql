--Технология системы резервного копирования и восстановления БД
--Тест
INSERT INTO Products( name, price, manufacturer, weight, composition)
VALUES( 'TEST', '1001020', 'TEST', '123', 'TEST');

SELECT * FROM Products WHERE name = 'TEST';

SELECT pg_switch_wal();