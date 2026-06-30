--Триггеры

--Автозапись в историю при смене статуса
CREATE OR REPLACE FUNCTION log_status_change()
RETURNS TRIGGER AS $$
BEGIN
	IF NEW.status_id IS DISTINCT FROM OLD.status_id THEN
		INSERT INTO Order_status_history(order_id, status_id, changed_by_user_id)
   		VALUES(NEW.order_id, NEW.status_id, NULL);
	END IF;
		   
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_after_order_status_change
AFTER UPDATE ON Orders
FOR EACH ROW EXECUTE FUNCTION log_status_change();

--Запрет изменения завершённого заказа
CREATE OR REPLACE FUNCTION check_completed_order()
RETURNS TRIGGER AS $$

DECLARE 
	v_status_name varchar;
BEGIN

	SELECT status_name INTO v_status_name FROM Order_statuses WHERE status_id = OLD.status_id; 
	IF v_status_name = 'delivered' THEN
		RAISE EXCEPTION 'Нельзя изменить завершенный заказ';
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_block_update_completed_order
BEFORE UPDATE OR DELETE ON Orders
FOR EACH ROW EXECUTE FUNCTION check_completed_order();

--Автопересчёт итоговой суммы после какого либо изменения в Order_items
CREATE OR REPLACE FUNCTION recalculate_total()
RETURNS TRIGGER AS $$
DECLARE 
    v_total numeric(10, 2);
    v_order_id bigint;
BEGIN	
    -- Определяем ID заказа в зависимости от действия 
    IF TG_OP = 'DELETE' THEN
        v_order_id := OLD.order_id;
    ELSE
        v_order_id := NEW.order_id;
    END IF;
    
    -- Считаем сумму всех позиций в этом заказе
    SELECT SUM(price * quantity) INTO v_total 
    FROM Order_items 
    WHERE order_id = v_order_id;
    
    -- Обновляем итоговую цену в таблице Orders
    UPDATE Orders 
    SET total_price = COALESCE(v_total, 0) 
    WHERE order_id = v_order_id;

    -- Возвращаем результат 
    IF TG_OP = 'DELETE' THEN 
        RETURN OLD; 
    ELSE 
        RETURN NEW; 
    END IF;
END;
$$ LANGUAGE plpgsql
SECURITY DEFINER        
SET search_path = public; 

CREATE TRIGGER trig_retotal_price
AFTER INSERT OR UPDATE OR DELETE ON Order_items
FOR EACH ROW EXECUTE FUNCTION recalculate_total();

--Запрет изменения или удаления заказа во время доставки
CREATE OR REPLACE FUNCTION prevent_modifying_delivery()
RETURNS TRIGGER AS $$
DECLARE 
    v_status_name varchar;
BEGIN
    SELECT status_name INTO v_status_name FROM Order_statuses WHERE status_id = OLD.status_id;

    IF v_status_name = 'delivering' THEN
        -- Если пытаются изменить данные кроме статуса, блокируем
        IF (NEW.user_id IS DISTINCT FROM OLD.user_id OR 
            NEW.address_id IS DISTINCT FROM OLD.address_id OR 
            NEW.courier_id IS DISTINCT FROM OLD.courier_id) THEN
            RAISE EXCEPTION 'Нельзя изменить данные заказа в процессе доставки';
        END IF;
       
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE TRIGGER trig_inserting_order
BEFORE UPDATE OR DELETE ON Orders 
FOR EACH ROW EXECUTE FUNCTION prevent_modifying_delivery();
