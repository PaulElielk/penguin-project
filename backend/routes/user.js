import express from 'express';
import { 
  createUser, 
  loginUser, 
  getUsers, 
  makeTransaction, 
  getUserById, 
  searchUserByPhone, 
  getUserTransactions, 
  getUserProfile, 
  updateUserProfile, 
  updateUserPassword,
  loginMerchant,
  getMerchantById,
  getMerchantTransactions,
  validateUserQR
} from '../controllers/usersController.js';

const router = express.Router();

// User routes
router.post('/register', createUser);
router.post('/login', loginUser);
router.get('/', getUsers);
router.post('/transaction', makeTransaction);
router.get('/search', searchUserByPhone);
router.get('/:userId', getUserById);
router.get('/:userId/transactions', getUserTransactions);
router.get('/:userId/profile', getUserProfile);
router.put('/:userId/profile', updateUserProfile);
router.put('/:userId/password', updateUserPassword);
router.get('/validate-qr/:userId', validateUserQR);

// Merchant routes
router.post('/merchants/login', loginMerchant);
router.get('/merchants/:merchantId', getMerchantById);
router.get('/:userId/merchant-transactions', getMerchantTransactions);

export default router;