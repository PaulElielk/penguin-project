import db from '../config/db.js';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';

// Register a new user
export const createUser = (req, res) => {
  const { user_email, user_password, fname, lname, phone_number, balance } = req.body;

  // Hash the password
  bcrypt.hash(user_password, 10, (err, hash) => {
    if (err) {
      return res.status(500).json({ error: 'Error hashing password' });
    }

    const sql = `
      INSERT INTO user_account (user_email, user_password, fname, lname, phone_number, balance)
      VALUES (?, ?, ?, ?, ?, ?)
    `;
    db.query(sql, [user_email, hash, fname, lname, phone_number, balance || 0.00], (err, result) => {
      if (err) {
        return res.status(500).json({ error: 'Error creating user' });
      }
      res.status(201).json({ message: 'User created successfully' });
    });
  });
};

// Log in a user
export const loginUser = (req, res) => {
  const { user_email, user_password } = req.body;

  const sql = 'SELECT * FROM user_account WHERE user_email = ?';
  db.query(sql, [user_email], (err, results) => {
    if (err || results.length === 0) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const user = results[0];
    bcrypt.compare(user_password, user.user_password, (err, isMatch) => {
      if (err || !isMatch) {
        return res.status(401).json({ error: 'Invalid credentials' });
      }

      // Generate a JWT token
      const token = jwt.sign(
        { id: user.user_id, fname: user.fname, lname: user.lname },
        'secret_key',
        { expiresIn: '1h' }
      );
      res.status(200).json({ message: 'Login successful', token });
    });
  });
};

// Get all users
export const getUsers = (req, res) => {
  const sql = 'SELECT user_id, user_email, fname, lname, phone_number, balance FROM user_account';
  db.query(sql, (err, results) => {
    if (err) {
      return res.status(500).json({ error: 'Error fetching users' });
    }
    res.status(200).json(results);
  });
};