import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 18+ age gate shown between language selection and login.
///
/// Play Store requires dating apps to enforce an adult-only audience; this
/// screen blocks account creation for anyone under 18 and the declared date
/// of birth is stored so the backend can audit it.
class AgeGateScreen extends ConsumerStatefulWidget {
  const AgeGateScreen({super.key, this.datePicked});

  static const _dobKey = 'sawalove.declared_dob_iso';

  /// Test seam: when provided, this replaces the material date-picker dialog
  /// so widget tests can drive the gate deterministically.
  final Future<DateTime?> Function(BuildContext)? datePicked;

  /// True when the user previously passed the gate.
  static Future<bool> isVerified() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_dobKey) != null;
  }

  @override
  ConsumerState<AgeGateScreen> createState() => _AgeGateScreenState();
}

class _AgeGateScreenState extends ConsumerState<AgeGateScreen> {
  DateTime? _selectedDate;
  String? _errorText;

  bool _isFrench = false;

  bool get _isAdult {
    final dob = _selectedDate;
    if (dob == null) return false;
    final now = DateTime.now();
    var age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age >= 18;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final DateTime? picked;
    if (widget.datePicked != null) {
      picked = await widget.datePicked!(context);
    } else {
      picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate ?? DateTime(now.year - 25),
        firstDate: DateTime(now.year - 100),
        lastDate: now,
        helpText: _isFrench
            ? 'Sélectionnez votre date de naissance'
            : 'Select your date of birth',
      );
    }
    if (picked == null) return;
    setState(() {
      _selectedDate = picked;
      _errorText = null;
    });
  }

  Future<void> _continue() async {
    if (_selectedDate == null) {
      setState(() {
        _errorText = _isFrench
            ? "Sélectionnez votre date de naissance pour continuer"
            : 'Select your date of birth to continue';
      });
      return;
    }
    if (!_isAdult) {
      setState(() {
        _errorText = _isFrench
            ? "SawaLove est réservé aux adultes de 18 ans et plus. Vous ne pouvez pas créer de compte."
            : 'SawaLove is only for adults aged 18 and over. You cannot create an account.';
      });
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        AgeGateScreen._dobKey, _selectedDate!.toIso8601String());
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    _isFrench = Localizations.localeOf(context).languageCode == 'fr';
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.verified_user_outlined,
                size: 64,
                color: Color(0xFFB30065),
              ),
              const SizedBox(height: 32),
              Text(
                _isFrench
                    ? "Vous devez avoir 18 ans ou plus"
                    : 'You must be 18 or older',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _isFrench
                    ? "SawaLove est une communauté de rencontre pour adultes. Veuillez confirmer votre date de naissance pour continuer."
                    : 'SawaLove is a dating community for adults. Please confirm '
                        'your date of birth to continue.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(
                  _selectedDate == null
                      ? (_isFrench
                          ? 'Sélectionnez votre date de naissance'
                          : 'Select date of birth')
                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                  style: const TextStyle(fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorText!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 40),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB30065),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: Text(
                    _isFrench ? 'Continuer' : 'Continue',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/profile/terms'),
                child: Text(_isFrench
                    ? "Lire les conditions d'utilisation"
                    : 'Read the Terms of Service'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
