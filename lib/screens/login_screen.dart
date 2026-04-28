import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../components/primary_button.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      final authProvider = context.read<AuthProvider>();
      bool success;

      if (_isLogin) {
        // Login
        success = await authProvider.login(
          emailOrPhone: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        // Register
        success = await authProvider.register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
        );
      }

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        if (_isLogin) {
          // Login success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login successful!'),
              backgroundColor: AppColors.darkBrown,
            ),
          );

          // Check if we came from checkout flow
          final isFromCheckout =
              GoRouterState.of(context).uri.queryParameters['from'] ==
                  'checkout';

          if (isFromCheckout) {
            // Clear cart only for checkout flow
            context.read<CartProvider>().clear();
            // Navigate to order success screen
            context.go('/cart/checkout/success');
          } else {
            // For profile or other origins, just go back to profile screen
            context.go('/profile');
          }
        } else {
            // Registration success - redirect to OTP verification
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(authProvider.infoMessage ??
                    'Verification code sent to your email!'),
                backgroundColor: Colors.green,
              ),
            );

          // Navigate to OTP verification screen with email
          context.push(
            '/cart/checkout/verify-email',
            extra: _emailController.text.trim(),
          );
        }
      } else {
        // Show error message
        final errorMessage = authProvider.error ?? 'An error occurred';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.terracotta,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: const Icon(Icons.chevron_left_rounded, size: 28),
            onPressed: () => context.pop(),
          ),
        ),
        title: Text(_isLogin ? l10n.login : l10n.register),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: width > 400
              ? const EdgeInsets.all(24)
              : const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Logo/Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.darkBrown, AppColors.softBrown],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkBrown.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shopping_basket_rounded,
                    size: 40,
                    color: AppColors.cream,
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                Text(
                  _isLogin ? l10n.welcomeBack : l10n.createAccount,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBrown,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  _isLogin ? l10n.loginSubtitle : l10n.registerSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textLight,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Name field (only for register)
                if (!_isLogin) ...[
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: l10n.name,
                      prefixIcon: const Icon(Icons.person_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.nameRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Phone field (only for register)
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: const Icon(Icons.phone_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Phone number is required';
                      }
                      if (value.length < 10) {
                        return 'Enter valid phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.emailRequired;
                    }
                    if (!value.contains('@')) {
                      return l10n.emailInvalid;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: Color.fromARGB(1, 0, 0, 0),
                      ),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.passwordRequired;
                    }
                    if (value.length < 6) {
                      return l10n.passwordTooShort;
                    }
                    return null;
                  },
                ),

                if (!_isLogin) ...[
                  const SizedBox(height: 16),

                  // Confirm Password field
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: l10n.confirmPassword,
                      prefixIcon: const Icon(Icons.lock_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.confirmPasswordRequired;
                      }
                      if (value != _passwordController.text) {
                        return l10n.passwordsDoNotMatch;
                      }
                      return null;
                    },
                  ),
                ],

                const SizedBox(height: 8),

                // Forgot password (only for login)
                if (_isLogin)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        context.push('/login/forgot-password');
                      },
                      child: Text(l10n.forgotPassword),
                    ),
                  ),

                const SizedBox(height: 24),

                // Submit button
                PrimaryButton(
                  label: _isLogin ? l10n.login : l10n.register,
                  onTap: _handleSubmit,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        l10n.or,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textLight,
                            ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 24),

                // // Social login buttons
                // _SocialButton(
                //   icon: Icons.g_mobiledata,
                //   label: l10n.continueWithGoogle,
                //   onTap: () {
                //     // TODO: Implement Google sign in
                //   },
                // ),

                // const SizedBox(height: 32),

                // Toggle login/register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLogin ? l10n.dontHaveAccount : l10n.alreadyHaveAccount,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() => _isLogin = !_isLogin);
                      },
                      child: Text(
                        _isLogin ? l10n.register : l10n.login,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.darkBrown,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.beige, width: 1.5),
          borderRadius: BorderRadius.circular(16),
          color: AppColors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: AppColors.darkBrown),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.darkBrown,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
