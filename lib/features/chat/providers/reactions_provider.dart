import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/reaction.dart';

final reactionsProvider =
    StreamProvider.family<List<Reaction>, ({String matchId, String messageId})>(
  (ref, ids) => Stream.value([]),
);
