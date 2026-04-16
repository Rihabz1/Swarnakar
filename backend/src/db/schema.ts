import { pgTable, text, timestamp, boolean, integer, decimal, jsonb, serial } from 'drizzle-orm/pg-core';

export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  firebaseId: text('firebase_id').unique().notNull(),
  name: text('name').notNull(),
  email: text('email').unique().notNull(),
  phone: text('phone'),
  address: text('address'),
  profileImage: text('profile_image'),
  hashedPassword: text('hashed_password'),
  isSubscribed: boolean('is_subscribed').default(false),
  subscriptionExpiry: timestamp('subscription_expiry'),
  joinDate: timestamp('join_date').defaultNow(),
  totalCalculations: integer('total_calculations').default(0),
  savedReports: integer('saved_reports').default(0),
  preferences: jsonb('preferences').default({
    notifications: true,
    currency: 'BDT',
    language: 'bn',
  }),
  createdAt: timestamp('created_at').defaultNow(),
  updatedAt: timestamp('updated_at').defaultNow(),
});

export const userStats = pgTable('user_stats', {
  id: serial('id').primaryKey(),
  userId: integer('user_id').references(() => users.id),
  favoritePrices: integer('favorite_prices').default(0),
  subscriptionDaysLeft: integer('subscription_days_left').default(0),
  lastActiveAt: timestamp('last_active_at').defaultNow(),
  createdAt: timestamp('created_at').defaultNow(),
});
