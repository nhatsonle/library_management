CREATE TABLE "books" (
  "book_id" integer PRIMARY KEY,
  "title" varchar,
  "genre" varchar,
  "quantity" integer,
  "status" integer,
  "publish_year" timestamp,
  "publishing_house" varchar,
  "avg_star" integer,
  "author_id" integer,
  "staff_id" integer
);

CREATE TABLE "authors" (
  "author_id" integer PRIMARY KEY,
  "name" varchar,
  "nationality" varchar,
  "birth_year" timestamp
);

CREATE TABLE "users" (
  "user_id" integer PRIMARY KEY,
  "name" varchar,
  "birth_year" timestamp,
  "email" varchar,
  "address" varchar,
  "password" varchar
);

CREATE TABLE "staff" (
  "staff_id" integer PRIMARY KEY,
  "name" varchar,
  "phone_number" integer,
  "email" varchar,
  "login" varchar,
  "password" varchar,
  "report_id" integer
);

CREATE TABLE "report" (
  "report_id" integer PRIMARY KEY,
  "user_id" integer,
  "book_id" integer,
  "status" varchar,
  "reserve_book" varchar,
  "available_book" varchar
);

CREATE TABLE "re" (
  "reserve_date" timestamp,
  "return_date" timestamp,
  "due" timestamp,
  "book_id" integer,
  "user_id" integer,
  PRIMARY KEY ("book_id", "user_id")
);

CREATE TABLE "read" (
  "star" integer,
  "comment" varchar,
  "book_id" integer,
  "user_id" integer,
  PRIMARY KEY ("book_id", "user_id")
);

ALTER TABLE "books" ADD FOREIGN KEY ("author_id") REFERENCES "authors" ("author_id");

ALTER TABLE "books" ADD FOREIGN KEY ("staff_id") REFERENCES "staff" ("staff_id");

ALTER TABLE "staff" ADD FOREIGN KEY ("report_id") REFERENCES "report" ("report_id");

ALTER TABLE "re" ADD FOREIGN KEY ("book_id") REFERENCES "books" ("book_id");

ALTER TABLE "re" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("user_id");

ALTER TABLE "read" ADD FOREIGN KEY ("book_id") REFERENCES "books" ("book_id");

ALTER TABLE "read" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("user_id");