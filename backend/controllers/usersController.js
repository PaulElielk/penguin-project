import db from '../config/db.js';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';

// Register a new user
export const createUser = (req, res) => {
  const { user_email, user_password, fname, lname, phone_number, balance } = req.body;

  // Hash the password
  bcrypt.hash(user_password, 10, (err, hash) => {
    if (err) {
      console.error('Error hashing password:', err);
      return res.status(500).json({ error: 'Error hashing password' });
    }

    const sql = `
      INSERT INTO user_account (user_email, user_password, fname, lname, phone_number, balance)
      VALUES (?, ?, ?, ?, ?, ?)
    `;
    db.query(sql, [user_email, hash, fname, lname, phone_number, balance || 0.00], (err, result) => {
      if (err) {
        console.error('Error inserting user:', err);
        return res.status(500).json({ error: 'Error creating user' });
      }
      res.status(201).json({ message: 'User created successfully' });
    });
  });
};

// Log in a user
export const loginUser = (req, res) => {
  const { user_email, user_password } = req.body;

  if (!user_email || !user_password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }

  const sql = 'SELECT * FROM user_account WHERE user_email = ?';
  db.query(sql, [user_email], (err, results) => {
    if (err) {
      console.error('Database error:', err);
      return res.status(500).json({ error: 'Database error' });
    }

    if (results.length === 0) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const user = results[0];
    console.log('User fetched from database:', user);

    // Compare the hashed password
    bcrypt.compare(user_password, user.user_password, (err, isMatch) => {
      if (err) {
        console.error('Error comparing passwords:', err);
        return res.status(500).json({ error: 'Error comparing passwords' });
      }

      if (!isMatch) {
        return res.status(401).json({ error: 'Invalid credentials' });
      }

      res.status(200).json({
        message: 'Login successful',
        userId: user.user_id,
      });
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

// Get user by ID
export const getUserById = (req, res) => {
  const { userId } = req.params;

  const sql = 'SELECT fname, lname, balance FROM user_account WHERE user_id = ?';
  db.query(sql, [userId], (err, results) => {
    if (err || results.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.status(200).json(results[0]);
  });
};

// Make a transaction
export const makeTransaction = (req, res) => {
  const { sender_id, receiver_id, amount } = req.body;

  if (!sender_id || !receiver_id || !amount || amount <= 0) {
    return res.status(400).json({ error: 'Invalid transaction details' });
  }

  // Start transaction
  db.beginTransaction((err) => {
    if (err) {
      return res.status(500).json({ error: 'Error starting transaction' });
    }

    // Check sender's balance
    const checkBalanceSql = 'SELECT balance FROM user_account WHERE user_id = ?';
    db.query(checkBalanceSql, [sender_id], (err, results) => {
      if (err || results.length === 0) {
        return db.rollback(() => {
          res.status(400).json({ error: 'Sender not found' });
        });
      }

      const senderBalance = results[0].balance;

      if (senderBalance < amount) {
        return db.rollback(() => {
          res.status(400).json({ error: 'Insufficient balance' });
        });
      }

      // Deduct amount from sender
      const updateSenderSql = 'UPDATE user_account SET balance = balance - ? WHERE user_id = ?';
      db.query(updateSenderSql, [amount, sender_id], (err) => {
        if (err) {
          return db.rollback(() => {
            res.status(500).json({ error: 'Error updating sender balance' });
          });
        }

        // Add amount to receiver
        const updateReceiverSql = 'UPDATE user_account SET balance = balance + ? WHERE user_id = ?';
        db.query(updateReceiverSql, [amount, receiver_id], (err) => {
          if (err) {
            return db.rollback(() => {
              res.status(500).json({ error: 'Error updating receiver balance' });
            });
          }

          // Commit transaction
          db.commit((err) => {
            if (err) {
              return db.rollback(() => {
                res.status(500).json({ error: 'Error committing transaction' });
              });
            }

            res.status(200).json({ message: 'Transaction successful' });
          });
        });
      });
    });
  });
};

// Search user by phone number
export const searchUserByPhone = (req, res) => {
  const { phone_number } = req.query;

  if (!phone_number) {
    return res.status(400).json({ error: 'Phone number is required' });
  }

  const sql = 'SELECT user_id, fname, lname, phone_number FROM user_account WHERE phone_number = ?';
  
  db.query(sql, [phone_number], (err, results) => {
    if (err) {
      console.error('Database error:', err);
      return res.status(500).json({ error: 'Error searching user' });
    }
    
    if (results.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    res.status(200).json(results[0]);
  });
};