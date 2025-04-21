import db from '../config/db.js';
import bcrypt from 'bcrypt';

// Get all merchants
export const getMerchants = (req, res) => {
  const sql = 'SELECT * FROM merchant_account';
  db.query(sql, (err, results) => {
    if (err) {
      console.error('Error fetching merchants:', err);
      return res.status(500).json({ error: 'Error fetching merchants' });
    }
    console.log('Merchants fetched:', results);
    res.status(200).json(results);
  });
};

// Get all agents
export const getAgents = (req, res) => {
  const sql = 'SELECT * FROM agent_account';
  db.query(sql, (err, results) => {
    if (err) {
      console.error('Error fetching agents:', err);
      return res.status(500).json({ error: 'Error fetching agents' });
    }
    console.log('Agents fetched:', results);
    res.status(200).json(results);
  });
};

// Create merchant
export const createMerchant = async (req, res) => {
  const {
    business_name,
    business_type,
    business_address,
    user_email,
    user_password,
    phone_number,
    balance
  } = req.body;

  try {
    // Hash the password
    const hashedPassword = await bcrypt.hash(user_password, 10);

    const sql = `
      INSERT INTO merchant_account 
      (merchant_email, merchant_password, business_name, business_type, business_address, phone_number, balance)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    `;

    db.query(
      sql,
      [
        user_email,
        hashedPassword,
        business_name,
        business_type,
        business_address,
        phone_number,
        balance || 0
      ],
      (err, result) => {
        if (err) {
          console.error('Error creating merchant:', err);
          return res.status(500).json({ 
            error: 'Error creating merchant',
            details: err.message 
          });
        }

        res.status(201).json({
          message: 'Merchant created successfully',
          merchantId: result.insertId
        });
      }
    );
  } catch (err) {
    console.error('Error in create merchant:', err);
    res.status(500).json({ 
      error: 'Internal server error',
      details: err.message 
    });
  }
};

// Login merchant
export const loginMerchant = async (req, res) => {
  const { merchant_email, merchant_password } = req.body;

  const sql = `SELECT * FROM merchant_account WHERE merchant_email = ?`;

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
        balance: merchant.balance,
        isMerchant: true
      });
    });
  } catch (err) {
    console.error('Error in merchant login:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Create agent
export const createAgent = async (req, res) => {
  const { business_name, business_address, phone_number, user_id } = req.body;
  
  try {
    // First check if user exists and is not already an agent
    const checkUserSql = `
      SELECT u.* 
      FROM user_account u 
      LEFT JOIN agent_account a ON u.user_id = a.user_id 
      WHERE u.user_id = ? AND a.user_id IS NULL
    `;
    
    db.query(checkUserSql, [user_id], (err, users) => {
      if (err) {
        console.error('Error checking user:', err);
        return res.status(500).json({ error: 'Error checking user existence' });
      }
      
      if (users.length === 0) {
        return res.status(400).json({ error: 'User not found or is already an agent' });
      }
      
      // If user exists and is not an agent, create agent account
      const sql = `
        INSERT INTO agent_account 
        (business_name, business_address, phone_number, user_id)
        VALUES (?, ?, ?, ?)
      `;
      
      db.query(
        sql,
        [business_name, business_address, phone_number, user_id],
        (err, result) => {
          if (err) {
            console.error('Error creating agent:', err);
            return res.status(500).json({ 
              error: 'Error creating agent',
              details: err.message 
            });
          }
          res.status(201).json({
            message: 'User successfully converted to agent',
            agentId: result.insertId
          });
        }
      );
    });
  } catch (err) {
    console.error('Error in create agent:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Update merchant
export const updateMerchant = (req, res) => {
  const { id } = req.params;
  const { business_name, business_type, business_address } = req.body;
  
  try {
    const sql = `
      UPDATE merchant_account 
      SET business_name = ?, 
          business_type = ?, 
          business_address = ?
      WHERE merchant_id = ?
    `;
    
    db.query(
      sql, 
      [business_name, business_type, business_address, id], 
      (err, result) => {
        if (err) {
          console.error('Error updating merchant:', err);
          return res.status(500).json({ error: 'Error updating merchant' });
        }
        
        if (result.affectedRows === 0) {
          return res.status(404).json({ error: 'Merchant not found' });
        }
        
        res.status(200).json({ message: 'Merchant updated successfully' });
      }
    );
  } catch (err) {
    console.error('Error in update merchant:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Delete merchant
export const deleteMerchant = (req, res) => {
  const { id } = req.params;
  const sql = 'DELETE FROM merchant_account WHERE merchant_id = ?';
  
  db.query(sql, [id], (err, result) => {
    if (err) {
      console.error('Error deleting merchant:', err);
      return res.status(500).json({ error: 'Error deleting merchant' });
    }
    res.status(200).json({ message: 'Merchant deleted successfully' });
  });
};

// Similar functions for agents...
export const updateAgent = (req, res) => {
  const { id } = req.params;
  const { business_name, business_address, phone_number, user_id } = req.body;
  
  try {
    const sql = `
      UPDATE agent_account 
      SET business_name = ?, 
          business_address = ?,
          phone_number = ?,
          user_id = ?
      WHERE agent_id = ?
    `;
    
    db.query(
      sql, 
      [business_name, business_address, phone_number, user_id, id], 
      (err, result) => {
        if (err) {
          console.error('Error updating agent:', err);
          return res.status(500).json({ 
            error: 'Error updating agent',
            details: err.message 
          });
        }
        
        if (result.affectedRows === 0) {
          return res.status(404).json({ error: 'Agent not found' });
        }
        
        res.status(200).json({ message: 'Agent updated successfully' });
      }
    );
  } catch (err) {
    console.error('Error in update agent:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
};

export const deleteAgent = (req, res) => {
  const { id } = req.params;
  const sql = 'DELETE FROM agent_account WHERE agent_id = ?';
  
  db.query(sql, [id], (err, result) => {
    if (err) {
      console.error('Error deleting agent:', err);
      return res.status(500).json({ error: 'Error deleting agent' });
    }
    res.status(200).json({ message: 'Agent deleted successfully' });
  });
};

// Get all users
export const getUsers = (req, res) => {
  const sql = 'SELECT * FROM user_account';
  db.query(sql, (err, results) => {
    if (err) {
      console.error('Error fetching users:', err);
      return res.status(500).json({ error: 'Error fetching users' });
    }
    console.log('Users fetched:', results);
    res.status(200).json(results);
  });
};

// Get available users
export const getAvailableUsers = (req, res) => {
  // Get users that are not already agents
  const sql = `
    SELECT u.* 
    FROM user_account u 
    LEFT JOIN agent_account a ON u.user_id = a.user_id 
    WHERE a.user_id IS NULL
  `;
  
  db.query(sql, (err, results) => {
    if (err) {
      console.error('Error fetching available users:', err);
      return res.status(500).json({ error: 'Error fetching available users' });
    }
    res.status(200).json(results);
  });
};

// Create user
export const createUser = async (req, res) => {
  const { user_email, user_password, fname, lname, phone_number, balance } = req.body;
  
  try {
    // Hash the password
    const hashedPassword = await bcrypt.hash(user_password, 10);
    
    const sql = `
      INSERT INTO user_account 
      (user_email, user_password, fname, lname, phone_number, balance)
      VALUES (?, ?, ?, ?, ?, ?)
    `;
    
    db.query(
      sql, 
      [user_email, hashedPassword, fname, lname, phone_number, balance],
      (err, result) => {
        if (err) {
          console.error('Error creating user:', err);
          return res.status(500).json({ 
            error: 'Error creating user',
            details: err.message 
          });
        }
        
        res.status(201).json({
          message: 'User created successfully',
          userId: result.insertId
        });
      }
    );
  } catch (err) {
    console.error('Error in create user:', err);
    res.status(500).json({ 
      error: 'Internal server error',
      details: err.message 
    });
  }
};

// Update user
export const updateUser = async (req, res) => {
  const { id } = req.params;
  const { fname, lname, phone_number, balance } = req.body;
  
  try {
    const sql = `
      UPDATE user_account 
      SET fname = ?, lname = ?, phone_number = ?, balance = ?
      WHERE user_id = ?
    `;
    
    db.query(sql, [fname, lname, phone_number, balance, id], (err, result) => {
      if (err) {
        console.error('Error updating user:', err);
        return res.status(500).json({ error: 'Error updating user' });
      }
      res.status(200).json({ message: 'User updated successfully' });
    });
  } catch (err) {
    console.error('Error in update user:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Delete user
export const deleteUser = async (req, res) => {
  const { id } = req.params;
  
  if (!id) {
    return res.status(400).json({ error: 'User ID is required' });
  }

  try {
    const sql = 'DELETE FROM user_account WHERE user_id = ?';
    
    db.query(sql, [id], (err, result) => {
      if (err) {
        console.error('Error deleting user:', err);
        return res.status(500).json({ 
          error: 'Error deleting user',
          details: err.message 
        });
      }
      
      if (result.affectedRows === 0) {
        return res.status(404).json({ error: 'User not found' });
      }
      
      res.status(200).json({ 
        message: 'User deleted successfully',
        userId: id 
      });
    });
  } catch (err) {
    console.error('Error in delete user:', err);
    res.status(500).json({ 
      error: 'Internal server error',
      details: err.message 
    });
  }
};