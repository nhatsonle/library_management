--1.Get the most active users (who have read or reserved the most books)
CREATE OR REPLACE FUNCTION get_most_active_users(p_limit INT) RETURNS TABLE (
    user_id INT,
    user_name VARCHAR,
    activity_count INT
)
AS $$
BEGIN
    RETURN QUERY 
    SELECT u.user_id, u.user_name, COALESCE(r.read_count, 0) + COALESCE(re.reserve_count, 0) AS activity_count
    FROM users u
    LEFT JOIN (
        SELECT user_id, COUNT(*) AS read_count
        FROM read
        GROUP BY user_id
    ) r ON u.user_id = r.user_id
    LEFT JOIN (
        SELECT user_id, COUNT(*) AS reserve_count
        FROM re
        GROUP BY user_id
    ) re ON u.user_id = re.user_id
    ORDER BY activity_count DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

--2.Get the authors with the highest average book rating
CREATE OR REPLACE FUNCTION get_top_rated_authors(p_limit INT) RETURNS TABLE (
    author_id INT,
    name VARCHAR,
    avg_rating FLOAT
)
AS $$
BEGIN
    RETURN QUERY 
    SELECT a.author_id, a.name, AVG(r.star)::float AS avg_rating
    FROM author a
    JOIN book b ON a.author_id = b.author_id
    JOIN read r ON b.book_id = r.book_id
    GROUP BY a.author_id, a.name
    ORDER BY avg_rating DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;
--3.Get the average rating of books by genre

CREATE OR REPLACE FUNCTION get_avg_rating_by_genre() 
RETURNS TABLE (
    genre VARCHAR,
    avg_rating DOUBLE PRECISION
) 
AS $$
BEGIN
    RETURN QUERY 
    SELECT b.genre, AVG(r.star)::DOUBLE PRECISION AS avg_rating
    FROM books b
    JOIN read r ON b.book_id = r.book_id
    GROUP BY b.genre;
END;
$$ LANGUAGE plpgsql;
--4.Get overdue books and their users

CREATE OR REPLACE FUNCTION get_overdue_books_and_users(p_current_date TIMESTAMP) RETURNS TABLE (
    book_id INT,
    title VARCHAR,
    user_id INT,
    user_name VARCHAR,
    due TIMESTAMP
)
AS $$
BEGIN
    RETURN QUERY 
    SELECT b.book_id, b.title, u.user_id, u.user_name, re.due
    FROM re
    JOIN books b ON re.book_id = b.book_id
    JOIN users u ON re.user_id = u.user_id
    WHERE re.due < p_current_date AND re.return_date IS NULL;
END;
$$ LANGUAGE plpgsql;
--5.Get the history of a specific book (reservations and reads)

--6.Get users with the most overdue books

CREATE OR REPLACE FUNCTION get_users_with_most_overdue_books(p_current_date TIMESTAMP, p_limit INT) RETURNS TABLE (
    user_id INT,
    user_name VARCHAR,
    overdue_count INT
)
AS $$
BEGIN
    RETURN QUERY 
    SELECT u.user_id, u.user_name, COUNT(*) AS overdue_count
    FROM re
    JOIN users u ON re.user_id = u.user_id
    WHERE re.due < p_current_date AND re.return_date IS NULL
    GROUP BY u.user_id, u.user_name
    ORDER BY overdue_count DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;
--7.Get book recommendation based on user’s reading history

CREATE OR REPLACE FUNCTION get_book_recommendation(p_user_id INT) 
RETURNS TABLE (
    book_id INT,
    title VARCHAR,
    genre VARCHAR,
    avg_star INT
) 
AS $$
BEGIN
    RETURN QUERY 
    SELECT * FROM (
        SELECT DISTINCT b.book_id, b.title, b.genre, b.avg_star::INT AS avg_star
        FROM book b
        WHERE b.genre IN (
            SELECT DISTINCT b2.genre
            FROM read r
            JOIN book b2 ON r.book_id = b2.book_id
            WHERE r.user_id = p_user_id
        ) 
        AND b.book_id NOT IN (
            SELECT r.book_id
            FROM read r
            WHERE r.user_id = p_user_id
        )
    ) AS subquery
    ORDER BY avg_star DESC;
END;
$$ LANGUAGE plpgsql;

--8.Get the staff member with the most managed books

CREATE OR REPLACE FUNCTION get_staff_with_most_managed_books() RETURNS TABLE (
    staff_id INT,
    name VARCHAR,
    managed_books_count INT
)
AS $$
BEGIN
    RETURN QUERY 
    SELECT s.staff_id, s.name, COUNT(*)::INT AS managed_books_count
    FROM staff s
    JOIN book b ON s.staff_id = b.staff_id
    GROUP BY s.staff_id, s.name
    ORDER BY managed_books_count DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;
--9.Get the nationality with the most authors

CREATE OR REPLACE FUNCTION get_nationality_with_most_authors() RETURNS TABLE (
    nationality VARCHAR,
    author_count INT
)
AS $$
BEGIN
    RETURN QUERY 
    SELECT a.nationality, COUNT(*)::INT AS author_count
    FROM author a
    GROUP BY a.nationality
    ORDER BY author_count DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;
--10.Get the user who has reserved the most unique books

CREATE OR REPLACE FUNCTION get_user_with_most_unique_reservations() RETURNS TABLE (
    user_id INT,
    user_name VARCHAR,
    unique_reservations_count INT
)
AS $$
BEGIN
    RETURN QUERY 
    SELECT u.user_id, u.user_name, COUNT(DISTINCT re.book_id)::INT AS unique_reservations_count
    FROM users u
    JOIN re ON u.user_id = re.user_id
    GROUP BY u.user_id, u.user_name
    ORDER BY unique_reservations_count DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;
--11.Get the top genres by average rating

CREATE OR REPLACE FUNCTION get_top_genres_by_avg_rating(p_limit INT) RETURNS TABLE (
    genre VARCHAR,
    avg_rating FLOAT
)
AS $$
BEGIN
    RETURN QUERY 
    SELECT b.genre, AVG(r.star)::float AS avg_rating
    FROM book b
    JOIN read r ON b.book_id = r.book_id
    GROUP BY b.genre
    ORDER BY avg_rating DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;
--12.Get the number of books each staff member is responsible for
CREATE OR REPLACE FUNCTION get_books_per_staff() RETURNS TABLE (
    staff_id INT,
    name VARCHAR,
    books_count INT
)
AS $$
BEGIN
    RETURN QUERY 
    SELECT s.staff_id, s.name, COUNT(b.book_id)::INT AS books_count
    FROM staff s
    LEFT JOIN book b ON s.staff_id = b.staff_id
    GROUP BY s.staff_id, s.name
    ORDER BY books_count DESC;
END;
$$ LANGUAGE plpgsql;
--13.Get the most popular book genres based on reservations

CREATE OR REPLACE FUNCTION get_most_popular_genres_by_reservations(p_limit INT) RETURNS TABLE (
    genre VARCHAR,
    reservation_count INT
)
AS $$
BEGIN
    RETURN QUERY 
    SELECT b.genre, COUNT(re.book_id)::INT AS reservation_count
    FROM book b
    JOIN re ON b.book_id = re.book_id
    GROUP BY b.genre
    ORDER BY reservation_count DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;
--14.Get the most borrowed books by genre
CREATE OR REPLACE FUNCTION get_most_borrowed_books_by_genre(p_genre VARCHAR, p_limit INT) RETURNS TABLE (
    book_id INT,
    title VARCHAR,
    borrow_count INT
)
AS $$
BEGIN
    RETURN QUERY 
    SELECT b.book_id, b.title, COUNT(re.book_id)::INT AS borrow_count
    FROM book b
    JOIN re ON b.book_id = re.book_id
    WHERE b.genre = p_genre
    GROUP BY b.book_id, b.title
    ORDER BY borrow_count DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;



