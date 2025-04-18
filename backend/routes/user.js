import express from 'express';
import { createUser, loginUser, getUsers, makeTransaction, getUserById, searchUserByPhone } from '../controllers/usersController.js';

const router = express.Router();

// Routes
router.post('/register', createUser); // Register a new user
router.post('/login', loginUser); // Log in a user
router.get('/', getUsers); // Get all users
router.post('/transaction', makeTransaction); // Handle transactions
router.get('/search', searchUserByPhone); // Search user by phone (changed from /users/search to /search)
router.get('/:userId', getUserById); // Get user by ID

export default router;