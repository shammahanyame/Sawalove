import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SawaLove'**
  String get appTitle;

  /// No description provided for @phoneLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Phone Login'**
  String get phoneLoginTitle;

  /// No description provided for @enterPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterPhone;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// Toggle to French
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageToggle;

  /// No description provided for @moderationAppealTitle.
  ///
  /// In en, this message translates to:
  /// **'Moderation Appeal'**
  String get moderationAppealTitle;

  /// No description provided for @moderationAppealPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous Appeals'**
  String get moderationAppealPrevious;

  /// No description provided for @moderationAppealNew.
  ///
  /// In en, this message translates to:
  /// **'New Appeal'**
  String get moderationAppealNew;

  /// No description provided for @moderationAppealReason.
  ///
  /// In en, this message translates to:
  /// **'Reason for ban/flag'**
  String get moderationAppealReason;

  /// No description provided for @moderationAppealExplanation.
  ///
  /// In en, this message translates to:
  /// **'Explain why you believe this was a mistake'**
  String get moderationAppealExplanation;

  /// No description provided for @moderationAppealPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo evidence'**
  String get moderationAppealPhoto;

  /// No description provided for @moderationAppealSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit Appeal'**
  String get moderationAppealSubmit;

  /// No description provided for @discoveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Discovery'**
  String get discoveryTitle;

  /// No description provided for @exploreTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get exploreTitle;

  /// No description provided for @matchesTitle.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get matchesTitle;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chatTitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Signup'**
  String get signup;

  /// No description provided for @otp.
  ///
  /// In en, this message translates to:
  /// **'OTP Code'**
  String get otp;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @safety.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get safety;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @village.
  ///
  /// In en, this message translates to:
  /// **'Village'**
  String get village;

  /// No description provided for @intentSerious.
  ///
  /// In en, this message translates to:
  /// **'Serious relationship'**
  String get intentSerious;

  /// No description provided for @intentMarriage.
  ///
  /// In en, this message translates to:
  /// **'Marriage'**
  String get intentMarriage;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @kmAway.
  ///
  /// In en, this message translates to:
  /// **'km away'**
  String get kmAway;

  /// No description provided for @photoUploadTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Your Photos'**
  String get photoUploadTitle;

  /// No description provided for @photoUploadSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Min 2 photos, clear face required'**
  String get photoUploadSubtitle;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get addPhoto;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @instagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get instagram;

  /// No description provided for @faceDetected.
  ///
  /// In en, this message translates to:
  /// **'Face detected'**
  String get faceDetected;

  /// No description provided for @faceChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get faceChecking;

  /// No description provided for @noFaceFound.
  ///
  /// In en, this message translates to:
  /// **'No face found'**
  String get noFaceFound;

  /// No description provided for @replacePhoto.
  ///
  /// In en, this message translates to:
  /// **'Replace photo'**
  String get replacePhoto;

  /// Photo progress minimum label
  ///
  /// In en, this message translates to:
  /// **'{count} / 2 min'**
  String progressMin(Object count);

  /// Photo progress maximum label
  ///
  /// In en, this message translates to:
  /// **'{count} / 6 max'**
  String progressMax(Object count);

  /// No description provided for @addMoreToContinue.
  ///
  /// In en, this message translates to:
  /// **'Add {count} more to continue'**
  String addMoreToContinue(Object count);

  /// No description provided for @tipCardMessage.
  ///
  /// In en, this message translates to:
  /// **'Tip: Profiles with 4+ photos get 3× more likes'**
  String get tipCardMessage;

  /// No description provided for @celebratoryMessage.
  ///
  /// In en, this message translates to:
  /// **'Perfect! Your photos are ready'**
  String get celebratoryMessage;

  /// No description provided for @reorderInstruction.
  ///
  /// In en, this message translates to:
  /// **'Drag photos to reorder. The large slot is your main photo.'**
  String get reorderInstruction;

  /// No description provided for @newMainPhotoSet.
  ///
  /// In en, this message translates to:
  /// **'New main photo set'**
  String get newMainPhotoSet;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @continueToPreferences.
  ///
  /// In en, this message translates to:
  /// **'Continue to Preferences'**
  String get continueToPreferences;

  /// No description provided for @faceNotDetected.
  ///
  /// In en, this message translates to:
  /// **'Face not detected'**
  String get faceNotDetected;

  /// No description provided for @faceNotDetectedDesc.
  ///
  /// In en, this message translates to:
  /// **'Please upload a photo where your face is clearly visible.'**
  String get faceNotDetectedDesc;

  /// No description provided for @reorderPhotos.
  ///
  /// In en, this message translates to:
  /// **'Reorder Photos'**
  String get reorderPhotos;

  /// No description provided for @longPressToDrag.
  ///
  /// In en, this message translates to:
  /// **'Long press to drag and reorder.'**
  String get longPressToDrag;

  /// No description provided for @preferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'Who are you looking for?'**
  String get preferencesTitle;

  /// No description provided for @preferencesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tune your match pool'**
  String get preferencesSubtitle;

  /// No description provided for @ageRange.
  ///
  /// In en, this message translates to:
  /// **'Age Range'**
  String get ageRange;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @intent.
  ///
  /// In en, this message translates to:
  /// **'Relationship Intent'**
  String get intent;

  /// No description provided for @religion.
  ///
  /// In en, this message translates to:
  /// **'Religion'**
  String get religion;

  /// No description provided for @dealbreakers.
  ///
  /// In en, this message translates to:
  /// **'Deal-breakers'**
  String get dealbreakers;

  /// No description provided for @showMeEveryone.
  ///
  /// In en, this message translates to:
  /// **'Show me everyone'**
  String get showMeEveryone;

  /// No description provided for @showMeEveryoneDesc.
  ///
  /// In en, this message translates to:
  /// **'Ignore all filters above'**
  String get showMeEveryoneDesc;

  /// No description provided for @hasChildren.
  ///
  /// In en, this message translates to:
  /// **'Has children'**
  String get hasChildren;

  /// No description provided for @hasChildrenDesc.
  ///
  /// In en, this message translates to:
  /// **'Exclude profiles with children'**
  String get hasChildrenDesc;

  /// No description provided for @smokes.
  ///
  /// In en, this message translates to:
  /// **'Smokes'**
  String get smokes;

  /// No description provided for @smokesDesc.
  ///
  /// In en, this message translates to:
  /// **'Exclude smokers'**
  String get smokesDesc;

  /// No description provided for @onlyVerified.
  ///
  /// In en, this message translates to:
  /// **'Only photo-verified'**
  String get onlyVerified;

  /// No description provided for @onlyVerifiedDesc.
  ///
  /// In en, this message translates to:
  /// **'Show only verified users'**
  String get onlyVerifiedDesc;

  /// No description provided for @discoverMatches.
  ///
  /// In en, this message translates to:
  /// **'Discover Matches'**
  String get discoverMatches;

  /// No description provided for @peopleNearby.
  ///
  /// In en, this message translates to:
  /// **'people nearby'**
  String get peopleNearby;

  /// No description provided for @goodRange.
  ///
  /// In en, this message translates to:
  /// **'Good range'**
  String get goodRange;

  /// No description provided for @narrowPool.
  ///
  /// In en, this message translates to:
  /// **'Narrow pool'**
  String get narrowPool;

  /// No description provided for @veryNarrowPool.
  ///
  /// In en, this message translates to:
  /// **'Very narrow pool'**
  String get veryNarrowPool;

  /// No description provided for @allUsersShown.
  ///
  /// In en, this message translates to:
  /// **'All users shown'**
  String get allUsersShown;

  /// No description provided for @reportUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Report User'**
  String get reportUserTitle;

  /// No description provided for @photoViewerCloseSemantics.
  ///
  /// In en, this message translates to:
  /// **'Close photo viewer, return to profile.'**
  String get photoViewerCloseSemantics;

  /// Accessibility label for a photo
  ///
  /// In en, this message translates to:
  /// **'Photo {index}: {caption}. Double tap to like.'**
  String photoViewerPhotoSemantics(Object index, Object caption);

  /// Accessibility label for dot indicators
  ///
  /// In en, this message translates to:
  /// **'Photo navigation dots. Currently viewing photo {current} of {total}.'**
  String photoViewerDotsSemantics(Object current, Object total);

  /// No description provided for @photoViewerThumbnailsSemantics.
  ///
  /// In en, this message translates to:
  /// **'Photo thumbnails. Tap a thumbnail to navigate.'**
  String get photoViewerThumbnailsSemantics;

  /// No description provided for @photoViewerReportSemantics.
  ///
  /// In en, this message translates to:
  /// **'Report this photo.'**
  String get photoViewerReportSemantics;

  /// No description provided for @photoViewerPinchHint.
  ///
  /// In en, this message translates to:
  /// **'Pinch to zoom'**
  String get photoViewerPinchHint;

  /// No description provided for @photoViewerLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Profile link copied · Lien copié.'**
  String get photoViewerLinkCopied;

  /// No description provided for @photoViewerAlreadyLiked.
  ///
  /// In en, this message translates to:
  /// **'Already liked · Déjà aimé'**
  String get photoViewerAlreadyLiked;

  /// No description provided for @photoViewerUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get photoViewerUndo;

  /// No description provided for @reportReasonInappropriate.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate content'**
  String get reportReasonInappropriate;

  /// No description provided for @reportReasonSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam or fake profile'**
  String get reportReasonSpam;

  /// No description provided for @reportReasonHarassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment'**
  String get reportReasonHarassment;

  /// No description provided for @reportReasonUnderage.
  ///
  /// In en, this message translates to:
  /// **'Underage'**
  String get reportReasonUnderage;

  /// No description provided for @reportReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reportReasonOther;

  /// No description provided for @videoCallConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get videoCallConnecting;

  /// No description provided for @videoCallActive.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get videoCallActive;

  /// No description provided for @videoCallMuted.
  ///
  /// In en, this message translates to:
  /// **'Muted'**
  String get videoCallMuted;

  /// No description provided for @videoCallCameraOff.
  ///
  /// In en, this message translates to:
  /// **'Camera off'**
  String get videoCallCameraOff;

  /// No description provided for @videoCallPoorConnection.
  ///
  /// In en, this message translates to:
  /// **'Poor connection'**
  String get videoCallPoorConnection;

  /// No description provided for @videoCallReconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting…'**
  String get videoCallReconnecting;

  /// No description provided for @videoCallEnded.
  ///
  /// In en, this message translates to:
  /// **'Call ended'**
  String get videoCallEnded;

  /// No description provided for @videoCallCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel call'**
  String get videoCallCancel;

  /// No description provided for @videoCallEndCall.
  ///
  /// In en, this message translates to:
  /// **'End call'**
  String get videoCallEndCall;

  /// No description provided for @videoCallAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get videoCallAccept;

  /// No description provided for @videoCallDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get videoCallDecline;

  /// No description provided for @videoCallIncoming.
  ///
  /// In en, this message translates to:
  /// **'Incoming video call from {name}'**
  String videoCallIncoming(Object name);

  /// No description provided for @videoCallNoAnswer.
  ///
  /// In en, this message translates to:
  /// **'{name} didn\'t answer'**
  String videoCallNoAnswer(Object name);

  /// No description provided for @videoCallFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to connect'**
  String get videoCallFailed;

  /// No description provided for @videoCallRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get videoCallRetry;

  /// No description provided for @videoCallDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get videoCallDuration;

  /// No description provided for @videoCallQuality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get videoCallQuality;

  /// No description provided for @videoCallLatency.
  ///
  /// In en, this message translates to:
  /// **'Latency'**
  String get videoCallLatency;

  /// No description provided for @videoCallRatethis.
  ///
  /// In en, this message translates to:
  /// **'Rate this call'**
  String get videoCallRatethis;

  /// No description provided for @videoCallExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get videoCallExcellent;

  /// No description provided for @videoCallGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get videoCallGood;

  /// No description provided for @videoCallMessage.
  ///
  /// In en, this message translates to:
  /// **'Message {name}'**
  String videoCallMessage(Object name);

  /// No description provided for @videoCallBacktoDiscover.
  ///
  /// In en, this message translates to:
  /// **'Back to discover'**
  String get videoCallBacktoDiscover;

  /// No description provided for @videoCallReport.
  ///
  /// In en, this message translates to:
  /// **'Report this call'**
  String get videoCallReport;

  /// No description provided for @videoCallWhatwentwrong.
  ///
  /// In en, this message translates to:
  /// **'What went wrong?'**
  String get videoCallWhatwentwrong;

  /// No description provided for @videoCallAudioQuality.
  ///
  /// In en, this message translates to:
  /// **'Audio quality'**
  String get videoCallAudioQuality;

  /// No description provided for @videoCallVideoQuality.
  ///
  /// In en, this message translates to:
  /// **'Video quality'**
  String get videoCallVideoQuality;

  /// No description provided for @videoCallConnectionDropped.
  ///
  /// In en, this message translates to:
  /// **'Connection dropped'**
  String get videoCallConnectionDropped;

  /// No description provided for @videoCallOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get videoCallOther;

  /// No description provided for @videoCallMoveCloser.
  ///
  /// In en, this message translates to:
  /// **'Move closer to the router'**
  String get videoCallMoveCloser;

  /// No description provided for @videoCallDisableApps.
  ///
  /// In en, this message translates to:
  /// **'Disable other data-heavy apps'**
  String get videoCallDisableApps;

  /// No description provided for @videoCallSwitchWifi.
  ///
  /// In en, this message translates to:
  /// **'Switch from mobile data to Wi-Fi'**
  String get videoCallSwitchWifi;

  /// No description provided for @videoCallPip.
  ///
  /// In en, this message translates to:
  /// **'Picture-in-picture'**
  String get videoCallPip;

  /// No description provided for @videoCallFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Full screen'**
  String get videoCallFullscreen;

  /// No description provided for @videoCallMicOn.
  ///
  /// In en, this message translates to:
  /// **'Microphone on'**
  String get videoCallMicOn;

  /// No description provided for @videoCallMicOff.
  ///
  /// In en, this message translates to:
  /// **'Microphone off'**
  String get videoCallMicOff;

  /// No description provided for @videoCallCameraOn.
  ///
  /// In en, this message translates to:
  /// **'Camera on'**
  String get videoCallCameraOn;

  /// No description provided for @videoCallCameraOffToggle.
  ///
  /// In en, this message translates to:
  /// **'Camera off'**
  String get videoCallCameraOffToggle;

  /// No description provided for @videoCallFlipCamera.
  ///
  /// In en, this message translates to:
  /// **'Flip camera'**
  String get videoCallFlipCamera;

  /// No description provided for @videoCallEffects.
  ///
  /// In en, this message translates to:
  /// **'Effects'**
  String get videoCallEffects;

  /// No description provided for @videoCallNoFilter.
  ///
  /// In en, this message translates to:
  /// **'No filter'**
  String get videoCallNoFilter;

  /// No description provided for @videoCallWarmGlow.
  ///
  /// In en, this message translates to:
  /// **'Warm glow'**
  String get videoCallWarmGlow;

  /// No description provided for @videoCallSoftFocus.
  ///
  /// In en, this message translates to:
  /// **'Soft focus'**
  String get videoCallSoftFocus;

  /// No description provided for @videoCallBlurBg.
  ///
  /// In en, this message translates to:
  /// **'Blur background'**
  String get videoCallBlurBg;

  /// No description provided for @videoCallHD.
  ///
  /// In en, this message translates to:
  /// **'HD'**
  String get videoCallHD;

  /// No description provided for @videoCallReconnected.
  ///
  /// In en, this message translates to:
  /// **'Reconnected'**
  String get videoCallReconnected;

  /// No description provided for @videoCallConnectionLost.
  ///
  /// In en, this message translates to:
  /// **'Connection lost'**
  String get videoCallConnectionLost;

  /// No description provided for @videoCallTipMoveCloser.
  ///
  /// In en, this message translates to:
  /// **'Move closer to the router'**
  String get videoCallTipMoveCloser;

  /// No description provided for @videoCallTipDisableApps.
  ///
  /// In en, this message translates to:
  /// **'Disable other data-heavy apps'**
  String get videoCallTipDisableApps;

  /// No description provided for @videoCallTipSwitchWifi.
  ///
  /// In en, this message translates to:
  /// **'Switch from mobile data to Wi-Fi'**
  String get videoCallTipSwitchWifi;

  /// No description provided for @chatRequest.
  ///
  /// In en, this message translates to:
  /// **'Chat Request'**
  String get chatRequest;

  /// No description provided for @requestSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent! · Demande envoyée'**
  String get requestSent;

  /// No description provided for @writePersonalisedMessage.
  ///
  /// In en, this message translates to:
  /// **'Write a personalised message...'**
  String get writePersonalisedMessage;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @personalisedMessagesTip.
  ///
  /// In en, this message translates to:
  /// **'Personalised messages get '**
  String get personalisedMessagesTip;

  /// No description provided for @requestsRemaining.
  ///
  /// In en, this message translates to:
  /// **'requests remaining'**
  String get requestsRemaining;

  /// No description provided for @upgradeToSend.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to send'**
  String get upgradeToSend;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @messagePreview.
  ///
  /// In en, this message translates to:
  /// **'Your message here...'**
  String get messagePreview;

  /// No description provided for @messageAnyone.
  ///
  /// In en, this message translates to:
  /// **'Message anyone, anytime'**
  String get messageAnyone;

  /// No description provided for @freeAccountsMutualMatches.
  ///
  /// In en, this message translates to:
  /// **'Free accounts can only message mutual matches. Upgrade to message anyone.'**
  String get freeAccountsMutualMatches;

  /// No description provided for @messageDirectly.
  ///
  /// In en, this message translates to:
  /// **'Send a direct message to {name}'**
  String messageDirectly(Object name);

  /// No description provided for @likeRecipient.
  ///
  /// In en, this message translates to:
  /// **'Like {name} instead'**
  String likeRecipient(Object name);

  /// No description provided for @likeInstead.
  ///
  /// In en, this message translates to:
  /// **'Like instead'**
  String get likeInstead;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
