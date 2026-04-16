import { Context } from 'hono';
import { ProfileService } from '../services/profile.service';

const profileService = new ProfileService();

export class ProfileController {
  async getProfile(c: Context) {
    try {
      const firebaseId = c.get('userId'); // From auth middleware (Firebase ID from JWT 'sub' claim)
      const profile = await profileService.getUserProfile(firebaseId, {
        name: c.get('userName'),
        email: c.get('userEmail'),
        profileImage: c.get('userPicture'),
      });

      return c.json({
        success: true,
        data: profile,
      });
    } catch (error) {
      console.error('Error fetching profile:', error);
      return c.json({ success: false, error: 'Failed to fetch profile' }, 500);
    }
  }

  async updateProfile(c: Context) {
    try {
      const firebaseId = c.get('userId');
      const updateData = await c.req.json();

      const result = await profileService.updateUserProfile(firebaseId, updateData);

      return c.json({
        success: true,
        data: result,
      });
    } catch (error) {
      console.error('Error updating profile:', error);
      return c.json({ success: false, error: 'Failed to update profile' }, 500);
    }
  }

  async changePassword(c: Context) {
    try {
      const firebaseId = c.get('userId');
      const { currentPassword, newPassword } = await c.req.json();

      const result = await profileService.changePassword(firebaseId, currentPassword, newPassword);

      return c.json({
        success: true,
        data: result,
      });
    } catch (error) {
      console.error('Error changing password:', error);
      return c.json({ success: false, error: 'Failed to change password' }, 500);
    }
  }

  async deleteAccount(c: Context) {
    try {
      const firebaseId = c.get('userId');
      const result = await profileService.deleteAccount(firebaseId);

      return c.json({
        success: true,
        data: result,
      });
    } catch (error) {
      console.error('Error deleting account:', error);
      return c.json({ success: false, error: 'Failed to delete account' }, 500);
    }
  }

  async getUserStats(c: Context) {
    try {
      const firebaseId = c.get('userId');
      const stats = await profileService.getUserStats(firebaseId);

      return c.json({
        success: true,
        data: stats,
      });
    } catch (error) {
      console.error('Error fetching stats:', error);
      return c.json({ success: false, error: 'Failed to fetch stats' }, 500);
    }
  }
}
