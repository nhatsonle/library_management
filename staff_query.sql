
--staff task--
--sách mà staff 1 quản lý
select * from books
join staff on books.staff_id=staff.staff_id
where staff.staff_id=1
--sách, người quá hạn trả--
select * from report
where status='Overdue'
--người quá hạn trả--
select * from users
where user_id in (SELECT DISTINCT user_id FROM re WHERE extract(epoch FROM return_date) > extract(epoch FROM due));
-- số người đã từng mượn sách--
select count(*) from users
where user_id in (SELECT DISTINCT user_id FROM re WHERE extract(epoch FROM reserve_date) < extract(epoch FROM now()));
--sách nhiều sao nhất--
SELECT *
FROM books
WHERE avg_star = (SELECT MAX(avg_star) FROM books);
--sách dưới 2 sao--
SELECT COUNT(*) AS num_books_above_2_stars
FROM books
WHERE avg_star < 2;












   
