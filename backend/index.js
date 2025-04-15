import express from 'express';
import cors from 'cors';
import userRoutes from './routes/user.js';

const app = express();
const PORT = 5000;

// Middleware
app.use(cors()); // Enable CORS for all origins
app.use(express.json()); // Use Express's built-in JSON parser

// Routes
app.use('/api/users', userRoutes);

// Start the server
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});