// lib/features/onboarding/preferences_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import '../../shared/providers/preferences_provider.dart';
import '../../shared/services/firebase_service.dart';

class PreferencesScreen extends ConsumerStatefulWidget {
  const PreferencesScreen({super.key});

  @override
  ConsumerState<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends ConsumerState<PreferencesScreen> {
  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(preferencesProvider);
    final isOpenToAll = prefs.openToAll;

    return Scaffold(
      backgroundColor: SawaLoveTheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Who are you looking for?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _showDemoMenu,
            child: const Text('Demo'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tune your match pool / Ajustez votre bassin',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: SawaLoveTheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 24),
                      // Open to All toggle
                      _buildOpenToAllToggle(prefs),
                      const SizedBox(height: 24),
                      // Age range
                      _buildSectionTitle('Age Range / Tranche d\'âge'),
                      const SizedBox(height: 8),
                      _buildAgeRange(prefs, isOpenToAll),
                      const SizedBox(height: 24),
                      // Distance
                      _buildSectionTitle('Distance / Distance'),
                      const SizedBox(height: 8),
                      _buildDistanceSlider(prefs, isOpenToAll),
                      const SizedBox(height: 24),
                      // Gender
                      _buildSectionTitle('Gender / Genre'),
                      const SizedBox(height: 8),
                      _buildChipRow(
                        options: const [
                          _ChipOption('women', 'Women / Femmes'),
                          _ChipOption('men', 'Men / Hommes'),
                          _ChipOption('nonbinary', 'Non-binary'),
                          _ChipOption('everyone', 'Everyone / Tout le monde'),
                        ],
                        selected: prefs.genders,
                        onToggle: (value) => ref
                            .read(preferencesProvider.notifier)
                            .toggleGender(value),
                        disabled: isOpenToAll,
                      ),
                      const SizedBox(height: 24),
                      // Intent
                      _buildSectionTitle('Relationship Intent / Intention'),
                      const SizedBox(height: 8),
                      _buildChipRow(
                        options: const [
                          _ChipOption('serious', 'Serious / Sérieuse'),
                          _ChipOption('casual', 'Casual / Légère'),
                          _ChipOption('friendship', 'Friendship / Amitié'),
                          _ChipOption('networking', 'Networking'),
                          _ChipOption('marriage', 'Marriage / Mariage'),
                        ],
                        selected: prefs.intents,
                        onToggle: (value) => ref
                            .read(preferencesProvider.notifier)
                            .toggleIntent(value),
                        disabled: isOpenToAll,
                      ),
                      const SizedBox(height: 24),
                      // Religion
                      _buildSectionTitle('Religion / Religion'),
                      const SizedBox(height: 8),
                      _buildChipRow(
                        options: const [
                          _ChipOption('christian', 'Christian / Chrétien'),
                          _ChipOption('muslim', 'Muslim / Musulman'),
                          _ChipOption(
                              'traditional', 'Traditional / Traditionnel'),
                          _ChipOption('none', 'No religion / Sans'),
                          _ChipOption('any_faith', 'Any faith / Toute foi'),
                        ],
                        selected: prefs.religions,
                        onToggle: (value) => ref
                            .read(preferencesProvider.notifier)
                            .toggleReligion(value),
                        disabled: isOpenToAll,
                      ),
                      const SizedBox(height: 24),
                      // Deal-breakers
                      _buildSectionTitle(
                          'Deal-breakers / Critères éliminatoires'),
                      const SizedBox(height: 8),
                      _buildDealbreakerTile(
                        label: 'Has children / A des enfants',
                        description:
                            'Exclude profiles with children / Exclure les profils avec enfants',
                        value: prefs.dealbreakers['children'] ?? false,
                        onChanged: isOpenToAll
                            ? null
                            : (v) => ref
                                .read(preferencesProvider.notifier)
                                .toggleDealbreaker('children'),
                      ),
                      _buildDealbreakerTile(
                        label: 'Smokes / Fume',
                        description: 'Exclude smokers / Exclure les fumeurs',
                        value: prefs.dealbreakers['smokes'] ?? false,
                        onChanged: isOpenToAll
                            ? null
                            : (v) => ref
                                .read(preferencesProvider.notifier)
                                .toggleDealbreaker('smokes'),
                      ),
                      _buildDealbreakerTile(
                        label: 'Only photo-verified / Uniquement vérifiés',
                        description:
                            'Show only verified users / Afficher uniquement les utilisateurs vérifiés',
                        value: prefs.dealbreakers['unverified'] ?? false,
                        onChanged: isOpenToAll
                            ? null
                            : (v) => ref
                                .read(preferencesProvider.notifier)
                                .toggleDealbreaker('unverified'),
                      ),
                      const SizedBox(height: 24),
                      // Pool counter
                      _buildPoolCounter(prefs),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              // CTA
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    await ref
                        .read(preferencesProvider.notifier)
                        .savePreferences('');
                    final backend = ref.read(firebaseServiceProvider);
                    final uid = backend.currentUserId;
                    if (uid != null) {
                      await backend.saveUserProfile(uid, {
                        'visible': true,
                        'preferences': {
                          'ageMin': prefs.ageMin,
                          'ageMax': prefs.ageMax,
                          'distanceKm': prefs.distanceKm,
                          'genders': prefs.genders.toList(),
                          'intents': prefs.intents.toList(),
                          'religions': prefs.religions.toList(),
                          'dealbreakers': prefs.dealbreakers,
                          'openToAll': prefs.openToAll,
                        },
                      });
                    }
                    if (!context.mounted) return;
                    context.go('/home/discover');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SawaLoveTheme.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999)),
                  ),
                  child: const Text(
                    'Discover Matches / Découvrir',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: SawaLoveTheme.onSurface,
      ),
    );
  }

  Widget _buildOpenToAllToggle(PreferencesState prefs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: prefs.openToAll
            ? const Color(0xFFE8F8EF)
            : SawaLoveTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: prefs.openToAll
              ? const Color(0xFF1D9E75)
              : SawaLoveTheme.surfaceContainerHighest,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.public,
            color: prefs.openToAll
                ? const Color(0xFF1D9E75)
                : SawaLoveTheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Show me everyone / Montrez-moi tout le monde',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Ignore all filters above / Ignorer tous les filtres ci-dessus',
                  style: TextStyle(
                    fontSize: 12,
                    color: SawaLoveTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: prefs.openToAll,
            onChanged: (v) =>
                ref.read(preferencesProvider.notifier).setOpenToAll(v),
            activeThumbColor: const Color(0xFF1D9E75),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeRange(PreferencesState prefs, bool disabled) {
    final minLabel = prefs.ageMin.toString();
    final maxLabel = prefs.ageMax >= 60 ? '60+' : prefs.ageMax.toString();

    return Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: IgnorePointer(
        ignoring: disabled,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SawaLoveTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: SawaLoveTheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$minLabel – $maxLabel',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Semantics(
                label:
                    'Age range slider. Minimum age: ${prefs.ageMin}. Maximum age: ${prefs.ageMax}. '
                    'Drag the left thumb to adjust minimum age, right thumb to adjust maximum age.',
                child: RangeSlider(
                  values: RangeValues(
                      prefs.ageMin.toDouble(), prefs.ageMax.toDouble()),
                  min: 18,
                  max: 60,
                  divisions: 42,
                  activeColor: SawaLoveTheme.primary,
                  inactiveColor: SawaLoveTheme.surfaceContainerHighest,
                  onChanged: (values) {
                    ref.read(preferencesProvider.notifier).setAgeRange(
                          values.start.toInt(),
                          values.end.toInt(),
                        );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDistanceSlider(PreferencesState prefs, bool disabled) {
    return Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: IgnorePointer(
        ignoring: disabled,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SawaLoveTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: SawaLoveTheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      prefs.distanceLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Semantics(
                label:
                    'Distance slider. Current value: ${prefs.distanceLabel}. Drag to adjust maximum distance.',
                child: Slider(
                  value: prefs.distanceKm,
                  min: 1,
                  max: 500,
                  divisions: 499,
                  activeColor: SawaLoveTheme.primary,
                  inactiveColor: SawaLoveTheme.surfaceContainerHighest,
                  onChanged: (value) {
                    ref.read(preferencesProvider.notifier).setDistance(value);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChipRow({
    required List<_ChipOption> options,
    required Set<String> selected,
    required ValueChanged<String> onToggle,
    required bool disabled,
  }) {
    return Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: IgnorePointer(
        ignoring: disabled,
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((opt) {
            final isSelected = selected.contains(opt.value);
            return Semantics(
              label:
                  '${opt.label}. ${isSelected ? "Selected" : "Not selected"}. Double tap to toggle.',
              button: true,
              child: GestureDetector(
                onTap: () => onToggle(opt.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? SawaLoveTheme.primary
                        : SawaLoveTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? SawaLoveTheme.primary
                          : SawaLoveTheme.surfaceContainerHighest,
                    ),
                  ),
                  child: Text(
                    opt.label,
                    style: TextStyle(
                      color:
                          isSelected ? Colors.white : SawaLoveTheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDealbreakerTile({
    required String label,
    required String description,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    final bool active = value;
    return Opacity(
      opacity: onChanged == null ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: active
              ? SawaLoveTheme.errorColor.withValues(alpha: 0.06)
              : SawaLoveTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active
                ? SawaLoveTheme.errorColor.withValues(alpha: 0.3)
                : SawaLoveTheme.surfaceContainerHighest,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: active
                          ? SawaLoveTheme.errorColor
                          : SawaLoveTheme.onSurface,
                    ),
                  ),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: SawaLoveTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (active)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: SawaLoveTheme.errorColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700),
                ),
              ),
            Semantics(
              label:
                  '$label. ${active ? "Active — profiles matching this will be excluded" : "Inactive"}. Double tap to toggle.',
              toggled: active,
              child: Switch(
                value: active,
                onChanged: onChanged,
                activeThumbColor: SawaLoveTheme.errorColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoolCounter(PreferencesState prefs) {
    final count = prefs.estimatedPoolCount;
    final fraction = prefs.poolFraction;
    final isOpenToAll = prefs.openToAll;
    final suggestion = prefs.wideningSuggestion;

    Color barColor;
    if (isOpenToAll) {
      barColor = const Color(0xFF1D9E75);
    } else if (count < 100) {
      barColor = SawaLoveTheme.warning;
    } else {
      barColor = SawaLoveTheme.primary;
    }

    return Semantics(
      label: 'Estimated match pool: $count people. ${prefs.poolSubLabel}.',
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isOpenToAll
              ? const Color(0xFFE8F8EF)
              : count < 100
                  ? SawaLoveTheme.warningContainer
                  : SawaLoveTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOpenToAll
                ? const Color(0xFF1D9E75)
                : count < 100
                    ? SawaLoveTheme.warning
                    : SawaLoveTheme.surfaceContainerHighest,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: SawaLoveTheme.onSurface,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'people nearby / personnes à proximité',
                  style: TextStyle(
                    fontSize: 14,
                    color: SawaLoveTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: fraction,
                backgroundColor: SawaLoveTheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              prefs.poolSubLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isOpenToAll
                    ? const Color(0xFF1D9E75)
                    : count < 100
                        ? SawaLoveTheme.warning
                        : SawaLoveTheme.onSurfaceVariant,
              ),
            ),
            if (suggestion != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: SawaLoveTheme.warningContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb,
                        size: 18, color: SawaLoveTheme.warning),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        suggestion,
                        style: const TextStyle(
                          fontSize: 12,
                          color: SawaLoveTheme.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDemoMenu() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(title: Text('Demo States')),
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Default'),
                onTap: () {
                  ref
                      .read(preferencesProvider.notifier)
                      .applyDemoState('default');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.tune),
                title: const Text('Preferences Set'),
                onTap: () {
                  ref
                      .read(preferencesProvider.notifier)
                      .applyDemoState('preferences_set');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.block),
                title: const Text('Strict Filters'),
                onTap: () {
                  ref
                      .read(preferencesProvider.notifier)
                      .applyDemoState('strict');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.warning_amber),
                title: const Text('Deal-breakers'),
                onTap: () {
                  ref
                      .read(preferencesProvider.notifier)
                      .applyDemoState('dealbreakers');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.public),
                title: const Text('Open to All'),
                onTap: () {
                  ref
                      .read(preferencesProvider.notifier)
                      .applyDemoState('open_to_all');
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChipOption {
  final String value;
  final String label;
  const _ChipOption(this.value, this.label);
}
