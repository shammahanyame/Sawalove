// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SawaLove';

  @override
  String get phoneLoginTitle => 'Phone Login';

  @override
  String get enterPhone => 'Enter your phone number';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get languageToggle => 'Français';

  @override
  String get moderationAppealTitle => 'Moderation Appeal';

  @override
  String get moderationAppealPrevious => 'Previous Appeals';

  @override
  String get moderationAppealNew => 'New Appeal';

  @override
  String get moderationAppealReason => 'Reason for ban/flag';

  @override
  String get moderationAppealExplanation =>
      'Explain why you believe this was a mistake';

  @override
  String get moderationAppealPhoto => 'Add photo evidence';

  @override
  String get moderationAppealSubmit => 'Submit Appeal';

  @override
  String get discoveryTitle => 'Discovery';

  @override
  String get exploreTitle => 'Explore';

  @override
  String get matchesTitle => 'Matches';

  @override
  String get chatTitle => 'Chats';

  @override
  String get profileTitle => 'Profile';

  @override
  String get login => 'Login';

  @override
  String get signup => 'Signup';

  @override
  String get otp => 'OTP Code';

  @override
  String get settings => 'Settings';

  @override
  String get premium => 'Premium';

  @override
  String get safety => 'Safety';

  @override
  String get home => 'Home';

  @override
  String get village => 'Village';

  @override
  String get intentSerious => 'Serious relationship';

  @override
  String get intentMarriage => 'Marriage';

  @override
  String get verified => 'Verified';

  @override
  String get online => 'Online';

  @override
  String get kmAway => 'km away';

  @override
  String get photoUploadTitle => 'Add Your Photos';

  @override
  String get photoUploadSubtitle => 'Min 2 photos, clear face required';

  @override
  String get addPhoto => 'Add photo';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get instagram => 'Instagram';

  @override
  String get faceDetected => 'Face detected';

  @override
  String get faceChecking => 'Checking…';

  @override
  String get noFaceFound => 'No face found';

  @override
  String get replacePhoto => 'Replace photo';

  @override
  String progressMin(Object count) {
    return '$count / 2 min';
  }

  @override
  String progressMax(Object count) {
    return '$count / 6 max';
  }

  @override
  String addMoreToContinue(Object count) {
    return 'Add $count more to continue';
  }

  @override
  String get tipCardMessage => 'Tip: Profiles with 4+ photos get 3× more likes';

  @override
  String get celebratoryMessage => 'Perfect! Your photos are ready';

  @override
  String get reorderInstruction =>
      'Drag photos to reorder. The large slot is your main photo.';

  @override
  String get newMainPhotoSet => 'New main photo set';

  @override
  String get done => 'Done';

  @override
  String get continueToPreferences => 'Continue to Preferences';

  @override
  String get faceNotDetected => 'Face not detected';

  @override
  String get faceNotDetectedDesc =>
      'Please upload a photo where your face is clearly visible.';

  @override
  String get reorderPhotos => 'Reorder Photos';

  @override
  String get longPressToDrag => 'Long press to drag and reorder.';

  @override
  String get preferencesTitle => 'Who are you looking for?';

  @override
  String get preferencesSubtitle => 'Tune your match pool';

  @override
  String get ageRange => 'Age Range';

  @override
  String get distance => 'Distance';

  @override
  String get gender => 'Gender';

  @override
  String get intent => 'Relationship Intent';

  @override
  String get religion => 'Religion';

  @override
  String get dealbreakers => 'Deal-breakers';

  @override
  String get showMeEveryone => 'Show me everyone';

  @override
  String get showMeEveryoneDesc => 'Ignore all filters above';

  @override
  String get hasChildren => 'Has children';

  @override
  String get hasChildrenDesc => 'Exclude profiles with children';

  @override
  String get smokes => 'Smokes';

  @override
  String get smokesDesc => 'Exclude smokers';

  @override
  String get onlyVerified => 'Only photo-verified';

  @override
  String get onlyVerifiedDesc => 'Show only verified users';

  @override
  String get discoverMatches => 'Discover Matches';

  @override
  String get peopleNearby => 'people nearby';

  @override
  String get goodRange => 'Good range';

  @override
  String get narrowPool => 'Narrow pool';

  @override
  String get veryNarrowPool => 'Very narrow pool';

  @override
  String get allUsersShown => 'All users shown';

  @override
  String get reportUserTitle => 'Report User';

  @override
  String get photoViewerCloseSemantics =>
      'Close photo viewer, return to profile.';

  @override
  String photoViewerPhotoSemantics(Object index, Object caption) {
    return 'Photo $index: $caption. Double tap to like.';
  }

  @override
  String photoViewerDotsSemantics(Object current, Object total) {
    return 'Photo navigation dots. Currently viewing photo $current of $total.';
  }

  @override
  String get photoViewerThumbnailsSemantics =>
      'Photo thumbnails. Tap a thumbnail to navigate.';

  @override
  String get photoViewerReportSemantics => 'Report this photo.';

  @override
  String get photoViewerPinchHint => 'Pinch to zoom';

  @override
  String get photoViewerLinkCopied => 'Profile link copied · Lien copié.';

  @override
  String get photoViewerAlreadyLiked => 'Already liked · Déjà aimé';

  @override
  String get photoViewerUndo => 'Undo';

  @override
  String get reportReasonInappropriate => 'Inappropriate content';

  @override
  String get reportReasonSpam => 'Spam or fake profile';

  @override
  String get reportReasonHarassment => 'Harassment';

  @override
  String get reportReasonUnderage => 'Underage';

  @override
  String get reportReasonOther => 'Other';

  @override
  String get videoCallConnecting => 'Connecting…';

  @override
  String get videoCallActive => 'Connected';

  @override
  String get videoCallMuted => 'Muted';

  @override
  String get videoCallCameraOff => 'Camera off';

  @override
  String get videoCallPoorConnection => 'Poor connection';

  @override
  String get videoCallReconnecting => 'Reconnecting…';

  @override
  String get videoCallEnded => 'Call ended';

  @override
  String get videoCallCancel => 'Cancel call';

  @override
  String get videoCallEndCall => 'End call';

  @override
  String get videoCallAccept => 'Accept';

  @override
  String get videoCallDecline => 'Decline';

  @override
  String videoCallIncoming(Object name) {
    return 'Incoming video call from $name';
  }

  @override
  String videoCallNoAnswer(Object name) {
    return '$name didn\'t answer';
  }

  @override
  String get videoCallFailed => 'Failed to connect';

  @override
  String get videoCallRetry => 'Retry';

  @override
  String get videoCallDuration => 'Duration';

  @override
  String get videoCallQuality => 'Quality';

  @override
  String get videoCallLatency => 'Latency';

  @override
  String get videoCallRatethis => 'Rate this call';

  @override
  String get videoCallExcellent => 'Excellent';

  @override
  String get videoCallGood => 'Good';

  @override
  String videoCallMessage(Object name) {
    return 'Message $name';
  }

  @override
  String get videoCallBacktoDiscover => 'Back to discover';

  @override
  String get videoCallReport => 'Report this call';

  @override
  String get videoCallWhatwentwrong => 'What went wrong?';

  @override
  String get videoCallAudioQuality => 'Audio quality';

  @override
  String get videoCallVideoQuality => 'Video quality';

  @override
  String get videoCallConnectionDropped => 'Connection dropped';

  @override
  String get videoCallOther => 'Other';

  @override
  String get videoCallMoveCloser => 'Move closer to the router';

  @override
  String get videoCallDisableApps => 'Disable other data-heavy apps';

  @override
  String get videoCallSwitchWifi => 'Switch from mobile data to Wi-Fi';

  @override
  String get videoCallPip => 'Picture-in-picture';

  @override
  String get videoCallFullscreen => 'Full screen';

  @override
  String get videoCallMicOn => 'Microphone on';

  @override
  String get videoCallMicOff => 'Microphone off';

  @override
  String get videoCallCameraOn => 'Camera on';

  @override
  String get videoCallCameraOffToggle => 'Camera off';

  @override
  String get videoCallFlipCamera => 'Flip camera';

  @override
  String get videoCallEffects => 'Effects';

  @override
  String get videoCallNoFilter => 'No filter';

  @override
  String get videoCallWarmGlow => 'Warm glow';

  @override
  String get videoCallSoftFocus => 'Soft focus';

  @override
  String get videoCallBlurBg => 'Blur background';

  @override
  String get videoCallHD => 'HD';

  @override
  String get videoCallReconnected => 'Reconnected';

  @override
  String get videoCallConnectionLost => 'Connection lost';

  @override
  String get videoCallTipMoveCloser => 'Move closer to the router';

  @override
  String get videoCallTipDisableApps => 'Disable other data-heavy apps';

  @override
  String get videoCallTipSwitchWifi => 'Switch from mobile data to Wi-Fi';

  @override
  String get chatRequest => 'Chat Request';

  @override
  String get requestSent => 'Request sent! · Demande envoyée';

  @override
  String get writePersonalisedMessage => 'Write a personalised message...';

  @override
  String get send => 'Send';

  @override
  String get personalisedMessagesTip => 'Personalised messages get ';

  @override
  String get requestsRemaining => 'requests remaining';

  @override
  String get upgradeToSend => 'Upgrade to send';

  @override
  String get preview => 'Preview';

  @override
  String get messagePreview => 'Your message here...';

  @override
  String get messageAnyone => 'Message anyone, anytime';

  @override
  String get freeAccountsMutualMatches =>
      'Free accounts can only message mutual matches. Upgrade to message anyone.';

  @override
  String messageDirectly(Object name) {
    return 'Send a direct message to $name';
  }

  @override
  String likeRecipient(Object name) {
    return 'Like $name instead';
  }

  @override
  String get likeInstead => 'Like instead';
}
