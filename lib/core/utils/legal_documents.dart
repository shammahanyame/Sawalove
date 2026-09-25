/// Canonical legal documents for SawaLove, rendered in-app.
///
/// These replaced the previous placeholder pages, which Play Store policy
/// review treats as grounds for rejection. The text describes what the app
/// and its PHP backend actually collect and do.
library;

const String kSupportEmail = 'support@sawalove.cm';
const String kPrivacyPolicyMarkdown = '''
# SawaLove Privacy Policy

**Effective date: September 23, 2026**

SawaLove ("we", "us") operates a dating service for people in Cameroon and
the diaspora. This policy explains what data we collect, why, and the
controls you have. **You must be at least 18 years old to use SawaLove.**

## 1. Data we collect

- **Account data** — the phone number (with +237 prefix) or email address and
  name you register with. Phone numbers are used to send one-time
  verification codes by SMS.
- **Profile data** — photos you upload, your bio, age, city/region,
  relationship intent, religion, and matching preferences.
- **Location** — with your permission, a coarse location used to compute
  distance to other profiles. Your exact position is never shown to other
  users; distance is resolved to city/region level.
- **Photos** — profile photos that you choose to upload. The minimum is two
  photos with a clear face so other users can recognise you.
- **Messages** — if/when messaging is enabled, the messages you send to
  people you have matched with are stored so both of you can see the
  conversation.
- **Reports & moderation** — if you report a user, or a user reports you, we
  store the report, its reason, any details you add, and the moderation
  decision, to keep the community safe.
- **Transaction PIN** — if you set one, it is sent over TLS and stored only
  as a salted bcrypt hash. We never store the raw PIN.
- **Device & diagnostics** — basic device information and app version for
  troubleshooting and security.

## 2. How we use data

- Create your account and verify your phone number or email.
- Show your profile to other users and match you with people near you.
- Keep SawaLove safe: reviewing reports, pausing or banning accounts that
  violate our rules, and letting you appeal.
- Let you pause, delete, or export your account data.
- Improve the service using anonymised, aggregated statistics — only if you
  opt in on the consent screen. You can change this at any time.

## 3. What we never do

- We never sell your personal data.
- We never post anything anywhere on your behalf.
- We never show your exact GPS position to other users.

## 4. Camera, microphone, location & notifications

These permissions are optional and requested with an explanation:

- **Location** — to find matches near you. You can use SawaLove without it.
- **Camera** — to take profile photos and verification selfies.
- **Microphone** — to record voice notes in chats (when messaging is on).
- **Notifications** — to tell you about new matches and messages. You can
  turn these off any time in system settings.

Granting or denying a permission never blocks you from using the rest of
the app.

## 5. Data retention & deletion

- **Delete account** (Profile → Account) schedules permanent deletion of
  your profile, photos, matches and messages. Recovery is possible for 30
  days by contacting support; after that everything is erased.
- **Pause account** hides your profile from discovery until you resume it.
- **Download your data** (Profile → Account) gives you an export of your
  profile, matches and chats in JSON format.
- Declining the consent screen at signup deletes everything you entered
  and returns you to the welcome screen.

## 6. Security

Data travels over HTTPS. Session tokens are stored on your device and
expire automatically. Passwords and transaction PINs are stored only as
salted hashes. Access to moderation tools is restricted to authorised
moderator accounts, and every action is logged.

## 7. Your rights

You may access, correct, export, or delete your personal data at any time
from inside the app, or by emailing **$kSupportEmail**. Users in the EU/EEA
have additional rights under the GDPR, including the right to lodge a
complaint with a supervisory authority.

## 8. Children

SawaLove is strictly for adults aged 18 and over. We do not knowingly
collect data from anyone under 18. If you believe a minor is using
SawaLove, report the profile in-app or email **$kSupportEmail** and we will
remove it.

## 9. Changes & contact

We will announce material changes to this policy in the app before they
take effect. Questions? Email **$kSupportEmail**.
''';

const String kTermsOfServiceMarkdown = '''
# SawaLove Terms of Service

**Effective date: September 23, 2026**

Welcome to SawaLove. By creating an account you agree to these terms.
**SawaLove is only for people aged 18 or older.**

## 1. Your account

- You must be at least 18 years old to use SawaLove.
- You must provide accurate information during registration. Phone
  verification with a +237 number, or email verification for diaspora
  users, is required.
- You are responsible for keeping your account secure and for all activity
  under your account. One person, one account.

## 2. Community rules

SawaLove is a respectful dating community. You agree **not** to:

- Impersonate anyone, use fake photos, or create a profile for someone else.
- Harass, threaten, stalk, or bully other users.
- Send spam, scams, phishing links, or requests for money.
- Post nudity, sexual content, violent or hateful content.
- Share other people's private information without consent.
- Use SawaLove for prostitution, trafficking, or any illegal activity.

We remove violating content, pause or permanently ban accounts, and report
illegal activity to the relevant authorities. If your account is actioned
you can appeal through **Profile → Safety → Moderation appeal**.

## 3. Photos & content you upload

You keep ownership of your photos and bio. You give us a limited licence to
host and display them inside SawaLove for the purpose of operating the
service (for example, showing your profile to other users). Content you
post must follow our community rules above.

## 4. Safety

Meeting people online carries risk. Use common sense: keep conversations in
the app, meet in public places, tell a friend where you are going, and
report anyone who makes you feel unsafe. Report and block tools are always
free.

## 5. Purchases

Some features may be offered as paid subscriptions or consumables in the
future. If and when that happens, they will be billed through Google Play
on Google Play's terms, with clear pricing before you confirm any purchase.
Paid features are not available in this version of the app.

## 6. Ending these terms

You can stop using SawaLove and delete your account at any time from
Profile → Account; data deletion is described in the Privacy Policy. We may
suspend or ban accounts that break these rules, with an appeal process.

## 7. Disclaimers & liability

SawaLove is provided "as is" without warranties of any kind. To the maximum
extent permitted by law, we are not liable for indirect or consequential
damages, and our total liability to you is limited to the amount you paid
us in the 12 months before the claim (zero if you paid nothing). Nothing
here limits rights you have under mandatory consumer law.

## 8. Governing law

These terms are governed by the laws of the Republic of Cameroon. Contact:
**$kSupportEmail**.
''';

/// ---------------------------------------------------------------------------
/// French versions (the app ships EN + FR; Play reviewers in Cameroon see
/// both languages, and the in-app legal pages must match the device locale).
/// ---------------------------------------------------------------------------

const String kPrivacyPolicyMarkdownFr = '''
# Politique de confidentialité de SawaLove

**Date d'entrée en vigueur : 23 septembre 2026**

SawaLove (« nous ») exploite un service de rencontre destiné aux personnes
au Cameroun et dans la diaspora. Cette politique explique quelles données
nous collectons, pourquoi, et les contrôles dont vous disposez.
**Vous devez avoir au moins 18 ans pour utiliser SawaLove.**

## 1. Données que nous collectons

- **Données de compte** — le numéro de téléphone (avec l'indicatif +237) ou
  l'adresse e-mail et le nom que vous utilisez pour vous inscrire. Les
  numéros de téléphone servent à envoyer des codes de vérification à usage
  unique par SMS.
- **Données de profil** — les photos que vous téléversez, votre bio, votre
  âge, votre ville/région, votre intention relationnelle, votre religion et
  vos préférences de correspondance.
- **Localisation** — avec votre permission, une localisation approximative
  utilisée pour calculer la distance avec les autres profils. Votre position
  exacte n'est jamais montrée aux autres utilisateurs ; la distance est
  résolue au niveau de la ville/région.
- **Photos** — les photos de profil que vous choisissez de téléverser. Le
  minimum est de deux photos avec le visage dégagé afin que les autres
  utilisateurs puissent vous reconnaître.
- **Messages** — si/la messagerie est activée, les messages que vous
  envoyez aux personnes avec qui vous avez matché sont conservés afin que
  vous puissiez tous les deux consulter la conversation.
- **Signalements et modération** — si vous signalez un utilisateur, ou si un
  utilisateur vous signale, nous conservons le signalement, son motif, les
  détails que vous ajoutez et la décision de modération, afin de protéger
  la communauté.
- **Code PIN de transaction** — si vous en définissez un, il est transmis
  via TLS et stocké uniquement sous forme de hachage bcrypt salé. Nous ne
  stockons jamais le PIN en clair.
- **Appareil et diagnostics** — informations de base sur l'appareil et la
  version de l'application pour le dépannage et la sécurité.

## 2. Comment nous utilisons les données

- Créer votre compte et vérifier votre numéro de téléphone ou votre e-mail.
- Afficher votre profil aux autres utilisateurs et vous proposer des
  personnes proches de vous.
- Garantir la sécurité de SawaLove : examen des signalements, suspension ou
  bannissement des comptes qui enfreignent nos règles, et possibilité de
  faire appel.
- Vous permettre de suspendre, supprimer ou exporter vos données.
- Améliorer le service à l'aide de statistiques anonymisées et agrégées —
  uniquement si vous l'acceptez sur l'écran de consentement. Vous pouvez
  modifier ce choix à tout moment.

## 3. Ce que nous ne faisons jamais

- Nous ne vendons jamais vos données personnelles.
- Nous ne publieons jamais rien en votre nom.
- Nous ne montrons jamais votre position GPS exacte aux autres
  utilisateurs.

## 4. Caméra, micro, localisation et notifications

Ces autorisations sont facultatives et demandées avec une explication :

- **Localisation** — pour trouver des correspondances près de vous. Vous
  pouvez utiliser SawaLove sans l'activer.
- **Caméra** — pour prendre des photos de profil et des selfies de
  vérification.
- **Microphone** — pour enregistrer des messages vocaux dans les
  discussions (lorsque la messagerie est active).
- **Notifications** — pour vous informer des nouveaux matchs et messages.
  Vous pouvez les désactiver à tout moment dans les réglages du système.

Accorder ou refuser une autorisation ne vous bloque jamais de le reste de
l'application.

## 5. Conservation et suppression des données

- **Supprimer le compte** (Profil → Compte) planifie la suppression
  définitive de votre profil, photos, matchs et messages. Une récupération
  est possible pendant 30 jours en contactant le support ; ensuite, tout
  est effacé.
- **Suspendre le compte** masque votre profil de la découverte jusqu'à la
  reprise.
- **Télécharger vos données** (Profil → Compte) vous fournit un export de
  votre profil, matchs et discussions au format JSON.
- Refuser l'écran de consentement à l'inscription supprime tout ce que vous
  avez saisi et vous ramène à l'écran d'accueil.

## 6. Sécurité

Les données transitent par HTTPS. Les jetons de session sont stockés sur
votre appareil et expirent automatiquement. Les mots de passe et les codes
PIN sont stockés uniquement sous forme de hachages salés. L'accès aux
outils de modération est limité aux comptes de modérateurs autorisés, et
chaque action est journalisée.

## 7. Vos droits

Vous pouvez accéder à vos données personnelles, les corriger, les exporter
ou les supprimer à tout moment depuis l'application, ou en écrivant à
**$kSupportEmail**. Les utilisateurs de l'UE/EEE disposent de droits
supplémentaires au titre du RGPD, notamment le droit d'introduire une
réclamation auprès d'une autorité de contrôle.

## 8. Mineurs

SawaLove est strictement réservé aux adultes de 18 ans et plus. Nous ne
collectons pas sciemment de données sur des personnes de moins de 18 ans.
Si vous pensez qu'un mineur utilise SawaLove, signalez le profil dans
l'application ou écrivez à **$kSupportEmail** et nous le supprimerons.

## 9. Modifications et contact

Nous annoncerons les modifications importantes de cette politique dans
l'application avant leur entrée en vigueur. Des questions ? Écrivez à
**$kSupportEmail**.
''';

const String kTermsOfServiceMarkdownFr = '''
# Conditions d'utilisation de SawaLove

**Date d'entrée en vigueur : 23 septembre 2026**

Bienvenue sur SawaLove. En créant un compte, vous acceptez ces conditions.
**SawaLove est réservé aux personnes de 18 ans ou plus.**

## 1. Votre compte

- Vous devez avoir au moins 18 ans pour utiliser SawaLove.
- Vous devez fournir des informations exactes lors de l'inscription. La
  vérification par téléphone avec un numéro +237, ou par e-mail pour les
  utilisateurs de la diaspora, est obligatoire.
- Vous êtes responsable de la sécurité de votre compte et de toute
  activité effectuée sous votre compte. Une personne, un compte.

## 2. Règles de la communauté

SawaLove est une communauté de rencontre respectueuse. Vous acceptez de
**ne pas** :

- Usurper l'identité de quiconque, utiliser de fausses photos ou créer un
  profil pour quelqu'un d'autre.
- Harceler, menacer, traquer ou intimider les autres utilisateurs.
- Envoyer du spam, des arnaques, des liens de hameçonnage ou des demandes
  d'argent.
- Publier de la nudité, du contenu sexuel, violent ou haineux.
- Divulguer des informations privées d'autrui sans consentement.
- Utiliser SawaLove pour de la prostitution, de la traite ou toute activité
  illégale.

Nous supprimons les contenus fautifs, suspendons ou bannissons
définitivement les comptes, et signalons les activités illégales aux
autorités compétentes. Si votre compte est sanctionné, vous pouvez faire
appel via **Profil → Sécurité → Recours en modération**.

## 3. Photos et contenus que vous publiez

Vous restez propriétaire de vos photos et de votre bio. Vous nous accordez
une licence limitée pour les héberger et les afficher au sein de SawaLove
aux fins d'exploitation du service (par exemple, montrer votre profil aux
autres utilisateurs). Les contenus que vous publiez doivent respecter nos
règles de communauté ci-dessus.

## 4. Sécurité

Rencontrer des personnes en ligne comporte des risques. Faites preuve de
bon sens : restez dans l'application pour discuter, rencontrez-vous dans
des lieux publics, prévenez un proche de vos déplacements et signalez toute
personne qui vous met mal à l'aise. Les fonctions de signalement et de
blocage sont toujours gratuites.

## 5. Achats

Certaines fonctionnalités pourront à l'avenir être proposées sous forme
d'abonnements ou d'achats payants. Le cas échéant, ils seront facturés via
Google Play, aux conditions de Google Play, avec un prix clair avant toute
confirmation. Les fonctionnalités payantes ne sont pas disponibles dans
cette version de l'application.

## 6. Fin des présentes conditions

Vous pouvez cesser d'utiliser SawaLove et supprimer votre compte à tout
moment depuis Profil → Compte ; la suppression des données est décrite dans
la politique de confidentialité. Nous pouvons suspendre ou bannir les
comptes qui enfreignent ces règles, avec un recours d'appel.

## 7. Avertissements et responsabilité

SawaLove est fourni « en l'état », sans garantie d'aucune sorte. Dans la
mesure permise par la loi, nous ne sommes pas responsables des dommages
indirects ou consécutifs, et notre responsabilité totale est limitée au
montant que vous nous avez payé au cours des 12 mois précédant la
réclamation (zéro si vous n'avez rien payé). Rien de ce qui précède ne
limite les droits dont vous bénéficiez en vertu du droit impératif de la
consommation.

## 8. Droit applicable

Les présentes conditions sont régies par les lois de la République du
Cameroun. Contact : **$kSupportEmail**.
''';
