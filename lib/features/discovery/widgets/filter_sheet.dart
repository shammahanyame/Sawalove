// lib/features/discovery/widgets/filter_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sawalove/core/theme/theme.dart';
import 'package:sawalove/shared/providers/filter_provider.dart';
import 'filter_pill_chip.dart';
import 'pool_counter_card.dart';
import 'reset_modal.dart';

/// The main Filter and Preferences bottom sheet.
/// - DraggableScrollableSheet with 3 snap points (0.55, 0.85, 1.0)
/// - Sticky header with back arrow and Reset all button
/// - Live pool counter that updates on every filter change
/// - 7 filter sections with section dot indicators
/// - Active filter pills summary row
/// - Save preset feature (Premium)
/// - Reset confirmation modal
class FilterSheet extends ConsumerStatefulWidget {
  final ScrollController scrollController;

  const FilterSheet({
    super.key,
    required this.scrollController,
  });

  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  late FilterState savedFilters;
  late ScrollController _sheetScrollController;

  @override
  void initState() {
    super.initState();
    _sheetScrollController = widget.scrollController;
    savedFilters = ref.read(filterProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(filterProvider.notifier).saveSnapshot();
    });
  }

  void _onApply(BuildContext context) {
    ref.read(filterProvider.notifier).setApplied(true);
    Navigator.of(context).pop();
  }

  void _onDismiss(BuildContext context) {
    ref.read(filterProvider.notifier).restore(savedFilters);
    Navigator.of(context).pop();
  }

  void _onReset() {
    ResetConfirmModal.show(
      context: context,
      activeFilterCount: ref.read(filterProvider).activeFilterCount,
      onConfirmReset: () {
        ref.read(filterProvider.notifier).clearAll();
        Navigator.of(context).pop(); // Close modal
      },
    );
  }

  void _removeFilter(String filterKey) {
    ref.read(filterProvider.notifier).removeFilter(filterKey);
  }

  Widget _buildSectionDot(bool isActive) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? SawaLoveTheme.primary : Colors.transparent,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildChipSection({
    required String title,
    required List<String> options,
    required Set<String> selected,
    required Color selectedColor,
    required void Function(String) onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildSectionDot(selected.isNotEmpty),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((option) {
            final isSelected = selected.contains(option);
            return Semantics(
              label:
                  '$option. ${isSelected ? "Selected" : "Not selected"}. Double tap to toggle.',
              button: true,
              child: GestureDetector(
                onTap: () => onToggle(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? selectedColor
                        : SawaLoveTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? selectedColor
                          : SawaLoveTheme.outlineVariant,
                    ),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      color:
                          isSelected ? Colors.white : SawaLoveTheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSliderSection({
    required String title,
    required String currentValue,
    required Widget slider,
    bool isActive = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildSectionDot(isActive),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SawaLoveTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: SawaLoveTheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  currentValue,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              slider,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleCard({
    required String label,
    required String description,
    required bool value,
    required void Function(bool)? onChanged,
  }) {
    return Opacity(
      opacity: onChanged == null ? 0.5 : 1.0,
      child: IgnorePointer(
        ignoring: onChanged == null,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SawaLoveTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: SawaLoveTheme.outlineVariant),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      description,
                      style: const TextStyle(
                        color: SawaLoveTheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Semantics(
                label: '$label. ${value ? "On" : "Off"}. Double tap to toggle.',
                toggled: value,
                child: Switch(
                  value: value,
                  onChanged: onChanged,
                  activeThumbColor: SawaLoveTheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final filterState = ref.watch(filterProvider);
        final poolCount = filterState.estimatedPoolCount;
        final pills = filterState.activePills;
        final isWarning = poolCount < 80;

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Stack(
            children: [
              CustomScrollView(
                controller: _sheetScrollController,
                slivers: [
                  // Sticky header
                  SliverPersistentHeader(
                    delegate: _StickyHeaderDelegate(
                      isWarning: isWarning,
                      activeFilterCount: pills.length,
                      onDismiss: () => _onDismiss(context),
                      onReset: _onReset,
                    ),
                    pinned: true,
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Preset row (Premium only)
                          if (filterState.presets.isNotEmpty)
                            Container(
                              height: 44,
                              margin: const EdgeInsets.only(bottom: 20),
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: filterState.presets.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 10),
                                itemBuilder: (context, index) {
                                  final preset = filterState.presets[index];
                                  return GestureDetector(
                                    onTap: () => ref
                                        .read(filterProvider.notifier)
                                        .loadPreset(preset),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: SawaLoveTheme.tertiary
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: SawaLoveTheme.tertiary
                                              .withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Text(
                                        preset.name,
                                        style: const TextStyle(
                                          color: SawaLoveTheme.tertiary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                          // Pool counter - always visible
                          PoolCounterCard(
                            count: poolCount,
                            fraction: filterState.poolFraction,
                            subLabel: filterState.poolSubLabel,
                            warningMessage: filterState.wideningSuggestion,
                            showWarningBanner: isWarning,
                          ),
                          const SizedBox(height: 24),

                          // Active filter pills summary row
                          if (pills.isNotEmpty)
                            Container(
                              height: 44,
                              margin: const EdgeInsets.only(bottom: 20),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: pills
                                      .map((pill) => Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10),
                                            child: FilterPillChip(
                                              label: pill.label,
                                              filterKey: pill.key,
                                              onRemove: () =>
                                                  _removeFilter(pill.key),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ),
                            ),

                          // Age range section
                          _buildSliderSection(
                            title: 'Age range',
                            currentValue: filterState.ageRangeLabel,
                            slider: Semantics(
                              label:
                                  'Age range: ${filterState.ageMin} to ${filterState.ageMax}. Left thumb minimum, right thumb maximum.',
                              child: RangeSlider(
                                values: RangeValues(
                                    filterState.ageMin.toDouble(),
                                    filterState.ageMax.toDouble()),
                                min: 18,
                                max: 60,
                                divisions: 42,
                                activeColor: SawaLoveTheme.primary,
                                inactiveColor: SawaLoveTheme.outlineVariant,
                                onChanged: (values) {
                                  ref.read(filterProvider.notifier).setAgeRange(
                                        values.start.toInt(),
                                        values.end.toInt(),
                                      );
                                },
                              ),
                            ),
                            isActive: filterState.ageMin != 22 ||
                                filterState.ageMax != 35,
                          ),
                          const SizedBox(height: 24),

                          // Distance section
                          _buildSliderSection(
                            title: 'Distance',
                            currentValue: filterState.distanceLabel,
                            slider: Semantics(
                              label:
                                  'Distance: ${filterState.distanceKm.toInt()} km. Drag to adjust.',
                              child: Slider(
                                value: filterState.distanceKm,
                                min: 1,
                                max: 500,
                                divisions: 499,
                                activeColor: SawaLoveTheme.primary,
                                inactiveColor: SawaLoveTheme.outlineVariant,
                                onChanged: (value) {
                                  ref
                                      .read(filterProvider.notifier)
                                      .setDistance(value);
                                },
                              ),
                            ),
                            isActive: filterState.distanceKm != 25,
                          ),
                          const SizedBox(height: 24),

                          // Interested in chips (genders)
                          _buildChipSection(
                            title: 'Interested in',
                            options: const [
                              'women',
                              'men',
                              'nonbinary',
                              'everyone'
                            ],
                            selected: filterState.genders,
                            selectedColor: SawaLoveTheme.primary,
                            onToggle:
                                ref.read(filterProvider.notifier).toggleGender,
                          ),
                          const SizedBox(height: 24),

                          // Looking for chips (intents)
                          _buildChipSection(
                            title: 'Looking for',
                            options: const [
                              'serious',
                              'casual',
                              'friendship',
                              'networking',
                              'marriage'
                            ],
                            selected: filterState.intents,
                            selectedColor: SawaLoveTheme.primary,
                            onToggle:
                                ref.read(filterProvider.notifier).toggleIntent,
                          ),
                          const SizedBox(height: 24),

                          // Faith chips (purple)
                          _buildChipSection(
                            title: 'Faith',
                            options: const [
                              'christian',
                              'muslim',
                              'traditional',
                              'none',
                              'any_faith'
                            ],
                            selected: filterState.faiths,
                            selectedColor: const Color(0xFF8329C8),
                            onToggle:
                                ref.read(filterProvider.notifier).toggleFaith,
                          ),
                          const SizedBox(height: 24),

                          // Region chips (teal)
                          _buildChipSection(
                            title: 'Region',
                            options: const [
                              'Douala',
                              'Yaoundé',
                              'Bafoussam',
                              'Bamenda',
                              'Garoua',
                              'Maroua',
                              'Diaspora',
                            ],
                            selected: filterState.regions,
                            selectedColor: SawaLoveTheme.tertiary,
                            onToggle:
                                ref.read(filterProvider.notifier).toggleRegion,
                          ),
                          const SizedBox(height: 24),

                          // Lifestyle chips
                          _buildChipSection(
                            title: 'Lifestyle',
                            options: const [
                              'Non-smoker',
                              'No children',
                              'Verified only',
                              'Active this week',
                            ],
                            selected: filterState.lifestyles,
                            selectedColor: SawaLoveTheme.primary,
                            onToggle: ref
                                .read(filterProvider.notifier)
                                .toggleLifestyle,
                          ),
                          const SizedBox(height: 24),

                          // Online now toggle card
                          _buildToggleCard(
                            label: 'Online now',
                            description:
                                'Users active in the last 15 minutes (very narrow)',
                            value: filterState.onlineNow,
                            onChanged:
                                ref.read(filterProvider.notifier).setOnlineNow,
                          ),
                          const SizedBox(height: 16),

                          // Has photo toggle card
                          _buildToggleCard(
                            label: 'Has profile photo',
                            description:
                                'Exclude profiles with no photos (default: on)',
                            value: filterState.withPhoto,
                            onChanged:
                                ref.read(filterProvider.notifier).setWithPhoto,
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Bottom CTA buttons
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Semantics(
                  label:
                      'Apply ${filterState.activeFilterCount} filters. $poolCount people will appear in your feed.',
                  button: true,
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Save preset button (Premium only)
                        if (filterState.isPremium)
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: OutlinedButton(
                              onPressed: () {
                                // TODO: Show preset naming bottom sheet
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Save preset'),
                                    content: TextField(
                                      decoration: const InputDecoration(
                                        hintText: 'Preset name...',
                                        border: OutlineInputBorder(),
                                      ),
                                      onSubmitted: (name) {
                                        ref
                                            .read(filterProvider.notifier)
                                            .savePreset(name);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text('Cancel'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              child: const Text(
                                'Save preset',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: SawaLoveTheme.primary,
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 12),

                        // Apply filters button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () => _onApply(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: SawaLoveTheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            child: Text(
                              '${filterState.hasActiveFilters ? "Apply" : "Close"} filters',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Sticky header delegate for the filter sheet
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final bool isWarning;
  final int activeFilterCount;
  final VoidCallback onDismiss;
  final VoidCallback onReset;

  const _StickyHeaderDelegate({
    required this.isWarning,
    required this.activeFilterCount,
    required this.onDismiss,
    required this.onReset,
  });

  @override
  double get minExtent => 70;
  @override
  double get maxExtent => 70;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      height: maxExtent,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Back arrow
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: onDismiss,
            ),
            // Title
            Expanded(
              child: Text(
                'Filters & Preferences',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            // Reset button
            Semantics(
              label:
                  'Reset all filters. ${activeFilterCount > 0 ? "$activeFilterCount filters will be cleared." : "No active filters."}',
              button: true,
              child: GestureDetector(
                onTap: activeFilterCount > 0 ? onReset : null,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: activeFilterCount > 0
                        ? SawaLoveTheme.errorColor.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: activeFilterCount > 0
                        ? Border.all(
                            color:
                                SawaLoveTheme.errorColor.withValues(alpha: 0.3))
                        : Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'Reset all',
                    style: TextStyle(
                      color: activeFilterCount > 0
                          ? SawaLoveTheme.errorColor
                          : Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

void showFilterSheet(BuildContext context, WidgetRef ref) {
  final savedFilters = ref.read(filterProvider);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.55,
      maxChildSize: 1.0,
      snap: true,
      snapSizes: const [0.55, 0.85, 1.0],
      builder: (_, controller) => FilterSheet(scrollController: controller),
    ),
  ).then((_) {
    // Sheet dismissed without Apply
    if (!ref.read(filterProvider.notifier).wasApplied) {
      ref.read(filterProvider.notifier).restore(savedFilters);
    }
  });
}
