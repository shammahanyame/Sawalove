import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Core
import '../splash_screen.dart';
import '../language_selection_screen.dart';
import '../consent_screen.dart';
import '../offline_screen.dart';
import '../force_update_screen.dart';
import '../whats_new_screen.dart';
import '../refer_friends_screen.dart' as core_refer;
import '../reengagement_nudge_screen.dart';
import '../account_suspended_screen.dart';
import '../matches/match_success_screen.dart';

// Shared widgets
import '../../shared/widgets/glass_bottom_nav.dart';
import '../../shared/models/photo_slot.dart';

// Auth
import '../../features/auth/phone_login_screen.dart';
import '../../features/auth/otp_verification_screen.dart';
import '../../features/auth/email_signup_screen.dart';
import '../../features/auth/forgot_pin_screen.dart';
import '../../features/auth/reset_pin_screen.dart';
import '../../features/auth/terms_consent_screen.dart';

// Onboarding
import '../../features/onboarding/onboarding_flow.dart';
import '../../features/onboarding/photo_upload_screen.dart';
import '../../features/onboarding/preferences_screen.dart';
import '../../features/onboarding/photo_verification_screen.dart';
import '../../features/onboarding/bio_screen.dart';
import '../../features/onboarding/ethnicity_screen.dart';
import '../../features/onboarding/intent_picker_screen.dart';
import '../../features/onboarding/permissions_screen.dart';
import '../../features/onboarding/relationship_intent_screen.dart';
import '../../features/onboarding/religion_screen.dart';

// Discovery
import '../../features/discovery/discovery_screen.dart';
import '../../features/discovery/empty_discovery_screen.dart';
import '../../features/discovery/filters_screen.dart';
import '../../features/discovery/super_like_confirm_screen.dart';
import '../../features/discovery/undo_screen.dart';

// Explore
import '../../features/explore/explore_screen.dart';

// Matches
import '../../features/matches/likes_matches_screen.dart';

// Chat
import '../../features/chat/chat_list_screen.dart';
import '../../features/chat/chat_detail_screen.dart';
import '../../features/chat/incoming_call_screen.dart'
    hide DeclinedCallScreen, BusyUnavailableScreen;
import '../../features/chat/video_call_screen.dart';
import '../../features/chat/declined_call_screen.dart';
import '../../features/chat/busy_unavailable_screen.dart';
import '../../features/chat/ice_breakers_screen.dart';
import '../../features/chat/gif_sticker_picker.dart';
import '../../features/chat/chat_request_screen.dart';
import '../../features/chat/request_compose_screen.dart';
import '../../features/chat/decline_confirm_screen.dart';
import '../../features/chat/undo_decline_screen.dart';
import '../../features/chat/unmatch_confirmation_screen.dart';

// Profile
import '../../features/profile/self_profile_screen.dart';
import '../../features/profile/peer_profile_screen.dart';
import '../../features/profile/edit_profile_screen.dart';
import '../../features/profile/photo_viewer_screen.dart';
import '../../features/profile/completeness_screen.dart';
import '../../features/profile/notification_settings_screen.dart';
import '../../features/profile/notification_center_screen.dart';
import '../../features/profile/privacy_settings_screen.dart';
import '../../features/profile/blocked_users_screen.dart';
import '../../features/profile/account_pause_delete_screen.dart';
import '../../features/profile/language_region_screen.dart';
import '../../features/profile/dark_mode_display_screen.dart';
import '../../features/profile/linked_accounts_screen.dart';
import '../../features/profile/feedback_rating_screen.dart';
import '../../features/profile/help_faq_screen.dart';
import '../../features/profile/contact_support_screen.dart';
import '../../features/profile/geo_tag_status_screen.dart';
import '../../features/profile/refer_friends_screen.dart' as profile_refer;
import '../../features/profile/document_pages.dart';

// Premium
import '../../features/premium/premium_checkout_screen.dart';
import '../../features/premium/plans_screen.dart';
import '../../features/premium/feature_gate_screen.dart';
import '../../features/premium/payment_processing_screen.dart';
import '../../features/premium/payment_failed_screen.dart';
import '../../features/premium/purchase_history_screen.dart';
import '../../features/premium/boost_success_screen.dart';
import '../../features/premium/boost_timer_screen.dart';

// Safety
import '../../features/safety/safety_center_screen.dart';
import '../../features/safety/report_user_screen.dart';
import '../../features/safety/emergency_sos_screen.dart';
import '../../features/safety/id_verification_screen.dart';
import '../../features/safety/moderation_appeal_screen.dart';

// Location
import '../../features/location/nearby_map_screen.dart';
import '../../features/location/location_rationale_screen.dart';
import '../../features/location/meetup_place_picker_screen.dart';
import '../../features/location/traveling_banner_screen.dart';

// Social
import '../../features/social/local_events_news_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    routes: [
      // ── Splash ──────────────────────────────────────────────────────────
      GoRoute(path: '/splash', builder: (c, s) => const SplashScreen()),

      // ── Language ────────────────────────────────────────────────────────
      GoRoute(
          path: '/language-select',
          builder: (c, s) => const LanguageSelectionScreen()),

      // ── Auth ────────────────────────────────────────────────────────────
      GoRoute(path: '/login', builder: (c, s) => const PhoneLoginScreen()),
      GoRoute(
          path: '/login/otp',
          builder: (c, s) => OTPVerificationScreen(phone: s.extra as String?)),
      GoRoute(
          path: '/login/email', builder: (c, s) => const EmailSignupScreen()),
      GoRoute(
          path: '/login/email/verify',
          builder: (c, s) => const EmailVerificationScreen()),
      GoRoute(
          path: '/login/add-phone', builder: (c, s) => const AddPhoneScreen()),
      GoRoute(
          path: '/auth/google', builder: (c, s) => const TermsConsentScreen()),
      GoRoute(
          path: '/login/forgot-pin',
          builder: (c, s) => const ForgotPinScreen()),
      GoRoute(
          path: '/login/reset-pin',
          builder: (c, s) => const ResetPinFlowScreen()),
      GoRoute(
          path: '/login/terms', builder: (c, s) => const TermsConsentScreen()),
      GoRoute(path: '/consent', builder: (c, s) => const ConsentScreen()),

      // ── Onboarding ──────────────────────────────────────────────────────
      GoRoute(
        path: '/onboarding',
        builder: (c, s) => const OnboardingFlow(),
        routes: [
          GoRoute(path: 'photos', builder: (c, s) => const PhotoUploadScreen()),
          GoRoute(
              path: 'verification',
              builder: (c, s) => const PhotoVerificationScreen()),
          GoRoute(
              path: 'preferences',
              builder: (c, s) => const PreferencesScreen()),
          GoRoute(path: 'bio', builder: (c, s) => const BioScreen()),
          GoRoute(
              path: 'ethnicity', builder: (c, s) => const EthnicityScreen()),
          GoRoute(
              path: 'intent', builder: (c, s) => const IntentPickerScreen()),
          GoRoute(
              path: 'relationship-intent',
              builder: (c, s) => const RelationshipIntentScreen()),
          GoRoute(path: 'religion', builder: (c, s) => const ReligionScreen()),
          GoRoute(
              path: 'permissions',
              builder: (c, s) => const PermissionsScreen()),
          GoRoute(
              path: 'finalize', builder: (c, s) => const PermissionsScreen()),
          GoRoute(path: 'next', builder: (c, s) => const PhotoUploadScreen()),
        ],
      ),

      // ── Main Shell ──────────────────────────────────────────────────────
      ShellRoute(
        builder: (c, s, child) => ScaffoldWithBottomNav(child: child),
        routes: [
          GoRoute(
              path: '/home/discover',
              builder: (c, s) => const DiscoveryScreen()),
          GoRoute(
              path: '/home/explore', builder: (c, s) => const ExploreScreen()),
          GoRoute(
              path: '/home/matches',
              builder: (c, s) => const LikesMatchesScreen()),
          GoRoute(
              path: '/home/chat', builder: (c, s) => const ChatListScreen()),
          GoRoute(
              path: '/home/profile',
              builder: (c, s) => const SelfProfileScreen()),
        ],
      ),

      // ── Discovery extras ────────────────────────────────────────────────
      GoRoute(
          path: '/discover/empty',
          builder: (c, s) => const EmptyDiscoveryScreen()),
      GoRoute(
          path: '/discover/filters', builder: (c, s) => const FiltersScreen()),
      GoRoute(
          path: '/discover/super-like',
          builder: (c, s) => const SuperLikeConfirmScreen()),
      GoRoute(path: '/discover/undo', builder: (c, s) => const UndoScreen()),
      GoRoute(path: '/discover', builder: (c, s) => const DiscoveryScreen()),
      GoRoute(path: '/discovery', builder: (c, s) => const DiscoveryScreen()),
      GoRoute(path: '/filters', builder: (c, s) => const FiltersScreen()),
      GoRoute(
          path: '/notifications',
          builder: (c, s) => const NotificationCenterScreen()),

      // ── Match ───────────────────────────────────────────────────────────
      GoRoute(
        path: '/match/:matchId',
        builder: (c, s) =>
            MatchSuccessScreen(matchId: s.pathParameters['matchId']!),
      ),

      // ── Chat ────────────────────────────────────────────────────────────
      GoRoute(
        path: '/chat/:matchId',
        builder: (c, s) =>
            ChatDetailScreen(matchId: s.pathParameters['matchId']!),
      ),
      GoRoute(
        path: '/chat/:matchId/voice-message',
        builder: (c, s) =>
            ChatDetailScreen(matchId: s.pathParameters['matchId']!),
      ),
      GoRoute(
          path: '/chat-request', builder: (c, s) => const ChatRequestScreen()),
      GoRoute(path: '/chat', builder: (c, s) => const ChatListScreen()),
      GoRoute(
          path: '/request/compose/:uid',
          builder: (c, s) =>
              RequestComposeScreen(recipientUid: s.pathParameters['uid']!)),
      GoRoute(
          path: '/request/decline-confirm/:requestId',
          builder: (c, s) =>
              DeclineConfirmScreen(requestId: s.pathParameters['requestId']!)),
      GoRoute(
          path: '/request/undo/:requestId',
          builder: (c, s) =>
              UndoDeclineScreen(requestId: s.pathParameters['requestId']!)),
      // Peer name is optional untrusted display input; the screen clamps it.
      GoRoute(
          path: '/ice-breakers',
          builder: (c, s) => IceBreakersScreen(
              participantName: s.uri.queryParameters['name'])),
      GoRoute(
          path: '/gif-sticker', builder: (c, s) => const GifStickerPicker()),
      GoRoute(
          path: '/unmatch',
          builder: (c, s) => const UnmatchConfirmationScreen()),

      // ── Calls ───────────────────────────────────────────────────────────
      GoRoute(
          path: '/call/incoming',
          builder: (c, s) => const IncomingCallScreen()),
      GoRoute(path: '/call/video', builder: (c, s) => const VideoCallScreen()),
      GoRoute(
          path: '/chat/video-call', builder: (c, s) => const VideoCallScreen()),
      GoRoute(
        path: '/call/declined',
        builder: (c, s) => DeclinedCallScreen(
          callerName: s.uri.queryParameters['callerName'] ?? 'Someone',
        ),
      ),
      GoRoute(
        path: '/chat/call-declined',
        builder: (c, s) => DeclinedCallScreen(
          callerName: s.uri.queryParameters['callerName'] ?? 'Someone',
        ),
      ),
      GoRoute(
        path: '/call/busy',
        builder: (c, s) => BusyUnavailableScreen(
          recipientName: s.uri.queryParameters['recipientName'] ?? 'Someone',
          isOnAnotherCall: s.uri.queryParameters['isOnAnotherCall'] == 'true',
          hasDoNotDisturb: s.uri.queryParameters['hasDnd'] == 'true',
        ),
      ),
      GoRoute(
        path: '/chat/call-busy',
        builder: (c, s) => BusyUnavailableScreen(
          recipientName: s.uri.queryParameters['recipientName'] ?? 'Someone',
          isOnAnotherCall: s.uri.queryParameters['isOnAnotherCall'] == 'true',
          hasDoNotDisturb: s.uri.queryParameters['hasDnd'] == 'true',
        ),
      ),

      // ── Profile settings (specific routes BEFORE parameterised :uid) ────
      GoRoute(
          path: '/profile/edit', builder: (c, s) => const EditProfileScreen()),
      GoRoute(
        path: '/profile/photos',
        builder: (c, s) {
          final extra = s.extra as Map<String, dynamic>?;
          if (extra != null) {
            return PhotoViewerScreen(
              profileUid: extra['profileUid'] as String? ?? 'me',
              photos: (extra['photos'] as List<PhotoSlot>?) ?? const [],
              name: extra['name'] as String? ?? '',
              initialIndex: extra['initialIndex'] as int? ?? 0,
              age: extra['age'] as int?,
              city: extra['city'] as String?,
              badges: extra['badges'] as List<String>?,
            );
          }
          return const SelfProfileScreen();
        },
      ),
      GoRoute(
          path: '/profile/completeness',
          builder: (c, s) => const ProfileCompletenessScreen()),
      GoRoute(
          path: '/profile/complete',
          builder: (c, s) => const ProfileCompletenessScreen()),
      GoRoute(
          path: '/profile/notification-settings',
          builder: (c, s) => const NotificationSettingsScreen()),
      GoRoute(
          path: '/profile/notification-center',
          builder: (c, s) => const NotificationCenterScreen()),
      GoRoute(
          path: '/profile/privacy',
          builder: (c, s) => const PrivacySettingsScreen()),
      GoRoute(
          path: '/profile/privacy-policy',
          builder: (c, s) => const PrivacyPolicyPage()),
      GoRoute(
          path: '/profile/terms',
          builder: (c, s) => const TermsOfServicePage()),

      GoRoute(
          path: '/profile/blocked',
          builder: (c, s) => const BlockedUsersScreen()),
      GoRoute(
          path: '/profile/account',
          builder: (c, s) => const AccountPauseDeleteScreen()),
      GoRoute(
          path: '/profile/language',
          builder: (c, s) => const LanguageRegionScreen()),
      GoRoute(
          path: '/profile/display',
          builder: (c, s) => const DarkModeDisplayScreen()),
      GoRoute(
          path: '/profile/linked-accounts',
          builder: (c, s) => const LinkedAccountsScreen()),
      GoRoute(
          path: '/profile/feedback',
          builder: (c, s) => const FeedbackRatingScreen()),
      GoRoute(
          path: '/profile/help-faq', builder: (c, s) => const HelpFaqScreen()),
      GoRoute(
          path: '/profile/contact-support',
          builder: (c, s) => const ContactSupportScreen()),
      GoRoute(
          path: '/profile/geo-tag',
          builder: (c, s) => const GeoTagStatusScreen()),
      GoRoute(
          path: '/profile/refer-friends',
          builder: (c, s) => const profile_refer.ReferFriendsScreen()),

      // ── Peer profile (parameterised – AFTER specific /profile/* routes) ─
      GoRoute(
        path: '/profile/:uid',
        builder: (c, s) => PeerProfileScreen(uid: s.pathParameters['uid']!),
        routes: [
          GoRoute(
            path: 'report',
            builder: (c, s) => ReportUserScreen(
              profileUid: s.pathParameters['uid'],
              initialReason: s.uri.queryParameters['reason'],
              photoUrl: s.uri.queryParameters['photoUrl'],
            ),
          ),
        ],
      ),

      // ── Premium ─────────────────────────────────────────────────────────
      GoRoute(
          path: '/premium', builder: (c, s) => const PremiumCheckoutScreen()),
      GoRoute(
          path: '/premium/boost', builder: (c, s) => const BoostTimerScreen()),
      GoRoute(path: '/premium/plans', builder: (c, s) => const PlansScreen()),
      GoRoute(
          path: '/premium/gate', builder: (c, s) => const FeatureGateScreen()),
      GoRoute(
          path: '/premium/payment',
          builder: (c, s) => const PaymentProcessingScreen()),
      GoRoute(
          path: '/premium/failed',
          builder: (c, s) => const PaymentFailedScreen()),
      GoRoute(
          path: '/premium/history',
          builder: (c, s) => const PurchaseHistoryScreen()),
      GoRoute(
          path: '/premium/success',
          builder: (c, s) => const BoostSuccessScreen()),
      GoRoute(
          path: '/premium/boost-timer',
          builder: (c, s) => const BoostTimerScreen()),

      // ── Safety ──────────────────────────────────────────────────────────
      GoRoute(path: '/safety', builder: (c, s) => const SafetyCenterScreen()),
      GoRoute(
          path: '/safety/sos', builder: (c, s) => const EmergencySosScreen()),
      GoRoute(
          path: '/safety/contacts',
          builder: (c, s) => const EmergencySosScreen()),
      GoRoute(
        path: '/safety/report/:uid',
        builder: (c, s) => ReportUserScreen(
          profileUid: s.pathParameters['uid'],
          initialReason: s.uri.queryParameters['reason'],
          photoUrl: s.uri.queryParameters['photoUrl'],
        ),
      ),
      GoRoute(
          path: '/safety/block/:uid',
          builder: (c, s) => const BlockedUsersScreen()),
      GoRoute(
          path: '/safety/id-verification',
          builder: (c, s) => const IdVerificationScreen()),
      GoRoute(
          path: '/safety/moderation-appeal',
          builder: (c, s) => const ModerationAppealScreen()),

      // ── Location ────────────────────────────────────────────────────────
      GoRoute(
          path: '/location/nearby', builder: (c, s) => const NearbyMapScreen()),
      GoRoute(
          path: '/location/rationale',
          builder: (c, s) => const LocationRationaleScreen()),
      GoRoute(
          path: '/location-manual',
          builder: (c, s) => const LocationRationaleScreen()),
      GoRoute(
          path: '/location/meetup',
          builder: (c, s) => const MeetupPlacePickerScreen(matchName: 'Amaka')),
      GoRoute(
          path: '/location/traveling',
          builder: (c, s) => const TravelingBannerScreen()),

      // ── Social ──────────────────────────────────────────────────────────
      GoRoute(
          path: '/social/events',
          builder: (c, s) => const LocalEventsNewsScreen()),

      // ── System states ───────────────────────────────────────────────────
      GoRoute(path: '/offline', builder: (c, s) => const OfflineScreen()),
      GoRoute(path: '/', builder: (c, s) => const SplashScreen()),
      GoRoute(path: '/home', builder: (c, s) => const DiscoveryScreen()),
      GoRoute(path: '/explore', builder: (c, s) => const ExploreScreen()),
      GoRoute(path: '/matches', builder: (c, s) => const LikesMatchesScreen()),
      GoRoute(
          path: '/force-update', builder: (c, s) => const ForceUpdateScreen()),
      GoRoute(path: '/whats-new', builder: (c, s) => const WhatsNewScreen()),
      GoRoute(
          path: '/refer',
          builder: (c, s) => const core_refer.ReferFriendsScreen()),
      GoRoute(
          path: '/reengagement',
          builder: (c, s) => const ReengagementNudgeScreen()),
      GoRoute(
          path: '/account-suspended',
          builder: (c, s) => const AccountSuspendedScreen()),
    ],
  );
});

// ── Bottom-nav shell ────────────────────────────────────────────────────────

class ScaffoldWithBottomNav extends ConsumerWidget {
  final Widget child;
  const ScaffoldWithBottomNav({super.key, required this.child});

  static const _tabs = [
    '/home/discover',
    '/home/explore',
    '/home/matches',
    '/home/chat',
    '/home/profile',
  ];

  int _currentIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    for (int i = 0; i < _tabs.length; i++) {
      if (loc.startsWith(_tabs[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      bottomNavigationBar: GlassBottomNav(
        currentIndex: _currentIndex(context),
        onTap: (i) {
          if (i >= 0 && i < _tabs.length) context.go(_tabs[i]);
        },
      ),
    );
  }
}
