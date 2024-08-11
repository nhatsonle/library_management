-- tính tổng số sách trong thư viện

CREATE or REPLACE FUNCTION total_book(out total integer) as
$$
BEGIN
    select sum(quantity) into total from book;
END;
$$
LANGUAGE plpgsql;


-- select total_book();

-- kiểm tra xem sách có sẵn sàng cho mượn hay không

CREATE or REPLACE FUNCTION numAvailable(in id integer, out num integer)
as $$
BEGIN
    num := (select quantity from book where book_id = id) - (select count(*) from re where book_id = id and return_date is null);
END;
$$
LANGUAGE plpgsql;

-- select numavailable(677);


-- tính số sách một người dùng đang mượn

CREATE OR REPLACE FUNCTION reserving(in id integer, out num integer)
as $$
BEGIN
    select count(*) into num
    from re
    where user_id = id
    and return_date is null;
END;
$$
LANGUAGE plpgsql;

-- select reserving(240);


-- trả về list sách người dùng đang mượn


CREATE or REPLACE FUNCTION reserving_list(in id integer)
RETURNS TABLE (book_id integer, title VARCHAR, soluong int)
as $$
BEGIN
    RETURN query
    select book.book_id, book.title, count(re.book_id)::integer as soluong
    from book
    join re on book.book_id = re.book_id
    where re.user_id = id
    group by book.book_id;
END;
$$
LANGUAGE plpgsql;

-- select reserving_list(240);


-- tìm sách theo tên tác giả

CREATE or REPLACE FUNCTION find_books_by_author(author_name VARCHAR) RETURNS TABLE (id INT, title VARCHAR, genre varchar) AS $$
BEGIN
    RETURN QUERY
    SELECT book.book_id, book.title, book.genre
    from book
    join author on book.author_id = author.author_id
    where author.name = author_name;
END;
$$ LANGUAGE plpgsql;


-- select find_books_by_author('Roz Tuiller');


-- tìm sách theo thể loại


CREATE or REPLACE FUNCTION find_books_by_genre(book_genre VARCHAR) RETURNS TABLE (id INT, title VARCHAR, author VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT book.book_id, book.title, author.name
    from book
    join author on book.author_id = author.author_id
    where book.genre = book_genre
    order by book.book_id;
END;
$$ LANGUAGE plpgsql;


-- select find_books_by_genre('sci-fi');
