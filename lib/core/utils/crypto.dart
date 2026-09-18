import 'dart:convert';
import 'package:crypto/crypto.dart' as crypto;

Future<String> hashPin(String pin) async {
  final bytes = utf8.encode(pin);
  final digest = crypto.sha256.convert(bytes);
  return digest.toString();
}

