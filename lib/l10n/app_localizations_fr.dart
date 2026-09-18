// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'SawaLove';

  @override
  String get phoneLoginTitle => 'Connexion par téléphone';

  @override
  String get enterPhone => 'Entrez votre numéro de téléphone';

  @override
  String get sendOtp => 'Envoyer le OTP';

  @override
  String get languageToggle => 'English';

  @override
  String get moderationAppealTitle => 'Appel de modération';

  @override
  String get moderationAppealPrevious => 'Appels précédents';

  @override
  String get moderationAppealNew => 'Nouvel appel';

  @override
  String get moderationAppealReason => 'Raison du bannissement/signalement';

  @override
  String get moderationAppealExplanation =>
      'Expliquez pourquoi vous pensez que c\'était une erreur';

  @override
  String get moderationAppealPhoto => 'Ajouter une preuve photo';

  @override
  String get moderationAppealSubmit => 'Soumettre l\'appel';

  @override
  String get discoveryTitle => 'Découverte';

  @override
  String get exploreTitle => 'Explorer';

  @override
  String get matchesTitle => 'Matchs';

  @override
  String get chatTitle => 'Discussions';

  @override
  String get profileTitle => 'Profil';

  @override
  String get login => 'Connexion';

  @override
  String get signup => 'Inscription';

  @override
  String get otp => 'Code OTP';

  @override
  String get settings => 'Paramètres';

  @override
  String get premium => 'Premium';

  @override
  String get safety => 'Sécurité';

  @override
  String get home => 'Accueil';

  @override
  String get village => 'Village';

  @override
  String get intentSerious => 'Relation sérieuse';

  @override
  String get intentMarriage => 'Mariage';

  @override
  String get verified => 'Vérifié';

  @override
  String get online => 'En ligne';

  @override
  String get kmAway => 'km de distance';

  @override
  String get photoUploadTitle => 'Ajoutez vos photos';

  @override
  String get photoUploadSubtitle => 'Min 2 photos, visage clair requis';

  @override
  String get addPhoto => 'Ajouter une photo';

  @override
  String get camera => 'Caméra';

  @override
  String get gallery => 'Galerie';

  @override
  String get instagram => 'Instagram';

  @override
  String get faceDetected => 'Visage détecté';

  @override
  String get faceChecking => 'Vérification…';

  @override
  String get noFaceFound => 'Aucun visage trouvé';

  @override
  String get replacePhoto => 'Remplacer la photo';

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
    return 'Ajoutez $count de plus pour continuer';
  }

  @override
  String get tipCardMessage =>
      'Astuce : Les profils avec 4+ photos reçoivent 3× plus de likes';

  @override
  String get celebratoryMessage => 'Parfait ! Vos photos sont prêtes';

  @override
  String get reorderInstruction =>
      'Faites glisser les photos pour les réorganiser. La grande case est votre photo principale.';

  @override
  String get newMainPhotoSet => 'Nouvelle photo principale définie';

  @override
  String get done => 'Terminé';

  @override
  String get continueToPreferences => 'Continuer vers les préférences';

  @override
  String get faceNotDetected => 'Visage non détecté';

  @override
  String get faceNotDetectedDesc =>
      'Veuillez télécharger une photo où votre visage est clairement visible.';

  @override
  String get reorderPhotos => 'Réorganiser les photos';

  @override
  String get longPressToDrag =>
      'Appuyez longuement pour faire glisser et réorganiser.';

  @override
  String get preferencesTitle => 'Qui recherchez-vous ?';

  @override
  String get preferencesSubtitle => 'Affinez votre pool de matchs';

  @override
  String get ageRange => 'Tranche d\'âge';

  @override
  String get distance => 'Distance';

  @override
  String get gender => 'Genre';

  @override
  String get intent => 'Intention de relation';

  @override
  String get religion => 'Religion';

  @override
  String get dealbreakers => 'Points de rupture';

  @override
  String get showMeEveryone => 'Montrez-moi tout le monde';

  @override
  String get showMeEveryoneDesc => 'Ignorez tous les filtres ci-dessus';

  @override
  String get hasChildren => 'A des enfants';

  @override
  String get hasChildrenDesc => 'Exclure les profils avec des enfants';

  @override
  String get smokes => 'Fume';

  @override
  String get smokesDesc => 'Exclure les fumeurs';

  @override
  String get onlyVerified => 'Uniquement vérifiés par photo';

  @override
  String get onlyVerifiedDesc =>
      'Afficher uniquement les utilisateurs vérifiés';

  @override
  String get discoverMatches => 'Découvrir les matchs';

  @override
  String get peopleNearby => 'personnes à proximité';

  @override
  String get goodRange => 'Bonne portée';

  @override
  String get narrowPool => 'Pool étroit';

  @override
  String get veryNarrowPool => 'Pool très étroit';

  @override
  String get allUsersShown => 'Tous les utilisateurs affichés';

  @override
  String get reportUserTitle => 'Signaler l\'utilisateur';

  @override
  String get photoViewerCloseSemantics =>
      'Fermer la visionneuse de photos, retour au profil.';

  @override
  String photoViewerPhotoSemantics(Object index, Object caption) {
    return 'Photo $index : $caption. Double tapez pour aimer.';
  }

  @override
  String photoViewerDotsSemantics(Object current, Object total) {
    return 'Points de navigation photo. Visionnage actuel de la photo $current sur $total.';
  }

  @override
  String get photoViewerThumbnailsSemantics =>
      'Miniatures des photos. Tapez une miniature pour naviguer.';

  @override
  String get photoViewerReportSemantics => 'Signaler cette photo.';

  @override
  String get photoViewerPinchHint => 'Pincez pour zoomer';

  @override
  String get photoViewerLinkCopied => 'Lien du profil copié · Lien copié.';

  @override
  String get photoViewerAlreadyLiked => 'Déjà aimé · Déjà aimé';

  @override
  String get photoViewerUndo => 'Annuler';

  @override
  String get reportReasonInappropriate => 'Contenu inapproprié';

  @override
  String get reportReasonSpam => 'Spam ou faux profil';

  @override
  String get reportReasonHarassment => 'Harcèlement';

  @override
  String get reportReasonUnderage => 'Mineur';

  @override
  String get reportReasonOther => 'Autre';

  @override
  String get videoCallConnecting => 'Connexion en cours…';

  @override
  String get videoCallActive => 'Connecté';

  @override
  String get videoCallMuted => 'Muet';

  @override
  String get videoCallCameraOff => 'Caméra désactivée';

  @override
  String get videoCallPoorConnection => 'Mauvaise connexion';

  @override
  String get videoCallReconnecting => 'Reconnexion en cours…';

  @override
  String get videoCallEnded => 'Appel terminé';

  @override
  String get videoCallCancel => 'Annuler l\'appel';

  @override
  String get videoCallEndCall => 'Terminer l\'appel';

  @override
  String get videoCallAccept => 'Accepter';

  @override
  String get videoCallDecline => 'Refuser';

  @override
  String videoCallIncoming(Object name) {
    return 'Appel vidéo entrant de $name';
  }

  @override
  String videoCallNoAnswer(Object name) {
    return '$name n\'a pas répondu';
  }

  @override
  String get videoCallFailed => 'Échec de connexion';

  @override
  String get videoCallRetry => 'Réessayer';

  @override
  String get videoCallDuration => 'Durée';

  @override
  String get videoCallQuality => 'Qualité';

  @override
  String get videoCallLatency => 'Latence';

  @override
  String get videoCallRatethis => 'Noter cet appel';

  @override
  String get videoCallExcellent => 'Excellent';

  @override
  String get videoCallGood => 'Bon';

  @override
  String videoCallMessage(Object name) {
    return 'Envoyer un message à $name';
  }

  @override
  String get videoCallBacktoDiscover => 'Retour à la découverte';

  @override
  String get videoCallReport => 'Signaler cet appel';

  @override
  String get videoCallWhatwentwrong => 'Qu\'est-ce qui n\'a pas fonctionné?';

  @override
  String get videoCallAudioQuality => 'Qualité audio';

  @override
  String get videoCallVideoQuality => 'Qualité vidéo';

  @override
  String get videoCallConnectionDropped => 'Connexion perdue';

  @override
  String get videoCallOther => 'Autre';

  @override
  String get videoCallMoveCloser => 'Rapprochez-vous du routeur';

  @override
  String get videoCallDisableApps => 'Désactivez les applications lourdes';

  @override
  String get videoCallSwitchWifi => 'Passez du mobile au Wi-Fi';

  @override
  String get videoCallPip => 'Image dans l\'image';

  @override
  String get videoCallFullscreen => 'Plein écran';

  @override
  String get videoCallMicOn => 'Microphone activé';

  @override
  String get videoCallMicOff => 'Microphone désactivé';

  @override
  String get videoCallCameraOn => 'Caméra activée';

  @override
  String get videoCallCameraOffToggle => 'Caméra désactivée';

  @override
  String get videoCallFlipCamera => 'Retourner la caméra';

  @override
  String get videoCallEffects => 'Effets';

  @override
  String get videoCallNoFilter => 'Pas de filtre';

  @override
  String get videoCallWarmGlow => 'Lueur chaude';

  @override
  String get videoCallSoftFocus => 'Flou doux';

  @override
  String get videoCallBlurBg => 'Flou d\'arrière-plan';

  @override
  String get videoCallHD => 'HD';

  @override
  String get videoCallReconnected => 'Reconnecté';

  @override
  String get videoCallConnectionLost => 'Connexion perdue';

  @override
  String get videoCallTipMoveCloser => 'Rapprochez-vous du routeur';

  @override
  String get videoCallTipDisableApps => 'Désactivez les applications lourdes';

  @override
  String get videoCallTipSwitchWifi => 'Passez du mobile au Wi-Fi';

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
