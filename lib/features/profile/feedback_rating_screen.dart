import 'package:flutter/material.dart';
import 'package:sawalove/shared/widgets/pressable_scale.dart';
import '../../core/theme/theme.dart';

class FeedbackRatingScreen extends StatefulWidget {
  const FeedbackRatingScreen({super.key});

  @override
  State<FeedbackRatingScreen> createState() => _FeedbackRatingScreenState();
}

class _FeedbackRatingScreenState extends State<FeedbackRatingScreen> {
  int _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  bool _submitted = false;

  final List<String> _ratingLabels = [
    '😢 Disappointing',
    '😞 Could be better',
    '😐 Okay',
    '🙂 Good',
    '🥰 Amazing!',
  ];

  void _submitRating() {
    setState(() => _submitted = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_feedbackController.text.isNotEmpty 
          ? 'Thanks for your feedback!' 
          : 'Thanks for rating $_rating ⭐!'),
        backgroundColor: _rating >= 4 ? SawaLoveTheme.primary : SawaLoveTheme.warning,
      ),
    );
    // Analytics log
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate SawaLove'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Title
            Text(
              'How are you enjoying SawaLove?',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your rating helps us improve!',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: SawaLoveTheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // Stars
            GestureDetector(
              onTap: () => setState(() => _rating = 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starRating = index + 1;
                  return PressableScale(
                    onTap: () => setState(() => _rating = starRating),
                    child: Icon(
                      starRating <= _rating ? Icons.star : Icons.star_border,
                      color: SawaLoveTheme.primary,
                      size: 48,
                    ),
                  );
                }),
              ),
            ),
            if (_rating > 0) ...[
              const SizedBox(height: 8),
              Text(
                _ratingLabels[_rating - 1],
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 32),
            // Feedback
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Optional feedback', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _feedbackController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'What do you love or want improved?',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            if (_submitted)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: SawaLoveTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.check_circle, color: SawaLoveTheme.primary, size: 64),
                    SizedBox(height: 16),
                    Text('Thank you!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                    SizedBox(height: 8),
                    Text('Your input helps 10,000+ Cameroonians find love.', style: TextStyle(color: SawaLoveTheme.primary)),
                  ],
                ),
              )
            else ...[
              ElevatedButton(
                onPressed: _rating > 0 ? _submitRating : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: Text('Submit ($_rating/5 ⭐)'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Maybe Later'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

