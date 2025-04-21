import express from 'express';
import {
  getUsers,
  createUser,
  deleteUser,
  updateUser,
  getMerchants,
  createMerchant,
  deleteMerchant,
  updateMerchant,
  getAgents,
  createAgent,
  deleteAgent,
  updateAgent,
  getAvailableUsers,
  loginMerchant
} from '../controllers/adminController.js';

const router = express.Router();

// User routes
router.get('/users', getUsers);
router.post('/users', createUser);
router.put('/users/:id', updateUser);
router.delete('/users/:id', deleteUser);
router.get('/available-users', getAvailableUsers);

// Merchant routes
router.get('/merchants', getMerchants);
router.post('/merchants', createMerchant);
router.put('/merchants/:id', updateMerchant);
router.delete('/merchants/:id', deleteMerchant);
router.post('/merchants/login', loginMerchant);

// Agent routes
router.get('/agents', getAgents);
router.post('/agents', createAgent);
router.put('/agents/:id', updateAgent);
router.delete('/agents/:id', deleteAgent);

export default router;