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

  // Modified query to check user_account table only
  const sql = `
    SELECT * FROM user_account 
    WHERE user_email = ?
  `;

  db.query(sql, [user_email], async (err, results) => {
    if (err) {
      console.error('Database error:', err);
      return res.status(500).json({ error: 'Database error' });
    }

    if (results.length === 0) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const user = results[0];
    try {
      const isMatch = await bcrypt.compare(user_password, user.user_password);
      if (!isMatch) {
        return res.status(401).json({ error: 'Invalid credentials' });
      }

      res.status(200).json({
        userId: user.user_id,
        is_merchant: false // Regular users are not merchants
      });
    } catch (err) {
      console.error('Error comparing passwords:', err);
      res.status(500).json({ error: 'Internal server error' });
    }
  });
};

// Add separate merchant login endpoint
export const loginMerchant = async (req, res) => {
  const { merchant_email, merchant_password } = req.body;

  const sql = 'SELECT * FROM merchant_account WHERE merchant_email = ?';

  try {
    db.query(sql, [merchant_email], async (err, results) => {
      if (err) {
        console.error('Database error:', err);
        return res.status(500).json({ error: 'Database error' });
      }

      if (results.length === 0) {
        return res.status(401).json({ error: 'Invalid credentials' });
      }

      const merchant = results[0];
      const isMatch = await bcrypt.compare(merchant_password, merchant.merchant_password);

      if (!isMatch) {
        return res.status(401).json({ error: 'Invalid credentials' });
      }

      res.status(200).json({
        merchantId: merchant.merchant_id,
        businessName: merchant.business_name,
        businessType: merchant.business_type,
        phoneNumber: merchant.phone_number,
        balance: merchant.balance
      });
    });
  } catch (err) {
    console.error('Login error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
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

  const sql = `
    SELECT u.*, 
           IF(a.agent_id IS NOT NULL, TRUE, FALSE) as is_agent
    FROM user_account u
    LEFT JOIN agent_account a ON u.user_id = a.user_id
    WHERE u.user_id = ?
  `;

  db.query(sql, [userId], (err, results) => {
    if (err) {
      console.error('Error fetching user:', err);
      return res.status(500).json({ error: 'Error fetching user' });
    }
    if (results.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    res.status(200).json(results[0]);
  });
};

// Get merchant by ID
export const getMerchantById = (req, res) => {
  const { merchantId } = req.params;
  
  const sql = 'SELECT * FROM merchant_account WHERE merchant_id = ?';
  
  db.query(sql, [merchantId], (err, results) => {
    if (err) {
      console.error('Database error:', err);
      return res.status(500).json({ error: 'Database error' });
    }
    
    if (results.length === 0) {
      return res.status(404).json({ error: 'Merchant not found' });
    }
    
    const merchant = results[0];
    // Return all necessary merchant data
    res.status(200).json({
      merchant_id: merchant.merchant_id,
      business_name: merchant.business_name,
      business_type: merchant.business_type,
      phone_number: merchant.phone_number,
      balance: merchant.balance,
      merchant_email: merchant.merchant_email
    });
  });
};

// Make a transaction
export const makeTransaction = (req, res) => {
  const { sender_id, receiver_id, amount, is_merchant_transaction } = req.body;

  db.beginTransaction(async (err) => {
    if (err) {
      return res.status(500).json({ error: 'Transaction failed to start' });
    }

    try {
      // Check if receiver is an agent
      const [agentCheck] = await db.promise().query(
        'SELECT * FROM agent_account WHERE user_id = ?',
        [receiver_id]
      );
      
      const isAgentTransaction = agentCheck.length > 0;
      
      // Calculate fees (0 for merchant and agent transactions)
      const fees = (is_merchant_transaction || isAgentTransaction) ? 0 : amount * 0.01;
      const receiverAmount = amount - fees;

      // Check sender balance
      const [sender] = await db.promise().query(
        'SELECT balance FROM user_account WHERE user_id = ?',
        [sender_id]
      );

      if (sender[0].balance < amount) {
        throw new Error('Insufficient balance');
      }

      // Update sender balance
      await db.promise().query(
        'UPDATE user_account SET balance = balance - ? WHERE user_id = ?',
        [amount, sender_id]
      );

      if (is_merchant_transaction) {
        // Update merchant balance
        await db.promise().query(
          'UPDATE merchant_account SET balance = balance + ? WHERE merchant_id = ?',
          [amount, receiver_id]
        );

        // Insert into merchant_transactions table with status
        await db.promise().query(
          `INSERT INTO merchant_transactions 
           (merchant_id, user_id, amount, fees, transaction_date, status)
           VALUES (?, ?, ?, ?, NOW(), 'completed')`,
          [receiver_id, sender_id, amount, 0]  // Set fees to 0 for merchant transactions
        );
      } else {
        // Update receiver balance for regular user-to-user transaction
        await db.promise().query(
          'UPDATE user_account SET balance = balance + ? WHERE user_id = ?',
          [receiverAmount, receiver_id]
        );

        // Insert into regular transactions table
        await db.promise().query(
          `INSERT INTO transactions 
           (sender_id, receiver_id, amount, fees, receiver_amount, is_merchant_transaction)
           VALUES (?, ?, ?, ?, ?, ?)`,
          [sender_id, receiver_id, amount, fees, receiverAmount, is_merchant_transaction]
        );
      }

      db.commit((err) => {
        if (err) {
          return db.rollback(() => {
            res.status(500).json({ error: 'Failed to commit transaction' });
          });
        }
        res.status(200).json({ 
          message: 'Transaction successful',
          amount: amount,
          fees: fees,
          is_merchant: is_merchant_transaction
        });
      });
    } catch (error) {
      return db.rollback(() => {
        res.status(400).json({ error: error.message });
      });
    }
  });
};

// Search user by phone number
export const searchUserByPhone = (req, res) => {
  const { phone_number } = req.query;
  const { sender_id } = req.query; // Add this parameter

  if (!phone_number) {
    return res.status(400).json({ error: 'Phone number is required' });
  }

  const sql = 'SELECT user_id, fname, lname, phone_number FROM user_account WHERE phone_number = ? AND user_id != ?';
  
  db.query(sql, [phone_number, sender_id], (err, results) => {
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

// Get user transactions
export const getUserTransactions = (req, res) => {
  const { userId } = req.params;
  
  const sql = `
    SELECT 
      t.*,
      CASE
        WHEN t.sender_id = ? THEN 'sent'
        ELSE 'received'
      END as direction,
      u_s.fname as sender_fname,
      u_s.lname as sender_lname,
      u_r.fname as receiver_fname,
      u_r.lname as receiver_lname
    FROM (
      SELECT 
        id,
        sender_id,
        receiver_id,
        amount,
        fees,
        receiver_amount,
        transaction_date,
        is_merchant_transaction
      FROM transactions
      UNION ALL
      SELECT 
        id,
        user_id as sender_id,
        merchant_id as receiver_id,
        amount,
        fees,
        amount as receiver_amount,
        transaction_date,
        1 as is_merchant_transaction
      FROM merchant_transactions
    ) t
    LEFT JOIN user_account u_s ON t.sender_id = u_s.user_id
    LEFT JOIN user_account u_r ON t.receiver_id = u_r.user_id
    LEFT JOIN merchant_account m ON t.is_merchant_transaction = 1 AND t.receiver_id = m.merchant_id
    WHERE t.sender_id = ? OR t.receiver_id = ?
    ORDER BY t.transaction_date DESC`;

  db.query(sql, [userId, userId, userId], (err, results) => {
    if (err) {
      console.error('Error fetching transactions:', err);
      return res.status(500).json({ error: 'Error fetching transactions' });
    }
    
    const transformedResults = results.map(transaction => ({
      ...transaction,
      fees: transaction.is_merchant_transaction ? 0 : transaction.fees,
      other_party_name: transaction.is_merchant_transaction ? 
        transaction.business_name : 
        (transaction.direction === 'sent' ? 
          `${transaction.receiver_fname} ${transaction.receiver_lname}` : 
          `${transaction.sender_fname} ${transaction.sender_lname}`)
    }));

    res.status(200).json(transformedResults);
  });
};

// Add this new function to usersController.js
export const getMerchantTransactions = (req, res) => {
  const { userId } = req.params;
  
  const sql = `
    SELECT 
      mt.*,
      'sent' as direction,
      u.fname as sender_fname,
      u.lname as sender_lname,
      u.phone_number as sender_phone,
      m.business_name,
      m.phone_number as merchant_phone,
      m.business_type,
      m.merchant_id
    FROM merchant_transactions mt
    INNER JOIN user_account u ON mt.user_id = u.user_id
    INNER JOIN merchant_account m ON mt.merchant_id = m.merchant_id
    WHERE mt.user_id = ?
    ORDER BY mt.transaction_date DESC
  `;

  db.query(sql, [userId], (err, results) => {
    if (err) {
      console.error('Error fetching merchant transactions:', err);
      return res.status(500).json({ error: 'Error fetching merchant transactions' });
    }
    
    const transformedResults = results.map(transaction => ({
      id: transaction.id,
      amount: transaction.amount,
      fees: transaction.fees,
      transaction_date: transaction.transaction_date,
      direction: 'sent', // Always sent from user to merchant
      sender: {
        id: transaction.user_id,
        name: `${transaction.sender_fname} ${transaction.sender_lname}`,
        phone: transaction.sender_phone
      },
      merchant: {
        id: transaction.merchant_id,
        business_name: transaction.business_name,
        business_type: transaction.business_type,
        phone: transaction.merchant_phone
      },
      transaction_type: 'merchant_payment'
    }));

    res.status(200).json(transformedResults);
  });
};

// Get user profile
export const getUserProfile = (req, res) => {
  const { userId } = req.params;
  const sql = 'SELECT fname, lname, phone_number FROM user_account WHERE user_id = ?';
  
  db.query(sql, [userId], (err, results) => {
    if (err || results.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    res.status(200).json(results[0]);
  });
};

// Update user profile
export const updateUserProfile = (req, res) => {
  const { userId } = req.params;
  const { fname, lname, phone_number } = req.body;

  const sql = `
    UPDATE user_account 
    SET fname = ?, lname = ?, phone_number = ?
    WHERE user_id = ?
  `;

  db.query(sql, [fname, lname, phone_number, userId], (err, result) => {
    if (err) {
      console.error('Error updating user:', err);
      return res.status(500).json({ error: 'Error updating profile' });
    }
    res.status(200).json({ message: 'Profile updated successfully' });
  });
};

// Update user password
export const updateUserPassword = (req, res) => {
  const { userId } = req.params;
  const { current_password, new_password } = req.body;

  // First verify current password
  const checkPasswordSql = 'SELECT user_password FROM user_account WHERE user_id = ?';
  db.query(checkPasswordSql, [userId], (err, results) => {
    if (err || results.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    bcrypt.compare(current_password, results[0].user_password, (err, isMatch) => {
      if (err || !isMatch) {
        return res.status(401).json({ error: 'Current password is incorrect' });
      }

      // Hash new password
      bcrypt.hash(new_password, 10, (err, hash) => {
        if (err) {
          return res.status(500).json({ error: 'Error hashing new password' });
        }

        // Update password
        const updatePasswordSql = 'UPDATE user_account SET user_password = ? WHERE user_id = ?';
        db.query(updatePasswordSql, [hash, userId], (err, result) => {
          if (err) {
            return res.status(500).json({ error: 'Error updating password' });
          }
          res.status(200).json({ message: 'Password updated successfully' });
        });
      });
    });
  });
};

export const validateMerchantQR = (req, res) => {
  const { merchantId } = req.params;
  
  const sql = `
    SELECT 
      merchant_id,
      business_name,
      business_type,
      phone_number,
      status
    FROM merchant_account 
    WHERE merchant_id = ? AND status = 'Active'`;

  db.query(sql, [merchantId], (err, results) => {
    if (err) {
      console.error('Error validating merchant:', err);
      return res.status(500).json({ error: 'Database error' });
    }

    if (results.length === 0) {
      return res.status(404).json({ error: 'Merchant not found or inactive' });
    }

    res.status(200).json({
      merchant_id: results[0].merchant_id,
      business_name: results[0].business_name,
      business_type: results[0].business_type,
      phone_number: results[0].phone_number
    });
  });
};

// Add this new function
export const validateUserQR = (req, res) => {
  const { userId } = req.params;
  
  // Add type check
  const qrData = req.body;
  if (qrData.type !== 'user') {
    return res.status(400).json({ error: 'Invalid QR code type' });
  }
  
  const sql = `
    SELECT 
      u.user_id,
      u.fname,
      u.lname,
      u.phone_number,
      IF(a.agent_id IS NOT NULL, TRUE, FALSE) as is_agent
    FROM user_account u
    LEFT JOIN agent_account a ON u.user_id = a.user_id
    WHERE u.user_id = ?`;

  db.query(sql, [userId], (err, results) => {
    if (err) {
      console.error('Error validating user:', err);
      return res.status(500).json({ error: 'Database error' });
    }

    if (results.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Verify QR data matches database
    const user = results[0];
    if (user.fname !== qrData.fname || 
        user.lname !== qrData.lname || 
        user.phone_number !== qrData.phoneNumber) {
      return res.status(400).json({ error: 'Invalid QR code data' });
    }

    res.status(200).json({
      user_id: user.user_id,
      fname: user.fname,
      lname: user.lname,
      phone_number: user.phone_number,
      is_agent: user.is_agent
    });
  });
};