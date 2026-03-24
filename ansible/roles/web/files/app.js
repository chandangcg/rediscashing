const express = require("express");
const bodyParser = require("body-parser");
const os = require("os");
const db = require("./db");

const app = express();
app.use(bodyParser.urlencoded({ extended: true }));

// Signup page
app.get("/", (req, res) => {
  res.send(`
    <h2>Signup</h2>
    <form action="/signup" method="POST">
      <input name="username" placeholder="username"/><br>
      <input name="password" type="password" placeholder="password"/><br>
      <button>Signup</button>
    </form>

    <h2>Login</h2>
    <form action="/login" method="POST">
      <input name="username" placeholder="username"/><br>
      <input name="password" type="password"/><br>
      <button>Login</button>
    </form>
  `);
});

// Signup
app.post("/signup", (req, res) => {
  const { username, password } = req.body;

  db.query(
    "INSERT INTO users (username, password) VALUES (?, ?)",
    [username, password],
    () => {
      res.send("Signup successful. Go back and login.");
    }
  );
});

// Login
app.post("/login", (req, res) => {
  const { username, password } = req.body;

  db.query(
    "SELECT * FROM users WHERE username=? AND password=?",
    [username, password],
    (err, result) => {
      if (result.length > 0) {
        res.send(
          `<h1>Welcome ${username}</h1>
           <h3>Served from: ${os.hostname()}</h3>`
        );
      } else {
        res.send("Invalid credentials");
      }
    }
  );
});

app.listen(3000, () => console.log("App running on 3000"));