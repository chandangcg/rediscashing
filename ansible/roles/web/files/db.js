const mysql = require("mysql2");

const db = mysql.createConnection({
  host: "192.168.1.147", // 👉 your DB IP
  user: "appuser",
  password: "admin",
  database: "userdb"
});

db.connect(err => {
  if (err) throw err;
  console.log("MySQL Connected");
});

module.exports = db;