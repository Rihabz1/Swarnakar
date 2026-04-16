import { getFirestore, getAuth } from '../config/firebase';

export class ProfileService {
  private async findUserDoc(firebaseId: string) {
    const db = await getFirestore();

    for (const collectionName of ['users', 'Users']) {
      const userDoc = await db.collection(collectionName).doc(firebaseId).get();
      if (userDoc.exists) {
        return userDoc;
      }
    }

    return null;
  }

  async getUserProfile(
    firebaseId: string,
    fallback?: { name?: string | null; email?: string | null; profileImage?: string | null },
  ) {
    try {
      const userDoc = await this.findUserDoc(firebaseId);

      if (!userDoc) {
        return {
          id: firebaseId,
          name: fallback?.name ?? '',
          email: fallback?.email ?? '',
          phone: '',
          address: '',
          profileImage: fallback?.profileImage ?? null,
          isSubscribed: false,
          subscriptionExpiry: null,
          joinDate: new Date(),
          totalCalculations: 0,
          savedReports: 0,
          preferences: {
            notifications: true,
            currency: 'BDT',
            language: 'bn',
          },
        };
      }

      const userData = userDoc.data() as any;
      return {
        id: firebaseId,
        name: userData.name || fallback?.name || '',
        email: userData.email || fallback?.email || '',
        phone: userData.phone || '',
        address: userData.address || '',
        profileImage: userData.profileImage || fallback?.profileImage || null,
        isSubscribed: userData.isSubscribed || false,
        subscriptionExpiry: userData.subscriptionExpiry || null,
        joinDate: userData.joinDate || new Date(),
        totalCalculations: userData.totalCalculations || 0,
        savedReports: userData.savedReports || 0,
        preferences: userData.preferences || {
          notifications: true,
          currency: 'BDT',
          language: 'bn',
        },
      };
    } catch (error) {
      console.error('Error fetching profile from Firestore:', error);
      return {
        id: firebaseId,
        name: fallback?.name ?? '',
        email: fallback?.email ?? '',
        phone: '',
        address: '',
        profileImage: fallback?.profileImage ?? null,
        isSubscribed: false,
        subscriptionExpiry: null,
        joinDate: new Date(),
        totalCalculations: 0,
        savedReports: 0,
        preferences: {
          notifications: true,
          currency: 'BDT',
          language: 'bn',
        },
      };
    }
  }

  async updateUserProfile(firebaseId: string, updateData: any) {
    try {
      const db = await getFirestore();
      let userRef: FirebaseFirestore.DocumentReference | null = null;

      for (const collectionName of ['users', 'Users']) {
        const candidateRef = db.collection(collectionName).doc(firebaseId);
        const candidateDoc = await candidateRef.get();
        if (candidateDoc.exists) {
          userRef = candidateRef;
          break;
        }
      }

      if (!userRef) {
        throw new Error('User not found');
      }

      // Update only the provided fields
      await userRef.update({
        ...updateData,
        updatedAt: new Date(),
      });

      // Return updated data
      const updatedDoc = await userRef.get();
      return updatedDoc.data();
    } catch (error) {
      console.error('Error updating profile in Firestore:', error);
      throw error;
    }
  }

  async changePassword(firebaseId: string, currentPassword: string, newPassword: string) {
    try {
      // For Firebase Auth, password change is handled on the client side
      // This is just a backend notification/logging endpoint
      console.log(`Password change requested for user ${firebaseId}`);

      const db = await getFirestore();
      // You could store password change history in Firestore if needed
      await db.collection('users').doc(firebaseId).update({
        lastPasswordChangeAt: new Date(),
      });

      return {
        success: true,
        message: 'Password changed successfully',
      };
    } catch (error) {
      console.error('Error changing password:', error);
      throw error;
    }
  }

  async deleteAccount(firebaseId: string) {
    try {
      const db = await getFirestore();
      const auth = await getAuth();

      // Soft delete: Mark user as deleted
      await db.collection('users').doc(firebaseId).update({
        isDeleted: true,
        deletedAt: new Date(),
      });

      // Optionally delete from Firebase Auth (requires admin SDK)
      await auth.deleteUser(firebaseId);

      return {
        success: true,
        message: 'Account deleted successfully',
      };
    } catch (error) {
      console.error('Error deleting account:', error);
      throw error;
    }
  }

  async getUserStats(firebaseId: string) {
    try {
      const userDoc = await this.findUserDoc(firebaseId);

      if (!userDoc) {
        return {
          totalCalculations: 0,
          savedReports: 0,
          favoritePrices: 0,
          subscriptionDaysLeft: 0,
        };
      }

      const userData = userDoc.data() as any;

      return {
        totalCalculations: userData.totalCalculations || 0,
        savedReports: userData.savedReports || 0,
        favoritePrices: userData.favoritePrices || 0,
        subscriptionDaysLeft: this.calculateSubscriptionDaysLeft(userData.subscriptionExpiry),
      };
    } catch (error) {
      console.error('Error fetching stats from Firestore:', error);
      return {
        totalCalculations: 0,
        savedReports: 0,
        favoritePrices: 0,
        subscriptionDaysLeft: 0,
      };
    }
  }

  async createUser(firebaseId: string, email: string, name: string) {
    try {
      const db = await getFirestore();
      const userData = {
        firebaseId,
        email,
        name,
        isSubscribed: false,
        totalCalculations: 0,
        savedReports: 0,
        favoritePrices: 0,
        createdAt: new Date(),
        updatedAt: new Date(),
        preferences: {
          notifications: true,
          currency: 'BDT',
          language: 'bn',
        },
      };

      await db.collection('users').doc(firebaseId).set(userData);
      return userData;
    } catch (error) {
      console.error('Error creating user in Firestore:', error);
      throw error;
    }
  }

  private calculateSubscriptionDaysLeft(expiryDate: any): number {
    if (!expiryDate) return 0;

    const expiry = expiryDate instanceof Date ? expiryDate : expiryDate.toDate?.() || new Date(expiryDate);
    const today = new Date();
    const diffTime = expiry.getTime() - today.getTime();
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

    return Math.max(0, diffDays);
  }
}
