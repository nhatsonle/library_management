--Trigger cập nhật số lượng sách khi có người đặt sách (reserve):
-- Khi người dùng đặt sách, số lượng sách có sẵn sẽ giảm đi 1


CREATE OR REPLACE FUNCTION update_book_quantity_on_reserve()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE books
    SET quantity = quantity - 1
    WHERE book_id = NEW.book_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_book_quantity_on_reserve
AFTER INSERT ON re
FOR EACH ROW
EXECUTE FUNCTION update_book_quantity_on_reserve();


--Trigger khôi phục số lượng sách khi trả sách (return)**:
--Khi người dùng trả sách, số lượng sách có sẵn sẽ tăng lên 1.

CREATE OR REPLACE FUNCTION update_book_quantity_on_return()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE books
    SET quantity = quantity + 1
    WHERE book_id = NEW.book_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_book_quantity_on_return
AFTER DELETE ON re
FOR EACH ROW
EXECUTE FUNCTION update_book_quantity_on_return();






--Trigger gửi thông báo khi gần đến hạn trả sách 

CREATE OR REPLACE FUNCTION notify_due_books() 

RETURNS TRIGGER AS $$ 

BEGIN 

    IF NEW.due <= CURRENT_TIMESTAMP + INTERVAL '2 days' THEN 

        PERFORM pg_notify('book_due', 'Book ' || NEW.book_id || ' is due soon.'); 

    END IF; 

    RETURN NEW; 

END; 

$$ LANGUAGE plpgsql; 

  

CREATE TRIGGER due_books_notification 

AFTER INSERT OR UPDATE ON re 

FOR EACH ROW EXECUTE FUNCTION notify_due_books(); 



--Tạo danh sách các cuốn sách được đánh giá cao (vd: số sao lớn hơn 3) 

select b.book_id, b.title, read.star 

from books b 

join read 

on b.book_id = read.book_id 

where star > 3 







Việc viết các trigger cho cơ sở dữ liệu quản lý thư viện này sẽ giúp tự động hoá một số tác vụ quan trọng và đảm bảo tính nhất quán của dữ liệu. Dưới đây là năm trigger mẫu thực hiện một số chức năng đã liệt kê:

1. **Trigger cập nhật số lượng sách khi có người đặt sách (reserve)**:
   - Khi người dùng đặt sách, số lượng sách có sẵn sẽ giảm đi 1.

```sql
CREATE OR REPLACE FUNCTION update_book_quantity_on_reserve()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE books
    SET quantity = quantity - 1
    WHERE book_id = NEW.book_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_book_quantity_on_reserve
AFTER INSERT ON reserve
FOR EACH ROW
EXECUTE FUNCTION update_book_quantity_on_reserve();
```

2. **Trigger khôi phục số lượng sách khi trả sách (return)**:
   - Khi người dùng trả sách, số lượng sách có sẵn sẽ tăng lên 1.

```sql
CREATE OR REPLACE FUNCTION update_book_quantity_on_return()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE books
    SET quantity = quantity + 1
    WHERE book_id = NEW.book_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_book_quantity_on_return
AFTER DELETE ON reserve
FOR EACH ROW
EXECUTE FUNCTION update_book_quantity_on_return();
```

3. **Trigger tự động gửi thông báo khi sắp đến ngày trả sách**:
   - Gửi thông báo tới người dùng khi sắp đến ngày trả sách (trước 3 ngày).

```sql
CREATE OR REPLACE FUNCTION notify_user_before_due_date()
RETURNS TRIGGER AS $$
DECLARE
    v_user_id INTEGER;
BEGIN
    SELECT user_id INTO v_user_id
    FROM reserve
    WHERE reserve.book_id = NEW.book_id;

    INSERT INTO notifications (user_id, message, created_at)
    VALUES (v_user_id, 'Your reserved book is nearing its due date.', NOW());

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_notify_user_before_due_date
AFTER INSERT ON reserve
FOR EACH ROW
WHEN (NEW.due_date - CURRENT_DATE <= 3)
EXECUTE FUNCTION notify_user_before_due_date();
```

4. **Trigger cập nhật trạng thái sách khi có thay đổi (update/delete)**:
   - Khi có bất kỳ thay đổi nào về sách, cập nhật trạng thái sách tương ứng.

```sql
CREATE OR REPLACE FUNCTION update_book_status()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.quantity = 0 THEN
        UPDATE books
        SET status = 'Not Available'
        WHERE book_id = NEW.book_id;
    ELSE
        UPDATE books
        SET status = 'Available'
        WHERE book_id = NEW.book_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_book_status
AFTER UPDATE OR DELETE ON books
FOR EACH ROW
EXECUTE FUNCTION update_book_status();
```

5. **Trigger gửi thông báo cho nhân viên về sách có đánh giá thấp**:
   - Khi một cuốn sách có đánh giá thấp hơn 2 sao, gửi thông báo tới nhân viên.

```sql
CREATE OR REPLACE FUNCTION notify_staff_on_low_rating()
RETURNS TRIGGER AS $$
DECLARE
    v_staff_id INTEGER;
BEGIN
    SELECT staff_id INTO v_staff_id
    FROM books
    WHERE book_id = NEW.book_id;

    IF NEW.star < 2 THEN
        INSERT INTO notifications (user_id, message,