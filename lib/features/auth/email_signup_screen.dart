import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sawalove/core/utils/password_strength.dart';
import 'package:go_router/go_router.dart';
import 'package:sawalove/shared/services/firebase_service.dart';

class EmailSignupScreen extends ConsumerStatefulWidget {
  const EmailSignupScreen({super.key});

  @override
  ConsumerState<EmailSignupScreen> createState() => _EmailSignupScreenState();
}

class _EmailSignupScreenState extends ConsumerState<EmailSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _country = 'CM';
  bool _isFormValid = false;
  bool _isSubmitting = false;
  bool _isSignInMode = false;
  bool _obscurePassword = true;

  final List<String> _countries = ['CM', 'FR', 'GB', 'US', 'DE', 'CA', 'NG'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(_isSignInMode ? 'Sign in with email' : 'Sign up with email'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            onChanged: _validateForm,
            child: Column(
              children: [
                // Step 1: Why email cards
                if (!_isSignInMode) ...[
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle,
                                  color: Colors.green, size: 24),
                              SizedBox(width: 12),
                              Expanded(child: Text('Works from any country')),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(Icons.warning_amber,
                                  color: Colors.orange, size: 24),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                    'Super Likes, Premium, Nearby Map require verified phone'),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(Icons.favorite_border,
                                  color: Colors.purple, size: 24),
                              SizedBox(width: 12),
                              Expanded(
                                  child: Text('Cameroonians abroad welcome')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
                // Step 2: Form
                if (!_isSignInMode) ...[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (_isSignInMode) return null;
                      return (value?.length ?? 0) < 2
                          ? 'Minimum 2 characters'
                          : null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    if (!_isValidEmail(value)) return 'Invalid email';
                    return _suggestEmailCorrection(value);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    if (_isSignInMode) return null;
                    final strength = evaluatePasswordStrength(value);
                    if (strength == PasswordStrength.weak) {
                      return 'Password too weak';
                    }
                    return null;
                  },
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 16),
                if (!_isSignInMode) ...[
                  DropdownButtonFormField<String>(
                    initialValue: _country,
                    decoration: const InputDecoration(
                      labelText: 'Country of residence',
                      border: OutlineInputBorder(),
                    ),
                    items: _countries
                        .map((country) => DropdownMenuItem(
                              value: country,
                              child: Text(country),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _country = value!);
                      _validateForm();
                    },
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isFormValid && !_isSubmitting
                      ? _submitEmailCredentials
                      : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isSignInMode ? 'Sign in' : 'Create account'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _isSubmitting ? null : _toggleMode,
                  child: Text(_isSignInMode
                      ? 'Create a new account'
                      : 'Already have an account? Sign in'),
                ),
                TextButton.icon(
                  onPressed: _isSubmitting ? null : () => context.go('/login'),
                  icon: const Icon(Icons.phone_android),
                  label: const Text('Use phone or social sign-in'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(email.trim());
  }

  String? _suggestEmailCorrection(String email) {
    final corrections = {
      'gmail.con': 'gmail.com',
      'gmial.com': 'gmail.com',
      'gmaill.com': 'gmail.com',
      'yahooo.com': 'yahoo.com',
      'outlok.com': 'outlook.com',
    };
    for (final wrong in corrections.keys) {
      if (email.endsWith(wrong)) {
        return 'Did you mean ${corrections[wrong]}?';
      }
    }
    return null;
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  void _toggleMode() {
    setState(() {
      _isSignInMode = !_isSignInMode;
      _isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  Future<void> _submitEmailCredentials() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      setState(() => _isSubmitting = true);
      final backend = ref.read(firebaseServiceProvider);
      if (_isSignInMode) {
        await backend.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await backend.signUpWithEmail(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          country: _country,
        );
      }
      if (!mounted) return;
      if (_isSignInMode || backend.isSignedIn) {
        context.go('/onboarding');
      } else {
        context.go('/login/email/verify');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authErrorMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}

// Step 3: Verification gate (stub for stream listener)
class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify email')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.email, size: 80),
            SizedBox(height: 32),
            Text('Check your email for verification link'),
            SizedBox(height: 16),
            TextButton(onPressed: null, child: Text('Resend (cooldown)')),
            SizedBox(height: 16),
            TextButton(onPressed: null, child: Text('Switch to phone sign-up')),
          ],
        ),
      ),
    );
  }
}

// Step 4: Add phone (stub)
class AddPhoneScreen extends StatelessWidget {
  const AddPhoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add phone (optional)')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Unlock premium features'),
            SizedBox(height: 16),
            Text('- Super Likes'),
            Text('- Premium subscription'),
            Text('- Nearby People Map'),
            SizedBox(height: 32),
            ElevatedButton(
                onPressed: null, child: Text('Add phone & continue')),
            TextButton(onPressed: null, child: Text('Skip for now')),
          ],
        ),
      ),
    );
  }
}
