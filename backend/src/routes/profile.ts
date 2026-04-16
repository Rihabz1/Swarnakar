import { Hono } from 'hono';
import { ProfileController } from '../controllers/profile.controller';
import { authMiddleware } from '../middleware/auth.middleware';

const profileRoutes = new Hono();
const profileController = new ProfileController();

// Apply auth middleware to all profile routes
profileRoutes.use('*', authMiddleware);

profileRoutes.get('/', profileController.getProfile);
profileRoutes.put('/update', profileController.updateProfile);
profileRoutes.post('/change-password', profileController.changePassword);
profileRoutes.delete('/delete-account', profileController.deleteAccount);
profileRoutes.get('/stats', profileController.getUserStats);

export { profileRoutes };
