import express from 'express';
import { createUser, loginUser, getUsers } from '../controllers/usersController.js';

const router = express.Router();

// Routes
router.post('/register', createUser); // Register a new user
router.post('/login', loginUser); // Log in a user
router.get('/', getUsers); // Get all users

export default router;