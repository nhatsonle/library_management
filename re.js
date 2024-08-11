const express = require('express');
const { Client } = require('pg');
const path = require('path'); // Import the 'path' module
const app = express();
const port = 4000;


const client = new Client({
  user: 'postgres',
  host: 'localhost',
  database: 'new_lib',
  password: '0000',
  port: 5432, // default port for PostgreSQL
});

// Connect to the PostgreSQL database
client.connect()
  .then(() => {
    console.log('Connected to the database');
  })
  .catch(err => {
    console.error('Error connecting to the database:', err);
  });
app.use(express.static(path.join(__dirname, 'public')));




//home page
app.get('/', (req, res) => {
    res.sendFile('/Users/jmac/Desktop/be_web/pxcode-html/web/UntitledPage.html');
  });
//book warehouse
app.get('/viewbook', (req, res) => {
    res.sendFile('/Users/jmac/Desktop/be_web/yourbookview/web/Rbook.html');
  });
//search feature
  app.get('/viewbook/search', (req, res) => {
    res.sendFile('/Users/jmac/Desktop/be_web/search.html');
    console.log(`done`);
  });
//show profile
  app.get('/profile', (req, res) => {
    res.sendFile('/Users/jmac/Desktop/be_web/pro5/web/Profile.html');
  });

//show report
app.get('/report', (req, res) => {
    res.sendFile('/Users/jmac/Desktop/be_web/report/web/Newe.html');
  });

// đếm số sách mà staff này quản lý
app.get('/report/count', (req, res) => {
  client.query('select count(*) from books join staff on books.staff_id=staff.staff_id where staff.staff_id=1', (err, dbRes) => {
    if (!err) {
      res.json(dbRes.rows);
  
    } else {
      res.status(500).send(err.message);
    }
  });
});
// id ng quán hạn trả
app.get('/report/over', (req, res) => {
  client.query('select user_id from users where user_id in (SELECT DISTINCT user_id FROM re WHERE extract(epoch FROM return_date) > extract(epoch FROM due))', (err, dbRes) => {
    if (!err) {
      res.json(dbRes.rows);
      console.log('done'); // In ra câu lệnh SQL để kiểm tra
    } else {
      res.status(500).send(err.message);
    }
  });
});
// sách bị đánh giá thấp
app.get('/report/low', (req, res) => {
  client.query('SELECT title FROM books WHERE avg_star < 2', (err, dbRes) => {
    if (!err) {
      res.json(dbRes.rows);
  
    } else {
      res.status(500).send(err.message);
    }
  });
});
//sách đk yêu thích
app.get('/report/high', (req, res) => {
  client.query('SELECT name FROM books join authors on books.author_id=authors.author_id WHERE books.avg_star = (SELECT MAX(avg_star) FROM books);  ', (err, dbRes) => {
    if (!err) {
      res.json(dbRes.rows);
  
    } else {
      res.status(500).send(err.message);
    }
  });
});





app.get('/Calender', (req, res) => {
    res.sendFile('/Users/jmac/Desktop/be_web/calender/web/Calender.html');
  });
  




// hiển thị tổng số lượng sách
app.get('/viewbook/total', (req, res) => {
    client.query('SELECT sum(quantity) FROM books', (err, dbRes) => {
      if (!err) {
        res.json(dbRes.rows);
    
      } else {
        res.status(500).send(err.message);
      }
    });
  });

// chọn top6 truyện được yêu thích nhất để hiển thị trên book ware house


  app.get('/viewbook/title', (req, res) => {
    client.query('SELECT * FROM books ORDER BY avg_star DESC LIMIT 6', (err, dbRes) => {
      if (err) {
        console.error('Error executing query:', err.stack);
        res.status(500).send(err.message);
      } else {
        // dbRes.rows contains the array of rows, each row being an object
        res.json(dbRes.rows);
      }
    });
  });
//hiển thị số sách mượn off
  app.get('/viewbook/off', (req, res) => {
    client.query('SELECT COUNT(*) FROM re WHERE Return_date IS NULL ', (err, dbRes) => {
      if (!err) {
        res.json(dbRes.rows);
    
      } else {
        res.status(500).send(err.message);
      }
    });
  });
//hiển thị số sách đọc online
  app.get('/viewbook/on', (req, res) => {
    client.query('SELECT COUNT(*) FROM read ', (err, dbRes) => {
      if (!err) {
        res.json(dbRes.rows);
    
      } else {
        res.status(500).send(err.message);
      }
    });
  });
// hiển thị trung bình số sao đánh giá
  app.get('/viewbook/avgs', (req, res) => {
    client.query('select sum(avg_star)/count(*) as t from books', (err, dbRes) => {
      if (!err) {
        res.json(dbRes.rows);
    
      } else {
        res.status(500).send(err.message);
      }
    });
  });
  




app.get('/authors', (req, res) => {
  client.query('SELECT * FROM authors', (err, dbRes) => {
    if (!err) {
      res.json(dbRes.rows);
    } else {
      res.status(500).send(err.message);
    }
  });
});

//chức năng tìm kiếm

app.get('/search', (req, res) => {
  if (req.query.search) {
      let filterValues = req.query.search;
     
      // đổi tìm kiếm book id và name trả về 3 thuộc tính chính

      let query = "SELECT book_id, title, quantity, author_id FROM books WHERE CONCAT(book_id, title, quantity, staff_id) LIKE $1";


      console.log('Query:', query); // In ra câu lệnh SQL để kiểm tra

      client.query(query, ['%' + filterValues + '%'], (err, result) => {
        if (err) {
            console.error(err); // In ra lỗi nếu có
            res.status(500).json({ message: "Internal Server Error" }); // Trả về mã lỗi 500 nếu có lỗi xảy ra
        } else {
            if (result.rows.length > 0) {
                res.json(result.rows); // Trả về kết quả dưới dạng JSON nếu có bản ghi được tìm thấy

            } else {
                res.json({ message: "No Record Found" }); // Trả về thông báo khi không tìm thấy bản ghi
            }
        }
    });
  }})      


app.get('/search?search=', (req, res) => {
  if (req.query.search) {
      let filterValues = req.query.search;
      
      let query = "SELECT book_id, title, quantity, staff_id FROM books WHERE CONCAT(book_id, title, quantity, staff_id) LIKE $1";

      // đổi tìm kiếm book id và name trả về 4 thuộc tính chính
      

      console.log('Query:', query); // In ra câu lệnh SQL để kiểm tra

      client.query(query, ['%' + filterValues + '%'], (err, result) => {
        if (err) {
            console.error(err); // In ra lỗi nếu có
            res.status(500).json({ message: "Internal Server Error" }); // Trả về mã lỗi 500 nếu có lỗi xảy ra
        } else {
            if (result.rows.length > 0) {
                res.json(result.rows); // Trả về kết quả dưới dạng JSON nếu có bản ghi được tìm thấy

            } else {
                res.json({ message: "No Record Found" }); // Trả về thông báo khi không tìm thấy bản ghi
            }
        }
    });
  }})      



app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}/`);
});
module.exports = app;