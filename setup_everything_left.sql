alter table book
add constraint book_pkey primary key (book_id);

alter table author
add constraint author_pkey primary key (author_id);

alter table staff
add constraint staff_pkey primary key (staff_id);

alter table users
add constraint users_pkey primary key (user_id);

alter table book
add constraint book_author_id_fkey foreign key (author_id)
references author(author_id);

ALTER TABLE book
ADD CONSTRAINT book_staff_id_fkey FOREIGN KEY (staff_id)
REFERENCES staff(staff_id);

ALTER table re
ADD CONSTRAINT re_book_id_fkey FOREIGN KEY (book_id)
REFERENCES book(book_id);

ALTER table re 
ADD CONSTRAINT re_user_id_fkey FOREIGN key (user_id)
REFERENCES users(user_id);

ALTER TABLE read
ADD CONSTRAINT read_user_id_fkey FOREIGN KEY (user_id)
REFERENCES users(user_id);

ALTER TABLE read
ADD CONSTRAINT read_book_id_fkey FOREIGN KEY (book_id)
REFERENCES book(book_id);
