

---Month Report---
-- số lượng sách 1 staff cụ thể quản lý
select count(*) from books join staff on books.staff_id=staff.staff_id where staff.staff_id=1
--thông tin sách quá hạn--
select * from report where status='Overdue';
--người mượn quá hạn trả--
select user_id from users where user_id in (SELECT DISTINCT user_id FROM re WHERE extract(epoch FROM return_date) > extract(epoch FROM due));
--sách đánh giá kém--
SELECT book_id FROM books WHERE avg_star < 2;
--tên tác giả đánh giá cao bởi ng đọc --
SELECT name FROM books join authors on books.author_id=authors.author_id WHERE books.avg_star = (SELECT MAX(avg_star) FROM books);

-----BOOK WAREHOUSE
--top 6 sách yêu thích nhất--
SELECT * FROM books ORDER BY avg_star DESC LIMIT 6
--tổng số lượng sách trong kho
SELECT sum(quantity) FROM books
--tổng số sách đang được mượn off
SELECT COUNT(*) FROM re WHERE Return_date IS NULL
--tổng số sách đọc onl
SELECT COUNT(*) FROM read
--lượng sao trung bình
select sum(avg_star)/count(*) as t from books

---SEARCH FEARTURE
--truy vấn tìm sách dựa trên book id hoặc tên--
SELECT book_id, title, quantity, author_id FROM books WHERE CONCAT(book_id, title, quantity, staff_id) LIKE ($1)

---INDEX---
CREATE INDEX idx_books_staff_id ON books (staff_id);
CREATE INDEX idx_re_return_date_due ON re (return_date, due);
CREATE INDEX idx_books_avg_star ON books (avg_star);
CREATE INDEX idx_books_avg_star_desc ON books (avg_star DESC);



