enum PasswordStrength { weak, fair, good, strong }

PasswordStrength evaluatePasswordStrength(String password) {
  final length = password.length;
  final hasUpper = RegExp(r'[A-Z]').hasMatch(password);
  final hasLower = RegExp(r'[a-z]').hasMatch(password);
  final hasNumber = RegExp(r'[0-9]').hasMatch(password);
  final hasSymbol = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

  int score = 0;
  if (length >= 8) score += 1;
  if (length >= 12) score += 1;
  if (hasUpper && hasLower) score += 1;
  if (hasNumber) score += 1;
  if (hasSymbol) score += 1;

  if (score <= 2) return PasswordStrength.weak;
  if (score <= 3) return PasswordStrength.fair;
  if (score <= 4) return PasswordStrength.good;
  return PasswordStrength.strong;
}
