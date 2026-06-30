-- Создать пользователя
CALL create_user('ivan', 'ivan@mail.com', 'pass123', 'client_role');

SELECT u.user_id, u.username, u.email, r.role_name, u.status
FROM Users u
JOIN User_roles ur ON u.user_id = ur.user_id
JOIN Roles r ON ur.role_id = r.role_id
WHERE u.username = 'ivan_admin_test';

-- Удалить пользователя
CALL delete_user(33);

SELECT * FROM Users WHERE user_id = 33;



-- Заблокировать пользователя
CALL block_user(33);

SELECT user_id, username, status FROM Users WHERE user_id = 33;


-- Дать роль
CALL add_role(33, 'manager_role');

SELECT u.username, r.role_name 
FROM User_roles ur
JOIN Roles r ON ur.role_id = r.role_id
JOIN Users u ON ur.user_id = u.user_id
WHERE u.user_id = 33;

-- Изменить роль
CALL update_role(1, 'client_role', 'manager_role');

-- Удалить роль
CALL remove_role(1, 'manager_role');

-- Логирование бэкапа
CALL create_backup('FULL');

SELECT backup_id, file_name, backup_type, status, created_at 
FROM Backups 
ORDER BY created_at DESC 
LIMIT 2;

-- Логирование восстановления
CALL log_restore('FULL');