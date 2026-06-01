# Contributing to Swarnakar

Thank you for your interest in contributing to Swarnakar! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Making Changes](#making-changes)
- [Submitting Changes](#submitting-changes)
- [Coding Standards](#coding-standards)
- [Commit Message Guidelines](#commit-message-guidelines)
- [Pull Request Process](#pull-request-process)
- [Reporting Issues](#reporting-issues)
- [Feature Requests](#feature-requests)

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inspiring community for all.

### Our Standards

- Use welcoming and inclusive language
- Be respectful of differing opinions
- Accept constructive criticism gracefully
- Focus on what is best for the community
- Show empathy towards other community members

### Enforcement

Instances of abusive, harassing, or otherwise unacceptable behavior may be reported by contacting sarkarkabbo72@gmail.com.

## Getting Started

### Prerequisites

- Flutter SDK 3.x
- Dart 3.x
- Bun runtime
- Git
- Firebase CLI
- Your favorite code editor (VS Code recommended)

### Development Setup

1. **Fork the Repository**
   ```bash
   # Click "Fork" button on GitHub
   # Clone your fork
   git clone https://github.com/yourusername/swarnakar.git
   cd Swarnakar
   ```

2. **Add Upstream Remote**
   ```bash
   git remote add upstream https://github.com/original-owner/swarnakar.git
   git fetch upstream
   ```

3. **Create Development Branch**
   ```bash
   git checkout -b develop
   git pull upstream develop
   ```

4. **Follow Setup Instructions**
   - See [README.md - Complete Setup Guide](README.md#19-complete-setup-guide-step-by-step)

## Making Changes

### 1. Create Feature Branch

```bash
# Always branch from develop, not main
git checkout develop
git pull upstream develop

# Create your feature branch
git checkout -b feature/add-gold-price-api
# or
git checkout -b bugfix/fix-otp-validation
# or
git checkout -b docs/update-api-docs
```

### 2. Keep Your Branch Updated

```bash
# Fetch latest changes
git fetch upstream

# Rebase on develop
git rebase upstream/develop

# If conflicts exist, resolve them and continue
git add .
git rebase --continue
```

### 3. Follow Coding Standards

See [Coding Standards](#coding-standards) section below.

## Submitting Changes

### 1. Before Submitting

```bash
# Format code
dart format lib/ backend/src/

# Run analysis
flutter analyze
cd backend && bun run lint  # if available

# Run tests
flutter test
cd backend && bun test  # if available

# Clean build
flutter clean
flutter pub get
```

### 2. Commit Your Changes

Follow [Commit Message Guidelines](#commit-message-guidelines)

```bash
git add .
git commit -m "feat: add endpoint to fetch gold price history"
```

### 3. Push to Your Fork

```bash
git push origin feature/add-gold-price-api
```

### 4. Create Pull Request

Go to GitHub and click "Compare & pull request"

## Coding Standards

### Dart/Flutter

#### Naming Conventions

```dart
// ✅ Classes: PascalCase
class UserAuthenticationProvider extends StateNotifier<AuthState> {}
class GoldPriceScreen extends ConsumerWidget {}

// ✅ Variables/Methods: camelCase
final userEmail = 'user@example.com';
void sendVerificationEmail() {}

// ✅ Constants: camelCase
const defaultOtpExpiryMinutes = 10;

// ✅ Files: snake_case
// lib/features/auth/providers/auth_provider.dart
// lib/shared/widgets/golden_button.dart

// ❌ Avoid single letter names (except iterators)
// ❌ Avoid abbreviated names: UAP, AS, etc.
```

#### Code Style

```dart
// ✅ Good: Clear comments
/// Sends OTP to user's email for password reset.
/// 
/// Validates email format, checks rate limits, and sends 6-digit code.
/// Returns masked email and expiry time.
Future<OtpResponse> sendOtp(String email) async {
  // Implementation
}

// ✅ Good: Null safety
String? getUserName(User? user) {
  return user?.profile?.name;
}

// ✅ Good: Consistent formatting
final users = [
  UserModel(id: '1', name: 'John', email: 'john@example.com'),
  UserModel(id: '2', name: 'Jane', email: 'jane@example.com'),
];

// ✅ Good: Proper error handling
try {
  await authService.signup(email, password);
} catch (e) {
  _showErrorDialog('Signup failed: ${e.toString()}');
}

// ❌ Bad: Silent failures
try {
  await authService.signup(email, password);
} catch (e) {
  // Ignore error
}

// ❌ Bad: Unclear comments
// Do the thing
void doIt() {
  // Implementation
}
```

#### Widget Structure

```dart
// ✅ Good: Clean widget structure
class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: userAsync.when(
        data: (user) => _buildProfileContent(user),
        loading: () => const CircularProgressIndicator(),
        error: (error, stack) => ErrorWidget(error: error),
      ),
    );
  }

  Widget _buildProfileContent(UserModel user) {
    return Column(
      children: [
        // Content
      ],
    );
  }
}
```

### TypeScript (Backend)

#### Naming Conventions

```typescript
// ✅ Interfaces/Types: PascalCase
interface OtpRequest {
  email: string;
  purpose: OtpPurpose;
}

type OtpPurpose = 'reset_password' | 'login_verification';

// ✅ Functions: camelCase
async function sendOtp(request: OtpRequest): Promise<OtpResponse> {
  // Implementation
}

// ✅ Classes: PascalCase
class AuthService {
  async sendOtp(email: string): Promise<void> {}
}

// ✅ Constants: SCREAMING_SNAKE_CASE
const OTP_EXPIRY_MINUTES = 10;
const MAX_OTP_ATTEMPTS = 5;

// ✅ Files: kebab-case
// src/controllers/auth-controller.ts
// src/services/profile-service.ts
```

#### Code Style

```typescript
// ✅ Good: Strong typing
interface UserProfile {
  uid: string;
  email: string;
  name: string;
  isSubscribed: boolean;
  createdAt: Date;
}

async function getUserProfile(uid: string): Promise<UserProfile | null> {
  try {
    const doc = await db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return doc.data() as UserProfile;
  } catch (error) {
    logger.error('Failed to fetch profile:', error);
    throw new ApiError('Failed to fetch profile', 500);
  }
}

// ✅ Good: Error handling with proper types
class ApiError extends Error {
  constructor(
    public message: string,
    public statusCode: number,
    public code?: string
  ) {
    super(message);
  }
}

// ✅ Good: Async/await usage
async function resetPassword(
  email: string,
  resetToken: string,
  newPassword: string
): Promise<void> {
  const user = await auth.getUserByEmail(email);
  await auth.updateUser(user.uid, { password: newPassword });
}

// ❌ Bad: Missing types
function getUserProfile(uid) {
  return db.collection('users').doc(uid).get();
}

// ❌ Bad: Poor error handling
try {
  await updateProfile(data);
} catch (e) {
  console.log(e);
}
```

## Commit Message Guidelines

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type

- **feat**: A new feature
- **fix**: A bug fix
- **docs**: Documentation only changes
- **style**: Changes that do not affect the meaning of code (formatting, etc.)
- **refactor**: Code change that neither fixes a bug nor adds a feature
- **perf**: Code change that improves performance
- **test**: Adding missing tests or correcting existing tests
- **chore**: Changes to build process, dependencies, etc.

### Scope

Optional, but recommended. Examples:
- auth
- profile
- calculator
- prices
- frontend
- backend
- docs

### Subject

- Use imperative mood ("add" not "added" or "adds")
- Don't capitalize first letter
- No period (.) at the end
- Limit to 50 characters

### Body

- Explain what and why, not how
- Wrap at 72 characters
- Separate from subject with blank line

### Examples

```
feat(auth): add email verification link handling

Implement /finishSignIn route to handle Firebase email action links.
Allows users to verify email directly from email link sent by Firebase Auth.

Closes #123
```

```
fix(calculator): resolve incorrect bhori conversion

The calculator was not correctly converting grams to bhori.
Changed conversion factor from 11.5 to 11.66 per gold standard.

Fixes #456
```

```
docs: update API documentation with request/response examples

Added complete API documentation with curl examples and response codes
for all profile and auth endpoints.
```

## Pull Request Process

### PR Title Format

```
[TYPE] Brief description of changes
```

Examples:
- `[FEAT] Add gold price API endpoint`
- `[FIX] Resolve CORS issue on profile routes`
- `[DOCS] Update API documentation`
- `[REFACTOR] Simplify authentication logic`

### PR Description Template

```markdown
## Description
Brief description of what this PR does.

## Type of Change
- [ ] New feature
- [ ] Bug fix
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Code refactoring

## Related Issues
Closes #(issue number)

## Changes Made
- Change 1
- Change 2
- Change 3

## Testing
- [ ] Added/updated tests
- [ ] All tests pass
- [ ] Tested on [device/platform]

## Screenshots (if applicable)
Add screenshots of UI changes.

## Checklist
- [ ] Code follows style guidelines
- [ ] Comments added for complex logic
- [ ] Documentation updated
- [ ] No breaking changes
- [ ] Tested thoroughly
```

### Review Process

1. **Code Review**: Maintainers will review your PR
2. **Tests**: CI/CD pipeline will run automated tests
3. **Feedback**: Address any comments or suggestions
4. **Approval**: PR will be merged after approval
5. **Cleanup**: Delete your branch after merge

## Reporting Issues

### Issue Title

Be specific and descriptive:
- ✅ "OTP verification fails after 5 minutes expiry"
- ❌ "App doesn't work"

### Issue Template

```markdown
## Description
Clear description of the issue.

## Steps to Reproduce
1. Step 1
2. Step 2
3. Step 3

## Expected Behavior
What should happen?

## Actual Behavior
What actually happens?

## Environment
- Flutter version: `flutter --version`
- Dart version: `dart --version`
- OS: [Windows/macOS/Linux]
- Device/Browser: [e.g., Chrome, Android Emulator]

## Logs
```
Paste relevant error logs or stack traces
```

## Screenshots
Attach screenshots if applicable.

## Additional Context
Any other relevant information.
```

### Issue Labels

- `bug` - Something isn't working
- `enhancement` - Feature request
- `documentation` - Improvements to documentation
- `good first issue` - Good for newcomers
- `help wanted` - Extra attention needed
- `priority: high` - Urgent
- `priority: low` - Can wait

## Feature Requests

### Format

```markdown
## Feature Description
Clear description of the requested feature.

## Use Case
Why is this feature needed? Who will benefit?

## Proposed Solution
How should this feature work?

## Alternatives
Are there alternative approaches?

## Additional Context
Mockups, screenshots, or additional information.
```

## Development Workflow Summary

```
1. Fork repository
2. Clone your fork
3. Add upstream remote
4. Create feature branch from develop
5. Make changes following coding standards
6. Commit with clear messages
7. Push to your fork
8. Create Pull Request
9. Respond to review feedback
10. PR merged by maintainer
```

## Questions?

If you have questions about contributing:
- 📧 Email: sarkarkabbo72@gmail.com
- 💬 Create a GitHub Discussion
- 🐛 Open an issue for clarification

---

**Thank you for contributing to Swarnakar! 🙏**
