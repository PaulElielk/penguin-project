import express from 'express';
import cors from 'cors';
import userRoutes from './routes/user.js';
import adminRoutes from './routes/admin.js';


const app = express();
const PORT = 5000;

// Middleware
app.use(cors()); // Enable CORS for all origins
app.use(express.json()); // Use Express's built-in JSON parser

// Routes
app.use('/api/users', userRoutes);
app.use('/api/admin', adminRoutes);


// Start the server
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});