import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final consentProvider = StateNotifierProvider<ConsentNotifier, ConsentState>((ref) {
  return ConsentNotifier();
});

enum ConsentType { personalised, analytics }

class ConsentState {
  final bool hasOpenedTos;
  final bool hasOpenedPP;
  final bool hasOpenedCookies;
  final bool personalised;
  final bool analytics;

  const ConsentState({
    this.hasOpenedTos = false,
    this.hasOpenedPP = false,
    this.hasOpenedCookies = false,
    this.personalised = false,
    this.analytics = false,
  });

  bool get isReadyToAccept => hasOpenedTos && hasOpenedPP;

  ConsentState copyWith({
    bool? hasOpenedTos,
    bool? hasOpenedPP,
    bool? hasOpenedCookies,
    bool? personalised,
    bool? analytics,
  }) {
    return ConsentState(
      hasOpenedTos: hasOpenedTos ?? this.hasOpenedTos,
      hasOpenedPP: hasOpenedPP ?? this.hasOpenedPP,
      hasOpenedCookies: hasOpenedCookies ?? this.hasOpenedCookies,
      personalised: personalised ?? this.personalised,
      analytics: analytics ?? this.analytics,
    );
  }
}

class ConsentNotifier extends StateNotifier<ConsentState> {
  ConsentNotifier() : super(const ConsentState());

  void openTos() => state = state.copyWith(hasOpenedTos: true);
  void openPrivacy() => state = state.copyWith(hasOpenedPP: true);
  void openCookies() => state = state.copyWith(hasOpenedCookies: true);

  void toggle(ConsentType type) {
    switch (type) {
      case ConsentType.personalised:
        state = state.copyWith(personalised: !state.personalised);
        break;
      case ConsentType.analytics:
        state = state.copyWith(analytics: !state.analytics);
        break;
    }
  }

  void submitConsent(BuildContext context) {
    if (!state.isReadyToAccept) return;
    context.go('/onboarding');
  }
}

class ConsentProvider extends ChangeNotifier {
  void toggle(ConsentType type) {}
}

