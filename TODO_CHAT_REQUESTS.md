# Chat Request System Implementation Tracker

## Backend
- [ ] Create Cloud Functions: sendChatRequest, acceptChatRequest, declineChatRequest, undoDeclineChatRequest
- [ ] Deploy functions

## Frontend Steps
- [x] 1. Create TODO.md (done)
- [x] 2. Update quota_provider.dart for request quotas & persistence
- [x] 3. Polish request_compose_screen.dart with real recipient data
- [x] 4. Create chat_request_card.dart widget
- [x] 5. Update chat_list_screen.dart to use detailed card, add blur reveal, badges, confirmation
- [ ] 6. Update feature_gate_screen.dart to DraggableScrollableSheet
- [x] 7. Add decline_confirm_screen.dart & undo_screen.dart + router routes

- [ ] 4. Create chat_request_card.dart widget
- [ ] 5. Update chat_list_screen.dart to use detailed card, add blur reveal, badges, confirmation
- [ ] 6. Update feature_gate_screen.dart to DraggableScrollableSheet
- [ ] 7. Add decline_confirm_screen.dart & undo_screen.dart + router routes
- [ ] 8. Enhance inbox_provider.dart with full logic (CF calls, cooldown)
- [ ] 9. Update message.dart model (isRequestMessage)
- [ ] 10. Add l10n keys to app_en/fr.arb + Semantics
- [ ] 11. Test full flows
- [ ] 12. Firestore security rules
- [ ] 13. Polish: animations, sent requests view, quota reset

**Current progress: 8/13 steps complete**

## Completed:
- Frontend UI screens, cards, gate sheet, navigation, models
- L10n bilingual support
- View transitions for web

## Remaining:
- Backend Cloud Functions
- Inbox provider CF integration
- Full testing & rules

