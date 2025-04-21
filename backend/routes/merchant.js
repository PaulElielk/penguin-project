import express from 'express';
import { loginMerchant, getMerchantById } from '../controllers/merchantController.js';

const router = express.Router();

// Merchant routes
router.post('/login', loginMerchant);
router.get('/:merchantId', getMerchantById);

export default router;