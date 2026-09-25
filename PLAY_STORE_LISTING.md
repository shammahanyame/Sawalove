# SawaLove — Play Console paste pack (store listing + forms)

Last updated: 2026-09-25 · app 1.0.1+3 · applicationId `com.shammah.sawalove`

Everything below claims **only what v1.0.1 actually ships** (see
`PLAY_STORE_CHECKLIST.md` §5). Do not add calls, premium, verification
badges, SOS, super likes or referral rewards to any listing — reviewers test
every claim.

---

## 1. App name (max 30 characters)

| Listing | Text | Chars |
|---|---|---|
| Default (EN) | `SawaLove — Dating Cameroon` | 26 |
| French | `SawaLove Rencontres Cameroun` | 27 |

## 2. Short description (max 80 characters)

**EN** (64):
`Find your soulmate in Cameroon. Real profiles, real people, 18+.`

**FR** (57):
`Trouvez votre âme sœur au Cameroun. De vrais profils, 18+.`

## 3. Full description (max 4000 characters)

### EN

```
SawaLove is a dating app for people in Cameroon and the diaspora who are
serious about finding a real relationship. 18+ only. English and French.

CREATE A PROFILE THAT'S REALLY YOU
• Upload at least two clear photos
• Add your bio, your city or region, and your faith background
• Say what you're looking for: a relationship, marriage, or friendship
• Your location is only ever shown as a distance or city/region — never
  your exact position

DISCOVER REAL PEOPLE NEAR YOU
• Swipe through profiles from real people around you
• Filter by age, region, faith, relationship intent, and photos only
• Changed your mind? Undo your last swipe
• See everyone who liked you in the Likes tab

MATCH AND CHAT
• When you like each other, it's a match
• Message your matches one-to-one, with stickers
• New matches and messages arrive in one inbox

SAFE BY DESIGN
• Report and block are always free, one tap away from any profile or chat
• Everyone must be 18+ — your date of birth is checked at signup
• Moderators review every report, and you can appeal any decision
• Download your data or delete your account any time from Profile → Account

Free to join, free to chat. Find your soulmate in Cameroon — download
SawaLove today.
```

### FR

```
SawaLove est une application de rencontre pour les personnes au Cameroun et
dans la diaspora qui cherchent une vraie relation. 18+ uniquement. En
français et en anglais.

CRÉEZ UN PROFIL VRAIMENT VOUS
• Téléversez au moins deux photos nettes
• Ajoutez votre bio, votre ville ou région et votre contexte religieux
• Indiquez ce que vous cherchez : une relation, le mariage, ou l'amitié
• Votre localisation n'est montrée que sous forme de distance ou de
  ville/région — jamais votre position exacte

DÉCOUVRE DE VRAIES PERSONNES PRÈS DE VOUS
• Parcourez les profils de vraies personnes autour de vous
• Filtrez par âge, région, foi, intention relationnelle, et profils avec
  photos seulement
• Vous avez changé d'avis ? Annulez votre dernier swipe
• Voyez toutes les personnes qui vous ont liké dans l'onglet Likes

MATCH ET DISCUTEZ
• Si vous vous aimez mutuellement, c'est un match
• Échangez des messages en privé avec vos matchs, avec des stickers
• Nouveaux matchs et messages au même endroit

PENSÉE POUR VOTRE SÉCURITÉ
• Signaler et bloquer sont toujours gratuits, en un geste depuis n'importe
  quel profil ou discussion
• Tout le monde doit avoir 18+ — votre date de naissance est vérifiée à
  l'inscription
• Les modérateurs examinent chaque signalement, et vous pouvez contester
  toute décision
• Téléchargez vos données ou supprimez votre compte à tout moment depuis
  Profil → Compte

Inscription gratuite, discussions gratuites. Trouvez votre âme sœur au
Cameroun — téléchargez SawaLove dès maintenant.
```

## 4. Screenshots plan (phone, min 2 / recommended 8)

1. Onboarding consent screen (shows compliance at first glance)
2. Discovery swipe deck
3. Filters sheet
4. Profile view
5. Likes & Matches tabs
6. Chat list (inbox)
7. Chat detail with sticker picker
8. Safety center / report sheet

Capture in EN, then repeat the set for the FR listing. Use the running app
against the deployed API (checklist §0.1) so every screen shows real data.

## 5. Feature graphic & icon

- App icon 512×512: `assets/branding/sawalove_app_icon_512.png`
- Feature graphic 1024×500: not yet produced — needs to be made before
  submission (listing is rejected without one).

## 6. Data safety — paste-ready (Play Console → App content → Data safety)

**Does your app collect or share any of the required user data types?** → **Yes**

| Data type | Collected | Shared | Purpose | Ephemeral | Required |
|---|---|---|---|---|---|
| Personal info — Name | Yes | No | App functionality | No | Yes |
| Personal info — Phone number | Yes | No | Account management, app functionality | No | Optional (email sign-in instead) |
| Personal info — Email address | Yes | No | Account management | No | Optional (phone sign-in instead) |
| User IDs | Yes | No | Account management | No | Yes |
| Photos | Yes | No | App functionality (profile) | No | Yes |
| Other user content (bio, preferences, messages) | Yes | No | App functionality | No | Yes |
| Approximate location | Yes | No | App functionality (distance-based matching) | No | Yes (in-app disclosure; usable without it) |
| App interactions | Only if analytics consent given | No | Analytics | No | Optional |

Answers for the remaining questions:

- **Data encrypted in transit:** Yes (HTTPS enforced; cleartext disabled in the build)
- **Data can be deleted:** Yes — in-app (Profile → Account → Delete / Download data) and web: `https://sawalove.com/deletion`
- **Data sold:** No · **Data shared with third parties:** No
- **Committed to Google Play Families policy:** No (adults-only app)

Mirrors `PLAY_STORE_CHECKLIST.md` §1.4 — keep both in sync if collection ever changes.

## 7. Privacy policy URL field

`https://sawalove.com/privacy`

PDF sources are generated by `python scripts/export_legal_pdfs.py` →
`legal_exports/privacy-policy-{en,fr}.pdf`, `legal_exports/terms-of-service-{en,fr}.pdf`
(upload `privacy.pdf` + `tos.pdf` per checklist §0.3).

## 8. App access form (Play Console → App content → App access)

Template — fill the blanks after the API is live and you've tested a fresh
signup end-to-end:

```
All functionality is available to reviewers. No restrictions.

Sign-in method: Email address + password

Test account:
  Email:    <demo-account@sawalove.com>
  Password: <generated strong password — store in your password manager>

Steps for the reviewer:
  1. Install SawaLove from the testing track.
  2. Open the app, accept the consent screen (18+ confirmed).
  3. Choose "Continue with email", enter the credentials above.
  4. Full access: discovery, filters, likes, matching, chat, profile,
     report/block, and Account → Delete are all available.

Country of the test phone number (if OTP fallback needed): Cameroon (+237)
```

Notes:
- The release build ships with email auth enabled
  (`API_EMAIL_AUTH_ENABLED=true`), so reviewers are not blocked on Cameroonian
  SMS delivery — but verify the demo account actually works against the
  **production** API before submitting (checklist §1.7).
- Never reuse your personal account; create a dedicated demo account.
