import 'package:flutter/material.dart';
import 'package:sawalove/core/theme/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfilePeekCard extends StatelessWidget {
  final Map<String, dynamic> profile;

  const ProfilePeekCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final name = profile['name'] ?? 'Unknown';
    final age = profile['age'] ?? 0;
    final city = profile['location'] ?? '';
    final intent = profile['goal'] ?? '';
    final verified = profile['verified'] ?? false;
    final photo = profile['photo'] ?? '';

    return Semantics(
      label: 'Super Liking: $name, age $age, from $city. Intent: $intent. ${verified ? "Verified profile." : ""}',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipOval(
              child: CachedNetworkImage(
                imageUrl: photo,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 64,
                  height: 64,
                  color: SawaLoveTheme.surfaceContainerHigh,
                  child: const Icon(Icons.person, color: SawaLoveTheme.onSurfaceVariant),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 64,
                  height: 64,
                  color: SawaLoveTheme.surfaceContainerHigh,
                  child: const Icon(Icons.person, color: SawaLoveTheme.onSurfaceVariant),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '$name, $age',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4A2134),
                        ),
                      ),
                      if (verified) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.verified, color: Color(0xFF1D9E75), size: 18),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    city,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7E4D61),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFECF1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      intent,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFB30065),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

