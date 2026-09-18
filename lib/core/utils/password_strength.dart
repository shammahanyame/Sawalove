enum PasswordStrength { weak, fair, strong }

PasswordStrength evaluatePasswordStrength(String password) {
  if (password.length < 6) return PasswordStrength.weak;
  bool hasUpper = password.contains(RegExp(r'[A-Z]'));
  bool hasNumberOrSymbol = password.contains(RegExp(r'[0-9!@#\$%\^&\*]'));
  
  if (password.length < 8 || (!hasUpper && !hasNumberOrSymbol)) {
    return PasswordStrength.fair;
  }
  
  return PasswordStrength.strong;
}

