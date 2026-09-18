# SawaLove Reactions System Implementation TODO

Current working directory: sawalove/

## Breakdown of Approved Plan (Step-by-step)

### 1. **Complete/Enhance Models** ✅ [Complete when done]
   - [ ] Finish `lib/features/chat/models/reaction.dart` (full constructor, toFirestore/fromFirestore, copyWith)
   - [ ] Create `lib/features/chat/models/message.dart` (unified Message for text/voice/missed_call, with reactions field)

### 2. **Providers** 
   - [ ] Create `lib/features/chat/providers/reactions_provider.dart` (family StreamProvider<List<Reaction>> for msg reactions)
   - [ ] Update `lib/features/chat/providers/chat_messages_provider.dart` (align path to /matches/{matchId}/messages/, enrich with reactions data or link)

### 3. **Services**
   - [ ] Create `lib/features/chat/services/chat_service.dart` (toggleReaction, deleteMessage, etc.)

### 4. **UI Widgets** (lib/features/chat/widgets/)
   - [ ] Create `message_bubble.dart` (generalized, longPress -> picker, Stack w/ chips)
   - [ ] Create `reaction_chips_row.dart` (grouped chips, tap -> summary)
   - [ ] Update `voice_note_bubble.dart` (use MessageBubble wrapper)
   - [ ] Create `reaction_summary_sheet.dart` (who reacted tabs)

### 5. **Enhance Existing**
   - [ ] Update `message_reaction_picker.dart` (hook onReactionSelected to service, context actions)
   - [ ] Create `emoji_picker_full.dart` (DraggableSheet, search, categories incl. African, recent)

### 6. **Integrate to Screen**
   - [ ] Update `chat_detail_screen.dart` (use MessageBubble in ListView, fix isOutgoing, add reply state to input)

### 7. **Polish**
   - [ ] Add animations (ScaleTransition tray/chips, blur backdrop)
   - [ ] Haptics (HapticFeedback)
   - [ ] Accessibility (Semantics labels)
   - [ ] Bilingual (use AppLocalizations)
   - [ ] Update l10n/app_en.arb & app_fr.arb for new strings

### 8. **Test**
   - [ ] Run app: long-press bubbles, toggle reactions, picker/full picker, context menu, chips tap
   - [ ] Multi-device Firestore test (reactions sync)

### 9. **Completion**
   - [ ] attempt_completion

Progress tracked here. Each step confirmed via tool results before next.

